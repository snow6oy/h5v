#!/usr/bin/perl
use lib ('/opt/git/h5v/perl', '/home/dishyzee/h5v/perl');
use H5V::Read;
use Data::Dumper;
print $0. "\n";
my $h5v=H5V::Read->new;

# expected: {error=>'blah'}
# search_fail
print Dumper $h5v->search;

# expected: {playlist}
# search_ok
my $pList=$h5v->search('evinha');
print Dumper $pList;
