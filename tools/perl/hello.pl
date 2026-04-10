use 5.40.1;
use strict;
use warnings;

my $name = $ARGV[0] || $ENV{'NAME'} || "entity without a name!";

say "Hello, $name.";
