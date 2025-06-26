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
