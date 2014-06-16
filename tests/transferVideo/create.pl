#!/usr/bin/perl
# unit test
# create new metadata
use lib ('/opt/git/h5v/perl', '/home/dishyzee/h5v/perl');
use H5V::Read;
use H5V::Write;
use Data::Dumper;
my $h5v=H5V::Write->new;

$create=[{
  title=>"a small vehicle of lego",
  artist=>"boris",
  album=>"lego collection",
  rating=>"5",
  trackNumber=>"1",
  producer=>"lego.com",
  genre=>"country",
  source=>"http=>//h5v.fnarg.net/video/small.mp4"
}, {
  title=>"small by nature6oy",
  artist=>"",
  genre=>"Dance",
  album=>"",
  producer=>"",
  rating=>"-1",
  trackNumber=>"0",
  source=>"small.mp4",
  tw_id_str=>"449230816",
  tw_screen_name=>"nature6oy"
}];

print Dumper $create->[1]; 
my $rsp=$h5v->create($create->[1]);
unless($rsp){
  print 'ok'. "\n";
} else{
  print Dumper($rsp);
}
