#!/usr/bin/perl
use lib ('/opt/git/h5v/perl', '/home/dishyzee/h5v/perl');
use H5V::Read;
use H5V::Test;
use Data::Dumper;
my $t=H5V::Test->new($0);
my $h5v=H5V::Read->new;

# load_anyten
$t->set_after(Dumper $h5v->load_anyten);

print $t->cmp_before_after;
