#!/bin/sh
set -eu
cd "$(dirname "$0")/.."

APP_NAME="Corner Magnet"
APP_DIR="$PWD/build/$APP_NAME.app"
BINARY="$PWD/.build/release/CornerMagnet"

swift test
swift build -c release
mkdir -p "$APP_DIR/Contents/MacOS" "$APP_DIR/Contents/Resources"
cp "$BINARY" "$APP_DIR/Contents/MacOS/CornerMagnet"

cat > "$APP_DIR/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key><string>Corner Magnet</string>
  <key>CFBundleDisplayName</key><string>Corner Magnet</string>
  <key>CFBundleIdentifier</key><string>com.asashiki.cornermagnet</string>
  <key>CFBundleExecutable</key><string>CornerMagnet</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleVersion</key><string>0.1.0</string>
  <key>CFBundleShortVersionString</key><string>0.1.0</string>
  <key>LSMinimumSystemVersion</key><string>13.0</string>
  <key>LSUIElement</key><true/>
  <key>NSHighResolutionCapable</key><true/>
</dict>
</plist>
PLIST

codesign --force --deep --sign - "$APP_DIR"
echo "Built: $APP_DIR"
