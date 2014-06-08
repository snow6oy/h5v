#!/usr/bin/perl
# unit tests for Read and Write functions
# manually
use H5V::Read;
use H5V::Write;
use Data::Dumper;
require 'test_data.pl';
our($updateMetadata, $putMetadata);
print $0. "\n";
my $h5v=H5V::Read->new;
&search_ok;
&search_fail;
#&read_video_dir;
#&load_anyten;

#my $h5v=H5V::Write->new;
#&get_wwwdir_filenames_ok;
#&updateMetadata;
#&put_metadata;

sub load_anyten{
  print Dumper $h5v->load_anyten;
}
sub put_metadata{
  my $error=$h5v->update_metadata($_);
  my $output=($error)?"$error\n":"ok\n";
  print $output;
}
# expected: 
# ok
# ok
# trackNumber:Not an integer for XMP-xmpDM:TrackNumber
# Error opening file
# Writing of WEBM files is not yet supported
sub update_metadata{
  foreach(@$updateMetadata){
    my $error=$h5v->update_metadata($_);
    my $output=($error)?"$error\n":"ok\n";
    print $output;
  }
}
# expected: {file1=>1,file2=>3,file3=>1}
sub get_wwwdir_filenames_ok{
  my $seen=$h5v->get_wwwdir_filenames;
  print Dumper $seen;
}
# expected: {error=>'blah'}
sub search_fail{
  print Dumper $h5v->search;
}
# expected: {playlist}
sub search_ok{
  my $pList=$h5v->search('wibble');
  print Dumper $pList;
}
# expected: [{file1=>mdat}, {file2=>mdat} .. ]
sub read_video_dir{
  my $found=$h5v->read_video_dir;
  print Dumper $found;
}