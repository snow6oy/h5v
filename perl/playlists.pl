#!/usr/bin/perl
use Data::Dumper;
use JSON;
use H5V::Read;
use H5V::Write;
my $url=$ENV{REQUEST_URI};  # example:'REQUEST_URI' => '/playlists/search?term=a',
# uber endpoint controls
my $listUrl='/playlists/';
my $filterUrl='/playlists/search';
my $errorMessage={uber=>{version=>'1.0', error=>{data=>[{id=>'status', status =>undef}, {id=>'message', message=>undef}]}}};
# dump_env();
# main
if($url eq $listUrl){
  if($ENV{REQUEST_METHOD} eq 'GET'){
    my $h5v=H5V::Read->new;
    my $response=$h5v->load_anyten();
    print_response(200, $response);
  }elsif($ENV{REQUEST_METHOD} eq 'PUT'){
    my $h5v=H5v::Write->new;
    my $message;
    # no more than 100 kilobytes of json. thanks!
    if($ENV{'CONTENT_LENGTH'}<102400){
      read(STDIN, $message, $ENV{'CONTENT_LENGTH'});
    }else{
      show_error(400, "Excessive content length");
    }
    unless($message){ # but >nada
      show_error(400, 'Zero length body');
    }
    my $j=JSON->new;
    my $response=$h5v->update_playlist($j->decode($message));
    (exists($response->{error}))?show_error(500, $response->{error}):print_response(200, $response);
  }else{
    show_error(405, 'Method not allowed'. $ENV{REQUEST_METHOD});
  }
}elsif($url=~m#^$filterUrl.*#){
  my $filter=$ENV{QUERY_STRING};  # term=a
  $filter=~s/^term=//;
  if($ENV{REQUEST_METHOD} eq 'GET'){
    my $hr=H5V::Read->new;
    my $pList=$hr->search($filter);
    print_response(200, $pList);    
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