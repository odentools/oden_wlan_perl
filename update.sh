#!/bin/sh
#
# OdenWlan perl Update script for Linux distribution
# $ sh update.sh

echo "-- OdenWlan-perl アップデートスクリプト --"
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
		CON_NETWORK=0
		echo "[Error] インターネット接続が必要です。"
		exit
	fi
fi

echo "最新のOdenWlan-perlを取得しています..."
git fetch origin master
git reset --hard FETCH_HEAD

echo "OdenWlan-perlをアップデートしています..."
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
