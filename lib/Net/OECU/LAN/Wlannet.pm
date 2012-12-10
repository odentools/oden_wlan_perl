package Net::OECU::LAN::Wlannet;
#############################################
# OECU LAN connection module for Wlannet
# (C) OdenTools Project - 2012.
#############################################

use LWP::UserAgent;

sub new {
	my ($class, %hash) = @_;
	my $self = bless({}, $class);
	
	$self->{username} = $hash{username} || die('Not specified username.');
	$self->{password} = $hash{password} || die('Not specified password.');
	
	$self->{ua} = LWP::UserAgent->new;
	$self->{ua}->timeout(10);
	
	$ENV{HTTPS_CA_FILE} = '.webauth.it.osakac.ac.jp_chain.cert';
	
	return $self;
}

# login() - Login to Wlannet
sub login {
	my $self = shift;
	
	my $response = $self->{ua}->post('https://192.168.4.252/login.html',
		'username' => $self->{username},
		'password' => $self->{password},
		'buttonClicked' => 4,
		'redirect_url' => 'http://www.mc2.osakac.ac.jp/',
	);
	
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

# isLogined() - Check currently logged-in
sub isLogined {
	my $self = shift;
	my $response = $self->{ua}->get('https://192.168.4.252/logout.html');
	
	if ($response->is_success) {
		print $response->decoded_content;
		return 1;		
        }
	die $response->as_string;
}

1;
