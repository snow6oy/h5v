#!/usr/bin/perl
# unit test for listing video files as json
# expected: {file1=>1,file2=>3,file3=>1}
use lib ('/opt/git/h5v/perl', '/home/dishyzee/h5v/perl');
use H5V::Write;
use H5V::Test;
use Data::Dumper;

my $h5v=H5V::Write->new;
my $ht=H5V::Test->new($0);

my $seen=Dumper($h5v->get_wwwdir_filenames);

$ht->set_after($seen);

print $ht->cmp_before_after;
