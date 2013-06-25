#!/bin/sh
#
# OdenWlan perl install script for Ubuntu
# $ sh install_arch-linux.sh

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

echo "依存パッケージをインストールしています..."
if [ $CON_NETWORK -eq 1 ]; then
	# If connected with general network
	sudo apt-get install make perl cpan libssl-dev curl
	curl -LO http://xrl.us/cpanm
	chmod +x cpanm
	if [ -n "$PERL5LIB" ]; then
		echo "CPAN modules instal to local directory..."
		LANG=C cpanm Crypt::SSLeay
	else
		echo "CPAN modules instal to system..."
		sudo LANG=C cpanm Crypt::SSLeay
	fi
elif [ $CON_NETWORK -eq 2 ]; then
	# If connected with MC2Wifi
	sudo http_proxy=$PROXY_URL apt-get install make perl cpan libssl-dev curl
	http_proxy=$PROXY_URL curl -LO http://xrl.us/cpanm
	chmod +x cpanm
	if [ -n "$PERL5LIB" ]; then
		echo "CPAN modules instal to local directory..."
		http_proxy=$PROXY_URL LANG=C cpanm Crypt::SSLeay
	else
		echo "CPAN modules instal to system..."
		sudo http_proxy=$PROXY_URL LANG=C cpanm Crypt::SSLeay
	fi
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
	if [ -n "$PERL5LIB" ]; then
		# If PERL5LIB is defined, install to user directory
		echo "Install to user directory..."
		make install
	else
		# Install to system
		echo "Install to system..."
		sudo make install
	fi
elif  [ $CON_NETWORK -eq 2 ]; then
	if [ -n "$PERL5LIB" ]; then
		# If PERL5LIB is defined, install to user directory
		echo "Install to user directory..."
		http_proxy=$PROXY_URL make install
	else
		# Install to system
		echo "Install to system..."
		sudo http_proxy=$PROXY_URL make install
	fi
fi

echo "インストール完了 :)"
echo "Enjoy browsing! $ odenwlan"
