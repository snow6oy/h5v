#!/usr/bin/perl
use lib ('/opt/git/h5v/perl', '/home/dishyzee/h5v/perl');
use H5V::Read;
use H5V::Test;
use Data::Dumper;
my $h5v=H5V::Read->new;
my $t=H5V::Test->new($0);

# expected: {error=>'blah'}
# search_fail
$t->set_after(Dumper $h5v->search);

# expected: {playlist}
# search_ok
my $pList=$h5v->search('evinha');
$t->set_after(Dumper $pList);

print $t->cmp_before_after;
