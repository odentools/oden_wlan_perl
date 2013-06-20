#!/bin/sh
#
# OdenWlan perl install script for Ubuntu
# $ sh install_ubuntu.sh

echo "-- OdenWlan-perl インストールスクリプト --"

PROXY_URL="http://172.25.250.41:8080"
CON_NETWORK=1

echo "接続先ネットワークを識別しています..."
wget http://google.com/ --no-proxy -O - 1>/dev/null 2>/dev/null
IS_SUCCESS_CON=$?
if [ $IS_SUCCESS_CON -ne 0 ]; then
	# If error
	http_proxy=$PROXY_URL wget http://google.com/ -O - 1>/dev/null 2>/dev/null
	IS_SUCCESS_CON=$?
	CON_NETWORK=2
	if [ $IS_SUCCESS_CON -ne 0 ]; then
		# If error
		echo "[Error] インターネット接続が必要です。"
		exit
	fi
fi

echo "依存モジュールをインストールしています..."
if [ $CON_NETWORK -eq 1 ]; then
	# If connected with general network
	sudo apt-get install make perl cpan libssl-dev curl
	curl -LO http://xrl.us/cpanm
	chmod +x cpanm
	sudo LANG=C cpanm Crypt::SSLeay
elif [ $CON_NETWORK -eq 2 ]; then
	# If connected with MC2Wifi
	sudo http_proxy=$PROXY_URL apt-get install make perl libssl-dev curl
	curl -LO http://xrl.us/cpanm
	chmod +x cpanm
	sudo http_proxy=$PROXY_URL LANG=C cpanm Crypt::SSLeay
fi

echo "OdenWlan-perlをインストールしています..."
perl Makefile.PL
make
IS_SUCCESS_MAKE=$?
if [ $IS_SUCCESS_MAKE -ne 0 ]; then
	echo "[Error] インストール中にエラーが発生しました."
	exit -1
fi

if [ $CON_NETWORK -eq 1 ]; then
	sudo make install
elif  [ $CON_NETWORK -eq 2 ]; then
	sudo http_proxy=$PROXY_URL make install
fi

echo "Done :)"
echo "Enjoy browsing! $ odenwlan"
