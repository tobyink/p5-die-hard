use strict;
use lib "lib";
use lib "t/lib";

use Test::More tests => 10;
use Test::Exception;

use Die::Hard;
use Local::Test;
my $obj     = Local::Test->new;
my $maclane = Die::Hard->new($obj);

isa_ok $maclane => 'Die::Hard';
isa_ok $maclane => 'Local::Test';
ok !$maclane->isa('Terrorist'), "John Maclane ain't no terrorist!";
can_ok $maclane => qw(isa can DOES VERSION new live die);

lives_and {
	is $obj->live("Foo"), "Foo";
} '$obj->live method returns properly';

lives_and {
	is $maclane->live("Foo"), "Foo";
} '$maclane->live method returns properly';

is $maclane->last_error, '', 'last_error contains no error';

dies_ok {
	$obj->die("Bar");
} '$obj->die method dies';

lives_and {
	is $maclane->die("Bar"), undef;
} '$maclane->die method lives!';

like $maclane->last_error, qr(^Bar), 'last_error contains last error';

