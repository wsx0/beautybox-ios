# gh_build.ps1 —— 一键推仓库 + 触发 Actions + 下载并校验 ipa
# 用法:
#   $env:GH_TOKEN="ghp_xxx"        # token 需要 repo + workflow 权限
#   .\scripts\gh_build.ps1 -Repo "账号/beautybox-ios"
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$Repo,
    [string]$Token = $env:GH_TOKEN,
    [string]$Branch = "main",
    [string]$Workflow = "ios-ipa.yml",
    [int]$TimeoutMin = 25
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
$Api  = "https://api.github.com"

function Say($m) { Write-Host $m }
function Fail($m) { Write-Host "[FAIL] $m" -ForegroundColor Red; exit 1 }

if (-not $Token) { Fail '没有 token。先设置环境变量 GH_TOKEN（需要 repo 与 workflow 权限），或用 git push 手动推。' }
$parts = $Repo.Split("/")
if ($parts.Count -ne 2) { Fail "Repo 要写成 账号/仓库名" }
$owner = $parts[0]; $name = $parts[1]

$headers = @{
    Authorization          = "token $Token"
    Accept                 = "application/vnd.github+json"
    "X-GitHub-Api-Version" = "2022-11-28"
    "User-Agent"           = "beautybox-port"
}

Say "[1/6] 检查仓库 $Repo"
$exists = $true
try { Invoke-RestMethod -Uri "$Api/repos/$owner/$name" -Headers $headers -Method Get | Out-Null }
catch { $exists = $false }

if (-not $exists) {
    Say "      创建私有仓库 $name"
    $body = @{ name = $name; private = $true; auto_init = $false } | ConvertTo-Json
    try { Invoke-RestMethod -Uri "$Api/user/repos" -Headers $headers -Method Post -Body $body -ContentType "application/json" | Out-Null }
    catch { Fail "创建仓库失败：$($_.Exception.Message)" }
} else {
    Say "      仓库已存在，直接推"
}

Say "[2/6] 提交并推送"
Push-Location $Root
try {
    $git = "git"
    if (-not (Get-Command $git -ErrorAction SilentlyContinue)) { $git = "C:\Program Files\Git\cmd\git.exe" }
    if (-not (Test-Path (Join-Path $Root ".git"))) { & $git init -q }
    & $git -c user.name="beautybox" -c user.email="beautybox@local" add -A
    & $git -c user.name="beautybox" -c user.email="beautybox@local" commit -q -m "sync before build" 2>$null
    $remote = "https://x-access-token:$Token@github.com/$owner/$name.git"
    $has = & $git remote 2>$null
    if ($has -contains "origin") { & $git remote set-url origin $remote } else { & $git remote add origin $remote }
    & $git branch -M $Branch
    & $git push -u origin $Branch --force 2>&1 | Select-Object -Last 3
    if ($LASTEXITCODE -ne 0) { Fail "推送失败" }
} finally { Pop-Location }

Say "[3/6] 触发 workflow $Workflow"
Start-Sleep -Seconds 3
$body = @{ ref = $Branch } | ConvertTo-Json
try { Invoke-RestMethod -Uri "$Api/repos/$owner/$name/actions/workflows/$Workflow/dispatches" -Headers $headers -Method Post -Body $body -ContentType "application/json" | Out-Null }
catch { Fail "触发失败：$($_.Exception.Message)" }

Say "[4/6] 等待构建（最长 $TimeoutMin 分钟）"
$deadline = (Get-Date).AddMinutes($TimeoutMin)
$run = $null
while ((Get-Date) -lt $deadline) {
    Start-Sleep -Seconds 15
    $runs = Invoke-RestMethod -Uri "$Api/repos/$owner/$name/actions/runs?per_page=5" -Headers $headers
    $run = $runs.workflow_runs | Where-Object { $_.name -eq "build-ipa" } | Select-Object -First 1
    if ($run) {
        Say ("      run #" + $run.run_number + "  " + $run.status + " / " + $run.conclusion)
        if ($run.status -eq "completed") { break }
    }
}
if (-not $run) { Fail "没找到运行记录" }
if ($run.conclusion -ne "success") { Fail "构建失败：$($run.html_url)" }

Say "[5/6] 下载产物"
$arts = Invoke-RestMethod -Uri "$Api/repos/$owner/$name/actions/runs/$($run.id)/artifacts" -Headers $headers
$art = $arts.artifacts | Where-Object { $_.name -like "BeautyBox*" } | Select-Object -First 1
if (-not $art) { Fail "没有产物" }
$zip = Join-Path $Root "build\artifact.zip"
New-Item -ItemType Directory -Force -Path (Join-Path $Root "build") | Out-Null
Invoke-WebRequest -Uri $art.archive_download_url -Headers $headers -OutFile $zip
Expand-Archive -Path $zip -DestinationPath (Join-Path $Root "build\artifact") -Force
$ipa = Get-ChildItem (Join-Path $Root "build\artifact") -Recurse -Filter *.ipa | Select-Object -First 1
Say "      ipa: $($ipa.FullName)"

Say "[6/6] 结构校验"
$py = "python"
if (-not (Get-Command $py -ErrorAction SilentlyContinue)) {
    $py = "C:\Users\王世雄\.dsh\dsh-runtimes\dsh-primary-runtime\dependencies\python\python.exe"
}
& $py (Join-Path $Root "scripts\verify_ipa.py") $ipa.FullName
if ($LASTEXITCODE -ne 0) { Fail "ipa 校验没过，别拿去签" }
Say "完成：$($ipa.FullName)"
