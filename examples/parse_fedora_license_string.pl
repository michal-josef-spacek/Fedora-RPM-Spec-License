#!/usr/bin/env perl

use strict;
use warnings;

use Fedora::RPM::Spec::License;

if (@ARGV < 1) {
        print STDERR "Usage: $0 fedora_license_string\n";
        exit 1;
}
my $fedora_license_string = $ARGV[0];

# Object.
my $obj = Fedora::RPM::Spec::License->new;

# Parse license.
$obj->parse($fedora_license_string);

# Print out.
print "Fedora license string: $fedora_license_string\n";
print 'Format: '.$obj->format."\n";
print "Contain licenses:\n";
print join "\n", map { '- '. $_ } $obj->licenses;

# Output with 'MIT' input:
# Fedora license string: MIT
# Format: 2
# Contain licenses:
# - MIT