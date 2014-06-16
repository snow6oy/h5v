#!/usr/bin/perl
# unit tests adding and updating metadata
use lib ('/opt/git/h5v/perl', '/home/dishyzee/h5v/perl');
use H5V::Read;
use H5V::Test;
use Data::Dumper;
# use File::Compare;
my $h5v=H5V::Read->new;
my $ht=H5V::Test->new($0);
my @mp4sToTest=('borisLegoCollection0003.mp4', 'evinhaOya0000.mp4', 'anonDance0000.webm');

foreach (@mp4sToTest){
  $ht->set_after(Dumper($h5v->read_metadata($_)));
}
print $ht->cmp_before_after;
