#!/usr/bin/perl
use lib ('/opt/git/h5v/perl', '/home/dishyzee/h5v/perl');
use H5V::Read;
use H5V::Test;
use Data::Dumper;
my $t=H5V::Test->new($0);
my $h5v=H5V::Read->new;

# read_video_dir
### expected: [{file1=>mdat}, {file2=>mdat} .. ]
my $found=$h5v->read_video_dir;
$t->set_after(Dumper $found);

print $t->cmp_before_after;
