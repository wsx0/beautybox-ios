#!/usr/bin/env bash
# BeautyBox: APK 移植工程 -> 未签名 ipa（给 Sideloadly / AltStore / 爱思助手 自签）
#
# 用法（macOS + Xcode 15+）:
#   ./scripts/build_ipa.sh                     # 未签名 ipa -> build/BeautyBox-unsigned.ipa
#   TEAM_ID=ABCDE12345 ./scripts/build_ipa.sh  # 已签名导出 -> build/export/BeautyBox.ipa
set -eo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
PROJ="$ROOT/ios/BeautyBox.xcodeproj"
WEBAPP="$ROOT/ios/webapp"
BUNDLED="$ROOT/ios/BeautyBox/Resources/webapp"
BUILD="$ROOT/build"
ARCHIVE="$BUILD/BeautyBox.xcarchive"
SCHEME="BeautyBox"

command -v xcodebuild >/dev/null 2>&1 || {
  echo "没有 xcodebuild：需要在 macOS 上跑，或用 .github/workflows/ios-ipa.yml 在 GitHub Actions 上构建"
  exit 2
}

mkdir -p "$BUILD"

# 1) 把 Web App 同步到工程资源（目录引用，打出来的包里保留 webapp/ 层级）
if [ -d "$WEBAPP" ]; then
  rm -rf "$BUNDLED"
  mkdir -p "$BUNDLED"
  (cd "$WEBAPP" && tar --exclude='serve.py' --exclude='qr.png' --exclude='__pycache__' -cf - .) | (cd "$BUNDLED" && tar -xf -)
  echo "[1/5] 同步 webapp -> $BUNDLED ($(find "$BUNDLED" -type f | wc -l | tr -d ' ') 个文件)"
fi

# 2) 重新生成工程（幂等，新文件自动带上）
if command -v python3 >/dev/null 2>&1; then
  python3 "$ROOT/tools/gen_xcodeproj.py" --ios-dir "$ROOT/ios" --verify
  echo "[2/5] 工程已生成并校验"
fi

# 3) 归档（关签名先拿未签名包）
rm -rf "$ARCHIVE"
xcodebuild -project "$PROJ" -scheme "$SCHEME" -configuration Release -sdk iphoneos \
  -archivePath "$ARCHIVE" CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO \
  build archive
APP="$ARCHIVE/Products/Applications/BeautyBox.app"
[ -d "$APP" ] || { echo "归档里没有 BeautyBox.app：$APP"; exit 1; }
echo "[3/5] 归档完成：$APP"

# 4) 已签名导出 / 未签名打包
if [ -n "$TEAM_ID" ]; then
  cat > "$BUILD/ExportOptions.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>method</key><string>development</string>
  <key>teamID</key><string>$TEAM_ID</string>
  <key>signingStyle</key><string>automatic</string>
  <key>stripSwiftSymbols</key><true/>
</dict></plist>
PLIST
  rm -rf "$BUILD/export"
  xcodebuild -exportArchive -archivePath "$ARCHIVE" \
    -exportOptionsPlist "$BUILD/ExportOptions.plist" -exportPath "$BUILD/export"
  IPA=$(ls "$BUILD/export"/*.ipa | head -n 1)
  echo "[4/5] 已签名 ipa: $IPA"
else
  rm -rf "$BUILD/Payload"
  mkdir -p "$BUILD/Payload"
  cp -R "$APP" "$BUILD/Payload/"
  rm -f "$BUILD/BeautyBox-unsigned.ipa"
  (cd "$BUILD" && zip -qry BeautyBox-unsigned.ipa Payload)
  IPA="$BUILD/BeautyBox-unsigned.ipa"
  echo "[4/5] 未签名 ipa: $IPA ($(du -h "$IPA" | cut -f1))"
fi

# 5) 结构自检
if command -v python3 >/dev/null 2>&1 && [ -f "$ROOT/scripts/verify_ipa.py" ]; then
  python3 "$ROOT/scripts/verify_ipa.py" "$IPA" || exit 1
fi
echo "[5/5] 完成。用 Sideloadly / AltStore 签名安装，见 scripts/sideload.md"
