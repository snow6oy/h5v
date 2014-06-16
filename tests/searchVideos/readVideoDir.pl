#!/usr/bin/perl
use lib ('/opt/git/h5v/perl', '/home/dishyzee/h5v/perl');
use H5V::Read;
use Data::Dumper;
print $0. "\n";
my $h5v=H5V::Read->new;

# read_video_dir
### expected: [{file1=>mdat}, {file2=>mdat} .. ]
my $found=$h5v->read_video_dir;
print Dumper $found;
