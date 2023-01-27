use strict;
use warnings;

use Fedora::RPM::Spec::License;
use Test::More 'tests' => 3;
use Test::NoWarnings;

# Test.
my $obj = Fedora::RPM::Spec::License->new;
my $ret = $obj->parse('MIT');
is($ret, undef, 'Successful parse (MIT).');

# Test.
$obj = Fedora::RPM::Spec::License->new;
$ret = $obj->parse('BAD');
is($ret, undef, 'Successful parse (BAD).');
