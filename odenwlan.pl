
use lib 'lib/';
use Net::OECU::LAN::OecuWifi;

our $network = Net::OECU::LAN::OecuWifi->new(
	username => '',
	password => '',
);


if($network->is_logged_in()){
	print "[Info] すでにログイン済みです。\n";
} else {
	print "[Info] ログインしています...\n";
	$network->login();
}

exit;

sub connect {

}
