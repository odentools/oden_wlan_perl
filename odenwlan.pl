
use lib 'lib/';
use Net::OECU::LAN::MC2Wifi;
use Config::Pit;

my $config = Config::Pit->pit_get("odenwlan");

my $network = Net::OECU::LAN::MC2Wifi->new(
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
