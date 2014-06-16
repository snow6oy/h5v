#!/usr/bin/perl
# unit tests adding and updating metadata
use lib ('/opt/git/h5v/perl', '/home/dishyzee/h5v/perl');
use H5V::Write;
use H5V::Test;
my $h5v=H5V::Write->new;
my $t=H5V::Test->new($0);
my $small_mp4='borisLegoCollection0003.mp4';
my $dizzy_mp4='evinhaOya0000.mp4';
my $dizzy_webm='anonDance0000.webm'; # Writing of WEBM files is not yet supported

$updateMetadata=[
  {
    source=>$small_mp4,
    title=>'a small vehicle of lego',
    artist=>'tank man',
    album=>'lego collection',
    rating=>'2',
    trackNumber=>'4',
    producer=>'lego.com',
    genre=>'family',
  },
  {
    source=>$dizzy_mp4,
    title=>'Evinha make pop action',
    rating=>'1',
    trackNumber=>'0',
    genre=>'Latin',
    tw_id_str=>"449230816",
    tw_screen_name=>"nature6oy"
  },
  {
    source=>$dizzy_webm,    
    title=>'cat chasing a reflection',
    rating=>undef,             # rating must be an integer
    trackNumber=>'three'
  },  
  {source=>'/x/y.z'}
];
foreach(@$updateMetadata){
  my $error=$h5v->update_metadata($_);
  my $output=($error)?"$error\n":"ok\n";
  $t->set_after($output);
}

print $t->cmp_before_after;
