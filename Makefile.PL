use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
	VERSION		=> '1.00',
	NAME => 'odenwlan',
	DISTNAME => 'oden_wlan_perl',
	EXE_FILES => [
		'odenwlan'
	],
	PM => [
		'lib/Net/OECU/LAN/Base.pm' => '$(INST_LIBDIR)/Net/OECU/LAN/Base.pm',
		'lib/Net/OECU/LAN/MC2Wifi.pm' => '$(INST_LIBDIR)/Net/OECU/LAN/MC2Wifi.pm'
	],
	test		=> {
		TESTS => 't/*.t'
	},
	PREREQ_PM	=> {
		'URI' => 0,
		'Net::SSLeay' => 0,
		'LWP::UserAgent' => 0,
		'LWP::Protocol::https' => 0,
		'Config::Pit' => 0,
		'Data::Dumper' => 0,
		'YAML' => 0,
	}
);
