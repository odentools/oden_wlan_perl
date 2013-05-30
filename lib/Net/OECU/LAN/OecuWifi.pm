package Net::OECU::LAN::OecuWifi;
#############################################
# OECU LAN connection module for OECU wifi
# (C) OdenTools Project - 2013.
#############################################

use strict;
use warnings;

use URI;
use LWP::UserAgent;
use Data::Dumper;

sub new {
	my ($class, %hash) = @_;
	my $self = bless({}, $class);
	
	$self->{username} = $hash{username} || die('Not specified username.');
	$self->{password} = $hash{password} || die('Not specified password.');
	
	# Initialize the user-agent
	$self->{ua} = LWP::UserAgent->new;
	$self->{ua}->timeout(10);
	$self->{ua}->max_redirect(5);
	
	#$ENV{HTTPS_CA_FILE} = '.webauth.it.osakac.ac.jp_chain.cert';
	
	return $self;
}

# login() - Login to Wlannet
sub login {
	my $self = shift;

	# Check url
	$self->_ua_unset_proxy();
	my $response = $self->{ua}->get('http://www.osakac.ac.jp/');
	unless ($response->is_success && $response->title eq '無線LAN 利用者認証ページ') { # 未ログイン
		return -1;
	}

	#if(!defined $current_location || $current_location !~ /http:\/\/wlanlogin\.mc2ed\.sjn\.osakac\.ac\.jp\/.*/){
	#	return -1;
	#}

	# Get the "sip" parameter
	my $current_location = $response->previous->header('location');
	$current_location =~ /.*sip=([0-9.]+)\&/;
	my $sip = $1;

	if(!defined $sip || $sip eq ''){
		die '[Error] sip parameter is null.';
	}

	# Select login url
	my $login_url;
	if($sip eq '172.25.250.91'){
		$login_url = 'https://mcwlct1s.mc2ed.sjn.osakac.ac.jp:9998/login';
	} elsif($sip eq '172.25.250.92') {
		$login_url = 'https://mcwlct2s.mc2ed.sjn.osakac.ac.jp:9998/login';
	} else {
		die '[Error] Unknown sip.';
	}
	
	$response = $self->{ua}->post( $login_url,
		'username' => $self->{username},
		'password' => $self->{password},
		'submit' => 'Login',
	);

	print $response->as_string."\n\n";
	
	if ($response->is_success) {
		print $response->decoded_content;
		return 1;		
	}
	die $response->status_line;
}

# logout() - Logout from Wlannet
sub logout {
	my $self = shift;
	
	$self->{ua}->post('https://192.168.4.252/logout.html',
		'userStatus' => 1,
		'Logout' => 'Logout',
	);
	
	return 1;
}

# is_logged_in() - Check currently logged-in. Return: 1 = true, 0 = false
sub is_logged_in {
	my $self = shift;
	my $response = $self->{ua}->get('http://www.osakac.ac.jp/');
	if ($response->is_success && $response->title eq '無線LAN 利用者認証ページ') { # 未ログイン
		return 0;
	}
	return 1;
}

# _ua_set_proxy
sub _ua_set_proxy {
	my $self = shift;
	$self->{ua}->proxy('http', 'http://172.25.250.41:8080/');
	$self->{ua}->proxy('https', 'http://172.25.250.41:8080/');
}

# _ua_unset_proxy
sub _ua_unset_proxy {
	my $self = shift;
	$self->{ua}->proxy('http', '');
	$self->{ua}->proxy('https', '');
}

1;
