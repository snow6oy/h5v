#!/usr/bin/perl
# unit tests adding and updating metadata
use lib ('/opt/git/h5v/perl', '/home/dishyzee/h5v/perl');
use H5V::Read;
use Data::Dumper;
use File::Compare;

my $h5v=H5V::Read->new;
my @mp4sToTest=('borisLegoCollection0003.mp4', 'evinhaOya0000.mp4', 'anonDance0000.webm');

my $tmp=$0;
$tmp=~s/\.pl$/.txt/;
$rsp=$tmp;
$tmp=~s#\.#/tmp#;
unlink $tmp; # clear up from previous run


open(RESPONSE, ">>$tmp");
foreach (@mp4sToTest){
  print RESPONSE Dumper($h5v->read_metadata($_));
}
close RESPONSE;


$result=(compare($tmp, $rsp)==0) ? "Ok" : "FAIL" ;
print $result. "\n";

######### expected ###############
#{'EndUserName'=>'','Album'=>'Oya','EndUserID'=>'','Genre'=>'Latin','TrackNumber'=>'1','Rating'=>'4','Artist'=>'evinha','Title'=>'newtemplate','Producer'=>'','Permissions'=>'2'};
#{'EndUserName'=>'','Album'=>'Oya','EndUserID'=>'','Genre'=>'family','TrackNumber'=>'0','Rating'=>'1','Artist'=>'evinha','Title'=>'catchasingareflection','Producer'=>'','Permissions'=>'0'};
#{ 'error' => 'Error opening file' };

