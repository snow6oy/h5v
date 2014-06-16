#!/usr/bin/perl
use lib ('/opt/git/h5v/perl', '/home/dishyzee/h5v/perl');
use H5V::Read;
use Data::Dumper;
print $0. "\n";
my $h5v=H5V::Read->new;

# load_anyten
print Dumper $h5v->load_anyten;
