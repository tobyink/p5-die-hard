package Die::Hard;

use 5.010;
use Any::Moose;
use utf8;

BEGIN {
	no warnings;
	$Die::Hard::AUTHORITY = 'cpan:TOBYINK';
	$Die::Hard::VERSION   = '0.001';
}

has proxy_for => (
	is       => 'ro',
	isa      => 'Object',
	required => 1,
);

has last_error => (
	is       => 'ro',
	isa      => 'Any',
	required => 0,
	writer   => '_set_last_error',
);

sub BUILDARGS
{
	my $class = shift;
	return +{ proxy_for => $_[0] } if @_ == 1 && blessed($_[0]);
	return $class->SUPER::BUILDARGS(@_);
}

our $AUTOLOAD;

foreach my $meth (qw( isa DOES can VERSION ))
{
	no strict 'refs';
	*{$meth} = sub
	{
		my $invocant = shift;
		if (blessed $invocant and wantarray)
		{
			my @r = eval { $invocant->proxy_for->$meth(@_) };
			return @r if @r;
		}
		elsif (blessed $invocant)
		{
			my $r = eval { $invocant->proxy_for->$meth(@_) };
			return $r if $r;
		}
		my $supermeth = join '::' => 'UNIVERSAL', $meth;
		return $invocant->$supermeth(@_);
	}
}

sub AUTOLOAD
{
	my ($meth) = ($AUTOLOAD =~ /::([^:]+)$/);
	
	local $@ = undef;
	my $self = shift;
	if (wantarray)
	{
		my @r = eval { $self->proxy_for->$meth(@_) };
		$self->_set_last_error($@);
		return @r if @r;
	}
	else
	{
		my $r = eval { $self->proxy_for->$meth(@_) };
		$self->_set_last_error($@);
		return $r if defined $r;
	}
	
	return;
}

1
__END__

=head1 NAME

Die::Hard - objects as resistant to dying as John Maclane

=head1 SYNOPSIS

 my $fragile = Fragile::Object->new;
 my $diehard = Die::Hard->new($fragile);
 
 $diehard->isa('Fragile::Object'); # true
 $diehard->method_that_will_die;   # lives!
 $fragile->method_that_will_die;   # dies!

=head1 DESCRIPTION

Die::Hard allows you to create fairly transparent wrapper object that
delegates all method calls through to the wrapped object, but does so
within an C<< eval { ... } >> block. If the wrapped method call dies,
then it sets a C<< last_error >> attribute.

=head2 Constructor

=over

=item C<< new(%attributes) >>

Standard Moose-style constructor.

=item C<< new($object) >>

Shortcut for setting the C<proxy_for> attribute.

=back

=head2 Attributes

=over

=item C<< proxy_for >>

The object being wrapped. Read-only; required.

=item C<< last_error >>

If the last proxied method call died, then this attribute will contain
the error. Otherwise will be false (undef or empty string).

=back

=begin private

=item AUTOLOAD

=item BUILDARGS

=item can

=item DOES

=item isa

=item VERSION

=end private

=head1 BUGS

Please report any bugs to
L<http://rt.cpan.org/Dist/Display.html?Queue=Die-Hard>.

=head1 SEE ALSO

L<No::Die>.

=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2012 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=head1 DISCLAIMER OF WARRANTIES

THIS PACKAGE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF
MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.

