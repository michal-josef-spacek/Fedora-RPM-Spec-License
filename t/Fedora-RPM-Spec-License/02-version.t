use strict;
use warnings;

use Fedora::RPM::Spec::License;
use Test::More 'tests' => 2;
use Test::NoWarnings;

# Test.
is($Fedora::RPM::Spec::License::VERSION, 0.04, 'Version.');
