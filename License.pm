package Fedora::RPM::Spec::License;

use strict;
use warnings;

use Class::Utils qw(set_params);
use Error::Pure qw(err);
use License::SPDX;
use List::Util qw(none);
use Parse::RecDescent;
use Readonly;

my $GRAMMAR1 = <<'END';
	start: expression
	expression: and_expr 'or' expression {
		[$item[1], '||', $item[3]],
	} | and_expr
	and_expr: brack_expression 'and' and_expr {
		[$item[1], '&&', $item[3]],
	} | brack_expression
	brack_expression: '(' expression ')' {
		$item[2];
	} | identifier
	identifier: /([\w\s\.\+]+?)(?=(?:\s*and|\s*or|\(|\)|$))/ {
		$item[1];
	}
END
my $GRAMMAR2 = <<'END';
	start: expression
	expression: and_expr 'OR' expression {
		[$item[1], '||', $item[3]],
	} | and_expr
	and_expr: brack_expression 'AND' and_expr {
		[$item[1], '&&', $item[3]],
	} | brack_expression
	brack_expression: '(' expression ')' {
		$item[2];
	} | identifier
	identifier: /[\w\-\.]+/ {
		$item[1];
	}
END

our $VERSION = 0.01;

sub new {
	my ($class, @params) = @_;

	# Create object.
	my $self = bless {}, $class;

	# Process parameters.
	set_params($self, @params);

	$self->{'spdx'} = License::SPDX->new;

	$self->{'parser1'} = Parse::RecDescent->new($GRAMMAR1);
	$self->{'parser2'} = Parse::RecDescent->new($GRAMMAR2);

	return $self;
}

sub format {
	my $self = shift;

	if (! $self->{'result'}->{'status'}) {
		err 'No Fedora license string processed.';
	}

	return $self->{'result'}->{'format'};
}

sub licenses {
	my $self = shift;

	if (! $self->{'result'}->{'status'}) {
		err 'No Fedora license string processed.';
	}

	return sort @{$self->{'result'}->{'licenses'}};
}

sub parse {
	my ($self, $fedora_license_string) = @_;

	$self->_init;

	$self->{'result'}->{'input'} = $fedora_license_string;

	if ($fedora_license_string =~ m/AND/ms
		|| $fedora_license_string =~ m/OR/ms) {

		$self->{'result'}->{'format'} = 2;
		$self->_process_format_2($fedora_license_string);
	} elsif ($fedora_license_string =~ m/and/ms
		|| $fedora_license_string =~ m/or/ms) {

		$self->{'result'}->{'format'} = 1;
		$self->_process_format_1($fedora_license_string);
	} else {
		if ($self->{'spdx'}->check_license($fedora_license_string)) {
			$self->{'result'}->{'format'} = 2;
			$self->_process_format_2($fedora_license_string);
		} else {
			$self->{'result'}->{'format'} = 1;
			$self->_process_format_1($fedora_license_string);
		}
	}
	$self->{'result'}->{'status'} = 1;

	$self->_unique_licenses($self->{'result'}->{'res'});

	return;
}

sub reset {
	my $self = shift;

	$self->_init;

	return;
}

sub _init {
	my $self = shift;

	$self->{'result'} = {
		'format' => undef,
		'input' => undef,
		'licenses' => [],
		'status' => 0,
		'res' => undef,
	};

	return;
}

sub _process_format_1 {
	my ($self, $fedora_license_string) = @_;

	$self->{'result'}->{'res'} = $self->{'parser1'}->start($fedora_license_string);

	return;
}

sub _process_format_2 {
	my ($self, $fedora_license_string) = @_;

	$self->{'result'}->{'res'} = $self->{'parser2'}->start($fedora_license_string);

	return;
}

sub _unique_licenses {
	my ($self, $value) = @_;

	if (ref $value eq '') {
		if ($value ne '||' && $value ne '&&') {
			push @{$self->{'result'}->{'licenses'}}, $value;
		}
	} elsif (ref $value eq 'ARRAY') {
		foreach my $item (@{$value}) {
			$self->_unique_licenses($item);
		}
	}

	return;
}

1;
