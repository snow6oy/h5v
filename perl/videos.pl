#!/usr/bin/perl
use strict;
use Data::Dumper;
use H5V::Read;
use CGI qw/:standard/;
use CGI::Cookie;
my %cookies=CGI::Cookie->fetch;           # fetch existing cookies
my $cdmp=Dumper(\%cookies);
my $h5v=H5V::Read->new;                   # setup interface to stored video
my $base_dir=$h5v->conf('BASE_DIR');
my $fn=$ENV{PATH_INFO};                   # incoming video filename
   $fn=~s#^/##;                           # strip leading slash
my $file=$base_dir. '/videos/'. $fn;
my $mdat=$h5v->read_metadata($fn);        # tested with 'evinhaOya0001.mp4'
my $user=$mdat->{EndUserName};
my $id=$mdat->{EndUserID};
my ($len, $error, $dzid);
if(exists($cookies{'dzid'})){
  $dzid=$cookies{'dzid'}->value;
}
if(!$dzid || $dzid!=$id){                 # auth error
  $error=401;
}
if(-r $file){                             # not found error
  $len=(stat($file))[10];
} else{
  $error=404;
}
if($error){
print <<ERR;
Content-type: text/plain
Status: $error

$error
---
$base_dir
$fn
$user
$dzid
$id

$cdmp
ERR

} else{

print <<OK;
Content-type: video/mp4
Content-length: $len

OK
  my $buffer;
  binmode STDOUT;
  open (FH, '<', $file);
  while (read(FH, $buffer, 10240)) {
    print $buffer;
  }
  close FH;
}
