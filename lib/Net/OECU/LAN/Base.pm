package Net::OECU::LAN::Base;
#############################################
# OECU LAN connection Base module
# (C) OdenTools Project - 2013.
#############################################

use strict;
use warnings;

use URI;
use LWP::UserAgent;

sub new {
	my ($class, %hash) = @_;
	my $self = bless({}, $class);
	
	$self->{username} = $hash{username} || die('Not specified username.');
	$self->{password} = $hash{password} || die('Not specified password.');
	
	# Initialize the user-agent
	$self->{ua} = LWP::UserAgent->new;
	$self->{ua}->timeout(10);
	$self->{ua}->max_redirect(5);
	$self->{ua}->agent('OdenWlan-Perl/Net::OECU::LAN::MC2Wifi/1.0');

	my $a = <<'EOF';
-----BEGIN CERTIFICATE-----
MIIEvzCCA6egAwIBAgISESHNMfeNJw/6mnbdn/53ZgNCMA0GCSqGSIb3DQEBBQUA
MC4xETAPBgNVBAoTCEFscGhhU1NMMRkwFwYDVQQDExBBbHBoYVNTTCBDQSAtIEcy
MB4XDTEzMDMyOTA0NTcyN1oXDTE2MDMyOTA0NTcyN1owTTEhMB8GA1UECxMYRG9t
YWluIENvbnRyb2wgVmFsaWRhdGVkMSgwJgYDVQQDEx9tY3dsY3Qxcy5tYzJlZC5z
am4ub3Nha2FjLmFjLmpwMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA
xDuCZ58nRR9L2H8wHr2WRbtTJtttFANowCSc3Lg9cgYi6GQPMqYSwPjaYU/Hyq4O
ACvol8OqytLu4+MSK6Q8Gd9BkkGj/xGHZ6/d7b3qm94XrvrC7+QU9/YEUh7V+Obc
0dUhBITrfbd82BdyB++chtij32doTespT4sT9+XG2cfGjo9SD6x2KNll94WIJZ2C
OfKBjPpLLKkd4kHX6nb45nBENlFlQidCJGs1gqxPPOut9z6uoVV/had6C7lUq2rU
jP2kBv20vBi0VdJFbfbRm4GChndyE2fFfQMD4HFGhEjtVAvI0o2dB5g5Fg4UlnPj
0asulGguir1AMCXtOMYepwIDAQABo4IBtjCCAbIwDgYDVR0PAQH/BAQDAgWgME0G
A1UdIARGMEQwQgYKKwYBBAGgMgEKCjA0MDIGCCsGAQUFBwIBFiZodHRwczovL3d3
dy5nbG9iYWxzaWduLmNvbS9yZXBvc2l0b3J5LzAqBgNVHREEIzAhgh9tY3dsY3Qx
cy5tYzJlZC5zam4ub3Nha2FjLmFjLmpwMAkGA1UdEwQCMAAwHQYDVR0lBBYwFAYI
KwYBBQUHAwEGCCsGAQUFBwMCMDoGA1UdHwQzMDEwL6AtoCuGKWh0dHA6Ly9jcmwy
LmFscGhhc3NsLmNvbS9ncy9nc2FscGhhZzIuY3JsMH8GCCsGAQUFBwEBBHMwcTA8
BggrBgEFBQcwAoYwaHR0cDovL3NlY3VyZTIuYWxwaGFzc2wuY29tL2NhY2VydC9n
c2FscGhhZzIuY3J0MDEGCCsGAQUFBzABhiVodHRwOi8vb2NzcDIuZ2xvYmFsc2ln
bi5jb20vZ3NhbHBoYWcyMB0GA1UdDgQWBBRCGkSrdQsUmmW38sBfhTAUFUpFZDAf
BgNVHSMEGDAWgBQU6hlV8A4NMsYfdDO3jmYaTBIxHjANBgkqhkiG9w0BAQUFAAOC
AQEAHFVNx4lw8yZW+/ybZS/yv07GcZO0q5yzr9mEDTu7fqnvSL/Ojli+NghAw8yX
zNC/YToHy+Wi/BgLb3WzrnzAPWORA9NbsEnwAAJwpVPMhsu9+Btk+jRuQdGjCL7G
bthgywBj+FLbFAs7JZGP4o/u6f4GucLImyCBcuz32+rMRRRv9i6EJkMZjXFUXADK
bXHQ3ZGmF15+OUAum7e6v8R2MEytwHigYGL1ZhI0Jj3AvPCvBpd90udp4l9ZSjTf
z7ePYpdQlzckT53FmIArzNcunTDMnzVM9y1dNX9An5B3Sb5Gi8bxRWNzC+WyvBRE
kCWjnNAM/0HrGgJ1m7TkmSwsLA==
-----END CERTIFICATE-----
EOF

	$self->{ua}->ssl_opts(
		verify_hostname => 1,
		SSL_cert => {
			"mcwlct1s.mc2ed.sjn.osakac.ac.jp" => $a,
		},
	);
	
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

	$response = $self->{ua}->post( $login_url, {
		'username' => $self->{username},
		'password' => $self->{password},
		'submit' => 'Login',
	});
	
	print $login_url."\n";

	unless ($response->is_success) {
		warn '[Debug] '.$response->as_string."\n";
		die '[Error] Login error : '.$response->status_line."\n";
	}

	if($response->as_string =~ /window\.location\.href\=\'(http\:\/\/[^\']+)\'/){
		# Detect last redirect with JavaScript
		my $last_url = $1;
		print "$last_url\n";
		$response = $self->{ua}->get( $last_url );
	}

	return 1;
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

# env_set_proxy() - Set the proxy to ENV
sub env_set_proxy {
	my $self = shift;

}

# env_set_proxy() - Unset the proxy to ENV
sub env_unset_proxy {
	my $self = shift;

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
