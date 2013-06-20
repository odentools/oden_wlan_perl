#!/bin/bash
#
# Install script for OdenWlan perl gnome-shell extension
# supported: gnome 3.4 or later
#
# [How to install]
# $ bash install.sh
#

echo "Fetch builder files..."
git --version
GIT_IS_AVAILABLE=$?
if [ $GIT_IS_AVAILABLE -eq 1 ]; then
	echo "[Error] Please install the 'git' by using such as apt-get or yum"
	exit
fi

if [ ! -f "/usr/bin/gnome-autogen.sh" ]; then
	echo "[Error] Please install the 'gnome-common' package by using such as apt-get or yum."
	exit
fi

git clone git://git.gnome.org/gnome-shell-extensions
if [ ! -d "gnome-shell-extensions/" ]; then
	echo "[Error] Can not fetch a files from the repository."
	exit
fi

#if [ ! -d "$HOME/.local/share/gnome-shell/extensions/network-odenwlan@gnome-extensions.odentools.github.com" ]; then
#	mkdir $HOME/.local/share/gnome-shell/extensions/network-odenwlan@gnome-extensions.odentools.github.com
#fi
#cp *.js $HOME/.local/share/gnome-shell/extensions/network-odenwlan@gnome-extensions.odentools.github.com/

if [ ! -d "gnome-shell-extensions/extensions/network-odenwlan" ]; then
	mkdir gnome-shell-extensions/extensions/network-odenwlan
fi
cp *.js gnome-shell-extensions/extensions/network-odenwlan/
cp *.css gnome-shell-extensions/extensions/network-odenwlan/

cd gnome-shell-extensions/
make clean
./autogen.sh --prefix="$HOME/.local" --enable-extensions="network-odenwlan"
make install
echo "Done :)"
echo "Please restart your login session."
