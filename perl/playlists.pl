#!/usr/bin/perl
use Data::Dumper;
use JSON;
use H5V::Read;
my $url=$ENV{REQUEST_URI};  # example:'REQUEST_URI' => '/playlists/search?term=a',
# uber endpoint controls
my $listUrl='/playlists/';
my $filterUrl='/playlists/search';
my $errorMessage={uber=>{version=>'1.0', error=>{data=>[{id=>'status', status =>undef}, {id=>'message', message=>undef}]}}};
# dump_env();
# main
if($url eq $listUrl){
  if($ENV{REQUEST_METHOD} eq 'GET'){
    my $hr=H5V::Read->new;
    my $pList=$hr->load_anyten();
    print_response(200, $pList);
  }elsif($ENV{REQUEST_METHOD} eq 'PUT'){
    show_error(405, 'Method not allowed'. $ENV{REQUEST_METHOD});
  }else{
    show_error(405, 'Method not allowed'. $ENV{REQUEST_METHOD});
  }
}elsif($url=~m#^$filterUrl.*#){
  my $filter=$ENV{QUERY_STRING};  # term=a
  $filter=~s/^term=//;
  if($ENV{REQUEST_METHOD} eq 'GET'){
    my $hr=H5V::Read->new;
    my $pList=$hr->search($filter);
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
}
sub show_error{
  my ($status, $msg)=@_;
  $errorMessage->{uber}->{error}->{data}->[0]->{status}=$status;
  $errorMessage->{uber}->{error}->{data}->[1]->{message}=$msg;
  print_response($status, $errorMessage);
}
sub dump_env{
  print <<EOF;
Content-type: text/plain

EOF
  print Dumper \%ENV;
  exit;
}