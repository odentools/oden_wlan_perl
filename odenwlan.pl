#!/usr/bin/env perl

###################################
# OdenWlan perl
# https://github.com/odentools/oden_wlan_perl
# (C) OdenTools Project - 2013.
###################################

use lib 'lib/';
use Net::OECU::LAN::MC2Wifi;
use Config::Pit;

# Initialize and read configurations. (ARGV parameter is primary.)
my $user = {
	'username' => '',
	'password' => '',
};

my $config;
eval {
	$config = Config::Pit::get("odenwlan");
	print Dumper $config;
	if(defined $config->{username}){
		$user->{username} = $config->{username};
	}
	if(defined $config->{password}){
		$user->{password} = $config->{password};
	}
}; if ($@) { warn "[Warn] $@\n"; }

foreach(@ARGV){
	if($_ =~ /--username=(.+)/i){
		$user->{username} = $1;
	} elsif ($_ =~ /--password=(.+)/i){
		$user->{password} = $1;
	}
}

# Connect
eval{
	connect_mc2wifi($user->{username}, $user->{password});
}; if ($@) { die "[Error] $@\n"; }

exit;

sub connect_mc2wifi {
	my ($username, $password) = @_;

	# Initialize the network module
	my $network = Net::OECU::LAN::MC2Wifi->new(
		username => $username,
		password => $password,
	);

	if($network->is_logged_in()){
		print "[Info] すでにログイン済みです。\n";
	} else {
		print "[Info] ログインしています...\n";
		$network->login();
		if($network->is_logged_in()){
			print "[Info] ログイン成功 :)\n"
		} else {
			print "[Error] ログイン失敗 :(\n";
		}
	}
	return;
}
