package Object::Attribute::Cached;

our $VERSION = 0.92;

use strict;
use warnings;

=head1 NAME

Object::Attribute::Cached - cache complex object attributes

=head1 SYNOPSIS

	use Object::Attribute::Cached
		attribute1 => sub { shift->some_complex_task },
		squared => sub { shift->{num} ** 2 },
		uptosquare => sub { 1 .. shift->squared },
		squaredsquared => sub { map $_ ** 2, shift->uptosquare };

=head1 DESCRIPTION

This provides a simple interface to writing simple caching attribute methods.

It avoids having to write code like:

	sub parsed_query { 
		my $self = shift;
		$self->{_cached_parsed_query} ||= $self->parse_the_query;
		return $self->{_cached_parsed_query};
	}

Instead you can just declare:

	use Object::Attribute::Cached
		parsed_query => sub { shift->parse_the_query };


It's nothing fancy, and it might get confused if you've context-specific
code lurking in there as it attempts to cope with these attributes being
able to be lists and hashes, but it's Good Enough for most of what I need.

=cut

sub import {
  my ($self, @pairs) = @_;
  no strict 'refs';
  my $caller = caller();
  while (my ($method, $code) = splice (@pairs, 0,2)) {
    my $cache = "__cache_$method";
    *{"$caller\::$method"} = sub {
      my $self = shift;
      $self->{$cache} ||= [ $code->($self, @_) ];
      return @{ $self->{$cache} } if wantarray;
			return $self->{$cache}->[0];
    };
  };
}

=head1 AUTHOR

Tony Bowden, E<lt>kasei@tmtm.comE<gt>.

=head1 COPYRIGHT

Copyright (C) 2003 Kasei. All rights reserved.

This module is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

