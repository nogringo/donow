app_title="Donow"
app_title_lower_case="donow"

rm -rf build/output
mkdir -p build/output

flutter build linux
flutter build apk
flutter build aab
flutter build web

cp build/app/outputs/flutter-apk/app-release.apk build/output/$app_title.apk
cp build/app/outputs/bundle/release/app-release.aab build/output/$app_title.aab

cd build && zip -r ${app_title}-web.zip web && cd -
mv build/${app_title}-web.zip build/output/

cp linux/${app_title_lower_case}.desktop build/linux/x64/release/bundle/
sed -i "s|/usr/local/bin/${app_title_lower_case}|.|g" build/linux/x64/release/bundle/${app_title_lower_case}.desktop
cd build/linux/x64/release && zip -r ${app_title}-linux-bundle.zip bundle && cd -
rm -rf build/linux/x64/release/bundle/${app_title_lower_case}.desktop
mv build/linux/x64/release/${app_title}-linux-bundle.zip build/output/

bash linux/build_deb.sh

# Build AppImage
echo "Building AppImage..."

# Create AppDir structure
APPDIR="build/linux/x64/release/AppDir"
rm -rf "$APPDIR"
mkdir -p "$APPDIR"

# Copy the entire bundle to AppDir
cp -r build/linux/x64/release/bundle/* "$APPDIR/"

# Create AppRun script
cat > "$APPDIR/AppRun" << 'APPRUN_EOF'
#!/bin/bash
SELF=$(readlink -f "$0")
HERE=${SELF%/*}
export PATH="${HERE}/bin:${HERE}/usr/bin:${PATH}"
export LD_LIBRARY_PATH="${HERE}/lib:${HERE}/usr/lib:${HERE}/lib/x86_64-linux-gnu:${HERE}/usr/lib/x86_64-linux-gnu:${HERE}/usr/lib64:${LD_LIBRARY_PATH}"
cd "${HERE}"
exec "${HERE}/Donow" "$@"
APPRUN_EOF
chmod +x "$APPDIR/AppRun"

# Create desktop file for AppImage
cat > "$APPDIR/${app_title_lower_case}.desktop" << DESKTOP_EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=${app_title}
Exec=${app_title}
Icon=${app_title_lower_case}
Comment=A Nostr native todo list app.
Categories=Utility;
StartupWMClass=com.example.${app_title_lower_case}
DESKTOP_EOF

# Copy icon
cp "linux/icon.png" "$APPDIR/${app_title_lower_case}.png"
ln -s "${app_title_lower_case}.png" "$APPDIR/.DirIcon"

# Download appimagetool if not present
APPIMAGETOOL="build/appimagetool-x86_64.AppImage"
if [ ! -f "$APPIMAGETOOL" ]; then
    echo "Downloading appimagetool..."
    wget -q -O "$APPIMAGETOOL" "https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage"
    chmod +x "$APPIMAGETOOL"
fi

# Build AppImage
export ARCH=x86_64
"$APPIMAGETOOL" "$APPDIR" "build/output/${app_title}-x86_64.AppImage" >/dev/null 2>&1 || "$APPIMAGETOOL" "$APPDIR" "build/output/${app_title}-x86_64.AppImage"

echo "AppImage created: build/output/${app_title}-x86_64.AppImage"
