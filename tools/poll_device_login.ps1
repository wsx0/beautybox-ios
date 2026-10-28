# 后台轮询 GitHub 设备授权，成功后把 token 写到 scripts/.gh_token
$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$dev = Get-Content -Raw -Encoding UTF8 "D:\deepseek项目\软件破解\beautybox_port\build\_device.json" | ConvertFrom-Json
$h = @{ Accept = "application/json"; "User-Agent" = "beautybox-port" }
$body = @{
    client_id   = "178c6fc778ccc68e1d6a"
    device_code = $dev.device_code
    grant_type  = "urn:ietf:params:oauth:grant-type:device_code"
}
$deadline = (Get-Date).AddSeconds([int]$dev.expires_in)
while ((Get-Date) -lt $deadline) {
    try {
        $r = Invoke-RestMethod -Uri "https://github.com/login/oauth/access_token" -Method Post -Body $body -Headers $h -TimeoutSec 30
    } catch {
        Write-Host "poll error: $($_.Exception.Message)"
        Start-Sleep -Seconds 6
        continue
    }
    if ($r.access_token) {
        $p = "D:\deepseek项目\软件破解\beautybox_port\scripts\.gh_token"
        [System.IO.File]::WriteAllText($p, $r.access_token, (New-Object System.Text.UTF8Encoding($false)))
        Write-Host "AUTHORIZED scope=$($r.scope)"
        exit 0
    }
    if ($r.error -eq "authorization_pending") { Write-Host "."; Start-Sleep -Seconds 5; continue }
    if ($r.error -eq "slow_down") { Start-Sleep -Seconds 10; continue }
    Write-Host "STOP $($r.error) $($r.error_description)"
    exit 1
}
Write-Host "EXPIRED"
exit 2
