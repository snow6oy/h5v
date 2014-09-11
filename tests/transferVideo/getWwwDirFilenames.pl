#!/usr/bin/perl
# unit test for listing video files as json
# expected: {file1=>1,file2=>3,file3=>1}
use lib ('/opt/git/h5v/perl', '/home/dishyzee/h5v/perl');
use H5V::Write;
use Data::Dumper;
print $0. "\n";
my $h5v=H5V::Write->new;
my $seen=$h5v->get_wwwdir_filenames;
print Dumper $seen;
