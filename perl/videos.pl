#!/usr/bin/perl
my $file='/opt/git/h5v/videos/'. $ENV{PATH_INFO};
if(-r $file){
  my $length = (stat($file))[10];
print <<OK;
Content-type: $contentType
Content-length: $length

OK
  my $buffer;
  binmode STDOUT;
  open (FH, '<', $file);
  while (read(FH, $buffer, 10240)) {
    print $buffer;
  }
  close FH;
} else{
print <<NOTFOUND;
Content-type: text/plain
Status: 404

404 $file
NOTFOUND