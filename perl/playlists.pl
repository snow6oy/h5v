#!/usr/bin/perl
use Data::Dumper;
use JSON;
use H5V::Read;
use constant CONF=>{
  DOC_ROOT=>'/opt/git/h5v/video/',    # media source. provided at runtime as ->new(/path/to/video)
};
my $url=$ENV{REQUEST_URI};
# uber error control
my $listUrl='/playlists/';
my $filterUrl='/playlists/search';
my $errorMessage={uber=>{version=>'1.0', error=>{data=>[{id=>'status', status =>undef}, {id=>'message', message=>undef}]}}};
# main
if ($url eq $listUrl){
  if ($ENV{'REQUEST_METHOD'} eq 'GET'){
    my $hr=H5V::Read->new(CONF->{DOC_ROOT});
    my $pList=$hr->load_anyten();
    print_response(200, $pList);
  }elsif ($ENV{'REQUEST_METHOD'} eq 'PUT'){
    show_error(405, 'Method not allowed'. $ENV{REQUEST_METHOD});
  }else{
    show_error(405, 'Method not allowed'. $ENV{REQUEST_METHOD});
  }
}elsif ($url eq $filterUrl){
  if ($ENV{'REQUEST_METHOD'} eq 'GET'){
    #searchList();
    show_error(405, 'Method not allowed');
  }else{
    show_error(405, 'Method not allowed');
  }
}else{
  show_error(404, 'Page not found');
}
sub print_response {
  my ($statusCode, $body)=@_;
  my $j=JSON->new;
  my $json=$j->pretty->encode($body);
print <<EOF;
Content-type: application/json
Status: $statusCode

$json
EOF
# print Dumper \%ENV;
}
sub show_error {
  my ($status, $msg)=@_;
  $errorMessage->{uber}->{error}->{data}->[0]->{status}=$status;
  $errorMessage->{uber}->{error}->{data}->[1]->{message}=$msg;
  print_response($status, $errorMessage);
}