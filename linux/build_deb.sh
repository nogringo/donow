rm -rf build/linux/my_app_deb
rm -rf build/linux/donow.deb

mkdir -p build/linux/my_app_deb/usr/local/bin/donow/data/flutter_assets/assets
mkdir -p build/linux/my_app_deb/usr/share/applications
mkdir -p build/linux/my_app_deb/DEBIAN

cp -r build/linux/x64/release/bundle/* build/linux/my_app_deb/usr/local/bin/donow/

cp linux/donow.desktop build/linux/my_app_deb/usr/share/applications
cp linux/control build/linux/my_app_deb/DEBIAN
cp linux/icon.png build/linux/my_app_deb/usr/local/bin/donow/data/flutter_assets/assets/icon.png

dpkg-deb --build build/linux/my_app_deb build/linux/Donow.deb