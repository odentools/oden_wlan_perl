#!/bin/sh
#
# OdenWlan perl install script for Ubuntu 10.xx or later
# $ sh install_ubuntu.sh 

echo "-- OdenWlan-perl インストールスクリプト --"

echo "依存モジュールをインストールしています..."
sudo apt-get install make perl cpan libssl-dev
sudo cpan App:cpanminus
sudo LANG=C cpan Crypt::SSLeay

echo "OdenWlan-perlをインストールしています..."
perl Makefile.PL
make
IS_SUCCESS_MAKE=$?
if [ $IS_SUCCESS_MAKE -eq 0 ]; then
	echo "エラーが発生しました."
	exit -1
fi

sudo make install

echo "Done :)"
echo "Enjoy browsing! $ odenwlan"
