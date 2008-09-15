use strict;
use warnings;

use Test::More tests => 2;

diag( "Testing CPANPLUS::Dist::RPM $CPANPLUS::Dist::RPM::VERSION" );
# TEST
use_ok('CPANPLUS::Dist::RPM');

diag( "Testing CPANPLUS::Dist::Fedora $CPANPLUS::Dist::Fedora::VERSION" );
# TEST
use_ok('CPANPLUS::Dist::Fedora');

