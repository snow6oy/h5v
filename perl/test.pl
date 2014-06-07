#!/usr/bin/perl
# unit tests for Read functions
use H5V::Read;
use Data::Dumper;
my $hr=H5V::Read->new;
print $0. "\n";
&search_ok;
#&search_fail;
#&read_video_dir;

sub search_fail{
  # expected: {error=>'blah'}
  print Dumper $hr->search;
}
sub search_ok{
  my $pList=$hr->search('wibble');
  print Dumper $pList;
}
sub read_video_dir{
  my $found=$hr->read_video_dir;
  print Dumper $found;
}