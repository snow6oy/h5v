#!/usr/bin/perl
# unit test
# create new metadata
use lib ('/opt/git/h5v/perl', '/home/dishyzee/h5v/perl');
use H5V::Read;
use H5V::Write;
use H5V::Test;
use Data::Dumper;
my $h5v=H5V::Write->new;
my $t=H5V::Test->new($0);
# test data
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
}, {
  "Title"=>"new video added today",
  "Artist"=>"evinha",
  "Genre"=>"Latin",
  "Album"=>"Oya",
  "TrackNumber"=>"3",
  "Producer"=>"",
  "Rating"=>"1",
  "Permissions"=>"0",
  "source"=>"wSJ8H6.mp4"
}];

my $json=$h5v->create($create->[2]);
$t->set_after(Dumper($json));
print $t->cmp_before_after;

# delete what was created
# $VAR1 = { 'location' => 'http://rudy.local/videos/evinhaOya0003.mp4', 'status' => 201 };
my $fn=$t->web_to_file($json->{location});

unlink $fn->{dir}. '/'. $fn->{filename}. $fn->{extn};
