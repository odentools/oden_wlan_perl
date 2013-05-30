use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
	VERSION		=> '0.01',
	test		=> {
		TESTS => 't/*.t'
	},
	PREREQ_PM	=> {
		'URI' => 0,
		'Net::SSLeay' => 0,
		'LWP::UserAgent' => 0,
		'LWP::Protocol::https' => 0,
		'Data::Dumper' => 0,
	}
);
