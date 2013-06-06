#!/usr/bin/env perl

###################################
# OdenWlan perl
# https://github.com/odentools/oden_wlan_perl
# (C) OdenTools Project - 2013.
###################################

use strict;
use warnings;

use lib 'lib/';
use Net::OECU::LAN::MC2Wifi;
use Config::Pit;

# Initialize and read configurations. (ARGV parameter is primary.)
my $mode = 'default';
my $user = {
	'username' => '',
	'password' => '',
};

my $config;
eval {
	$config = Config::Pit::get("odenwlan");
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
	} elsif ($_ =~ /--init/i){
		$mode = 'init';
	} elsif ($_ =~ /--setproxy/i){
		$mode = 'set_proxy';
	} elsif ($_ =~ /--unsetproxy/i){
		$mode = 'unset_proxy';
	}
}

# Check the settings
my $config_flg = 1;
if(!defined $user->{username} || $user->{username} eq ''){
	print "[NOTICE] Username is null.\n";
	$config_flg = 0;
}
if(!defined $user->{password} || $user->{password} eq ''){
	print "[NOTICE] password is null.\n";
	$config_flg = 0;
}

if($mode eq 'init'){
	config_mc2wifi($user);
	$mode = 'default';
} elsif($config_flg == 0){
	print "\nWould you configration in now ? [y/n]: ";
	my $ans = <STDIN>;
	if($ans =~ /y/i){
		config_mc2wifi($user);
	} else {
		print "Canceled.\n";
		exit;
	}
}

if($mode eq 'default') {
	# Connect
	eval{
		connect_mc2wifi($user->{username}, $user->{password});
	}; if ($@) { die "[Error] $@\n"; }
} elsif($mode eq 'proxy-set'){
	# Set proxy
	eval{
		set_proxy_mc2wifi($user->{username}, $user->{password});
	}; if ($@) { die "[Error] $@\n"; }
}elsif($mode eq 'proxy-unset'){
	# Unset proxy
	eval{
		unset_proxy_mc2wifi($user->{username}, $user->{password});
	}; if ($@) { die "[Error] $@\n"; }
}
exit;

# Configuration for MC2Wifi
sub config_mc2wifi {
	my ($user_hash_ref) = shift;
	print "\n-- Configuration for MC2Wifi --\n\n";

	my $username = "";
	my $password = "";

	if( $username eq "" ){
		print "Please input your MC2 username (ex: ht13a000): ";
		$username = <STDIN>;
		chomp($username);
		if($username eq ""){
			print "Canceled.\n";
			return;
		}
	}

	print "\n";

	if( $password eq "" ){
		print "Please input your MC2 password: ";
		$password = <STDIN>;
		chomp($password);
		if($password eq ""){
			print "Canceled.\n";
			return;
		}
	}

	# Save the configuration to Config::Pit
	my $config = Config::Pit::set("odenwlan", data => {
		username => $username,
		password => $password,
	});

	# Apply now
	if(defined $user_hash_ref){
		$user_hash_ref->{username} = $username;
		$user_hash_ref->{password} = $password;
	}

	print "\n";
	print "Complete configuration!";
	print "However, this setting is still unconfirmed.\n\n";
	print "You must re-configration, if this setting is wrong.\n";
	print "You can re-configuration with command: \$ odenwlan.pl --init\n";
}

# Connect to MC2Wifi and Set proxy
sub connect_mc2wifi {
	my ($username, $password) = @_;
	print "\n-- Connect to MC2Wifi --\n\n";

	# Initialize the network module
	my $network = Net::OECU::LAN::MC2Wifi->new(
		username => $username,
		password => $password,
	);

	if($network->is_logged_in() == 1){
		print "[Info] ログイン済みです。\n";
		# Set proxy
		$network->env_set_proxy();
	} elsif($network->is_logged_in() == -1){
		print "[Info] サポートされていないネットワークに接続済みです。\n";
		# Set proxy
		$network->env_unset_proxy();
	} else {
		print "[Info] ログインしています...\n";
		$network->login();
		if($network->is_logged_in()){
			print "[Info] ログイン成功 :)\n";

			# Set proxy
			$network->env_set_proxy();
		} else {
			print "[Error] ログイン失敗 :(\n";
		}
	}
	return;
}

# Set proxy for MC2Wifi
sub set_proxy_mc2wifi {
	my ($username, $password) = @_;
	# Initialize the network module

	my $network = Net::OECU::LAN::MC2Wifi->new(
		username => $username,
		password => $password,
	);

	# Set proxy
	$network->env_set_proxy();
}

# Unset proxy for MC2Wifi
sub unset_proxy_mc2wifi {
	my ($username, $password) = @_;
	
	# Initialize the network module
	my $network = Net::OECU::LAN::MC2Wifi->new(
		username => $username,
		password => $password,
	);

	# Unset proxy
	$network->env_unset_proxy();
}