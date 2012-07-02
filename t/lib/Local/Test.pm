package Local::Test;

use 5.010;
use Any::Moose;

sub live { return $_[1] }
sub die  { die $_[1] }

1;
