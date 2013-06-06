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
	
	die;
}

# login() - Login to Wlannet
sub login {
	my $self = shift;
}

# logout() - Logout from Wlannet
sub logout {
	my $self = shift;
}

# is_logged_in() - Check currently logged-in. Return: 1 = true, 0 = false
sub is_logged_in {
	my $self = shift;
}

# env_set_proxy() - Set the proxy to ENV
sub env_set_proxy {
	my $self = shift;
}

# env_set_proxy() - Unset the proxy to ENV
sub env_unset_proxy {
	my $self = shift;
}

# Detect proxy configuration environment on this computer
sub detect_proxy_conf_env {
	my $self = shift;
	my $conf_env = "gsettings";
	eval {
		`gsettings help`;
	}; if($@){ 
		$conf_env = "gconftool-2";
	};
	return $conf_env;
}

# _ua_set_proxy
sub _ua_set_proxy {
	my $self = shift;
}

# _ua_unset_proxy
sub _ua_unset_proxy {
	my $self = shift;
}

1;
