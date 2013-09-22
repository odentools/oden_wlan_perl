package Net::OECU::LAN::MC2Wifi;
#############################################
# OECU LAN connection module for OECU wifi
# (C) OdenTools Project - 2013.
#############################################

use strict;
use warnings;

use base 'Net::OECU::LAN::Base';

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
	unless ($response->is_success && $response->title eq '無線LAN 利用者認証ページ') { # If logged-in already
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
	my $base_url;
	if($sip eq '172.25.250.91'){
		$base_url = 'https://mcwlct1s.mc2ed.sjn.osakac.ac.jp:9998';
	} elsif($sip eq '172.25.250.92') {
		$base_url = 'https://mcwlct2s.mc2ed.sjn.osakac.ac.jp:9998';
	} else {
		die '[Error] Unknown sip.';
	}

	$response = $self->{ua}->post( $base_url.'/login', {
		'username' => $self->{username},
		'password' => $self->{password},
		'submit' => 'Login',
	});
	
	$self->debug("Base url : ". ${base_url);

	unless ($response->is_success) {
		$self->debug("Response(NotSuccess): ". $response->as_string);
		die '[Error] Login error : '.$response->status_line."\n";
	}

	for(my $redirect = 0; $redirect < 5; $redirect += 1) {
		$self->debug("Response: ". $response->as_string);
		if ($response->as_string =~ /window\.location\.href\=\'(http\:\/\/[^\']+)\'/){
			# Detect second redirect with JavaScript
			my $redirect_url = $1;

			if($response->as_string =~ /img\.src = \"(.+)\"/) {
				my $img_url = $1;
				my $response = $self->{ua}->get( $base_url . $1 );
				$self->debug("Img Response: ". $response->as_string);
			}

			# Request
			$self->debug("Redirect(A) to: ". $redirect_url);
			$response = $self->{ua}->get( $redirect_url );
		} elsif ($response->as_string =~ /window\.location\.href\=\'\/login([^\']+)\'/) {
			# Detect final redirect with JavaScript
			my $redirect_url = $base_url . '/login' . $1;

			# Request
			$self->debug("Redirect(B) to: ". $redirect_url);
			$response = $self->{ua}->get( $redirect_url );
		} elsif ($response->as_string =~ /window\.location\.href\=\'\/([^\']+)\'/) {
			# Detect other redirect with JavaScript
			my $redirect_url = $1;

			# Request
			$self->debug("Redirect(Other) to: ". $redirect_url);
			$response = $self->{ua}->get( $redirect_url );
			last;
		} else {
			last;
		}
		sleep(1);
	}

	sleep(1);

	return 1;
}

# logout() - Logout from Wlannet
sub logout {
	my $self = shift;
	die "Not support logout on this VLAN."
}

# is_logged_in() - Check currently logged-in. Return: 1 = true, 0 = false, -1 = other network
sub is_logged_in {
	my $self = shift;

	$self->_ua_unset_proxy();
	my $response = $self->{ua}->get('http://google.com/');

	if ($response->is_success && $response->title eq '無線LAN 利用者認証ページ') {
		# Not logged-in
		return 0;
	} elsif ($response->is_error || 5<= $response->redirects){ # Detect error or redirect-loop
		# Retry with unset proxy
		$self->_ua_set_proxy();
		$response = $self->{ua}->get('http://google.com/');

		if ($response->is_error || $response->title eq '無線LAN 利用者認証ページ') {
			# Not logged-in
			return 0;
		} else {
			# Logged-in with MC2Wifi
			return 1;
		}
	} else {
		# Connected with other network
		return -1;
	}
}

# env_set_proxy() - Set the proxy to ENV
sub env_set_proxy {
	my $self = shift;

	my $proxy_host = '172.25.250.41';
	my $proxy_port = '8080';

	my $conf_env = $self->detect_proxy_conf_env();

	if($conf_env eq 'gsettings'){
		`gsettings set org.gnome.system.proxy mode \"manual\"`;
		`gsettings set org.gnome.system.proxy.http host \"$proxy_host\"`;
		`gsettings set org.gnome.system.proxy.http port \"$proxy_port\"`;
		`gsettings set org.gnome.system.proxy.https host \"$proxy_host\"`;
		`gsettings set org.gnome.system.proxy.https port \"$proxy_port\"`;
		`gsettings set org.gnome.system.proxy.ftp host \"$proxy_host\"`;
		`gsettings set org.gnome.system.proxy.ftp port \"$proxy_port\"`;
	} elsif ($conf_env eq 'gconftool-2'){
		my $confpath = '/home/'. getpwuid($>) . '/.gconf';
		`gconftool-2 --direct --config-source xml:readwrite:${confpath} --type string --set /system/proxy/mode \"manual\"`;
		`gconftool-2 --direct --config-source xml:readwrite:${confpath} --type string --set /system/http_proxy/host \"$proxy_host\"`;
		`gconftool-2 --direct --config-source xml:readwrite:${confpath} --type string --set /system/https_proxy/host \"$proxy_host\"`;
		`gconftool-2 --direct --config-source xml:readwrite:${confpath} --type string --set /system/ftp_proxy/host \"$proxy_host\"`;
		`gconftool-2 --direct --config-source xml:readwrite:${confpath} --type string --set /system/http_proxy/port \"$proxy_port\"`;
		`gconftool-2 --direct --config-source xml:readwrite:${confpath} --type string --set /system/https_proxy/port \"$proxy_port\"`;
		`gconftool-2 --direct --config-source xml:readwrite:${confpath} --type string --set /system/ftp_proxy/port \"$proxy_port\"`;
	}
}

# env_set_proxy() - Unset the proxy to ENV
sub env_unset_proxy {
	my $self = shift;

	my $proxy_host = '';
	my $proxy_port = '';

	my $conf_env = $self->detect_proxy_conf_env();

	if($conf_env eq 'gsettings'){
		`gsettings set org.gnome.system.proxy mode \"none\"`;
		#`gsettings set org.gnome.system.proxy.http host \"$proxy_host\"`;
		#`gsettings set org.gnome.system.proxy.http port \"$proxy_port\"`;
		#`gsettings set org.gnome.system.proxy.https host \"$proxy_host\"`;
		#`gsettings set org.gnome.system.proxy.https port \"$proxy_port\"`;
		#`gsettings set org.gnome.system.proxy.ftp host \"$proxy_host\"`;
		#`gsettings set org.gnome.system.proxy.ftp port \"$proxy_port\"`;
	} elsif ($conf_env eq 'gconftool-2'){
		my $confpath = '/home/'. getpwuid($>) . '/.gconf';
		`gconftool-2 --direct --config-source xml:readwrite:${confpath} --type string --set /system/proxy/mode \"none\"`;
		#`gconftool-2 --direct --config-source xml:readwrite:${confpath} --type string --set /system/http_proxy/host \"$proxy_host\"`;
		#`gconftool-2 --direct --config-source xml:readwrite:${confpath} --type string --set /system/https_proxy/host \"$proxy_host\"`;
		#`gconftool-2 --direct --config-source xml:readwrite:${confpath} --type string --set /system/ftp_proxy/host \"$proxy_host\"`;
		#`gconftool-2 --direct --config-source xml:readwrite:${confpath} --type string --set /system/http_proxy/port \"$proxy_port\"`;
		#`gconftool-2 --direct --config-source xml:readwrite:${confpath} --type string --set /system/https_proxy/port \"$proxy_port\"`;
		#`gconftool-2 --direct --config-source xml:readwrite:${confpath} --type string --set /system/ftp_proxy/port \"$proxy_port\"`;
	}
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

__END__
=head1 NAME

Net::OECU::LAN::MC2Wifi - Connect to OECUWifi network

=head1 SYNOPSIS

This module is only support for linux, in currently.
Also, this module provides switcher to set/unset the proxy for gnome-network.

  use Net::OECU::LAN::MC2Wifi;
  
  my $network = Net::OECU::LAN::MC2Wifi->new(
    'username' => 'ht11a000',
    'password' => 'hogepiyo',
  );
  
  if ($network->is_logged_in() == 0){ # Not logged-in
    # Login and set the proxy setting
    $network->login();
    $network->env_set_proxy();
  } elsif ($network->is_logged_in() == 1){ # Already logged-in
    # Set the proxy setting
    $network->env_set_proxy();
  } else { # Other network
    # Unset the proxy setting
    $network->env_unset_proxy();
  }

This project has just launched development (alpha released).

=head1 METHODS

=head2 new ( %params )

Create an instance of this module.

%params:

=over 4

=item * 'username' - Your MC2 user name

=item * 'password' - Your MC2 login password

=back

=head2 login ()

Login to OECUWifi network.

=head2 is_logged_in ()

=head2 env_set_proxy ()

=head2 env_unset_proxy ()

=head1 SEE ALSO

L<https://github.com/odentools/oden_wlan_perl> - Your feedback is very much appreciated.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 OdenTools Project (https://sites.google.com/site/odentools/), Masanori Ohgita (http://ohgita.info/).

This library is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License version 3 (GPL v3).

