#!/usr/bin/perl
# unit tests adding and updating metadata
######### expected ###############
# ok
# ok
# trackNumber:Not an integer for XMP-xmpDM:TrackNumber
# Error opening file
# Writing of WEBM files is not yet supported
use lib ('/opt/git/h5v/perl', '/home/dishyzee/h5v/perl');
use H5V::Write;
my $h5v=H5V::Write->new;
my $small_mp4='borisLegoCollection0003.mp4';
my $dizzy_mp4='evinhaOya0000.mp4';
my $dizzy_webm='anonDance0000.webm';

print $0. "\n";

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
    title=>'cat chasing a reflection',
    rating=>'1',
    trackNumber=>'0',
    genre=>'family',
  },
  {
    source=>$dizzy_webm,    
    title=>'cat chasing a reflection',
    rating=>undef,
    trackNumber=>'three'    
  },  
  {source=>'/x/y.z'}
];
foreach(@$updateMetadata){
  my $error=$h5v->update_metadata($_);
  my $output=($error)?"$error\n":"ok\n";
  print $output;
}
