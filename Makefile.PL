use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
	VERSION		=> '1.1.0',
	NAME => 'oden_wlan_perl',
	DISTNAME => 'oden_wlan_perl',
	EXE_FILES => [
		'bin/odenwlan'
	],
	PM => {
		'lib/Net/OECU/LAN/Base.pm' => '$(INST_LIBDIR)/Net/OECU/LAN/Base.pm',
		'lib/Net/OECU/LAN/MC2Wifi.pm' => '$(INST_LIBDIR)/Net/OECU/LAN/MC2Wifi.pm'
	},
	test		=> {
		TESTS => 't/*.t'
	},
	PREREQ_PM	=> {
		'URI' => 1.60,
		'Net::SSLeay' => 1.55,
		'LWP::UserAgent' => 6.05, 
		'LWP::Protocol::https' => 6.04,
		'Data::Dumper' => 2.145,
		'YAML' => 0.85,
		'YAML::Syck' => 1.27,
		'Config::Pit' => 0.04,
	}
);
