#!/bin/sh
#
# OdenWlan perl install script for Ubuntu (10.xx or later)
# 

echo "-- OdenWlan-perl Install script --"

echo "Install dependency packages..."
sudo apt-get install make perl cpan libssl-devel
sudo cpan App:cpanminus
sudo LANG=C cpan Crypt::SSLeay

echo "Install OdenWlan-perl..."
perl Makefile.PL
make
sudo make install

echo "Done :)"
echo "Enjoy browsing! $ odenwlan"
