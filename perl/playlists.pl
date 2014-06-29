#!/usr/bin/perl
use Data::Dumper;
use JSON;
use H5V::Read;
use H5V::Write;
my $j=JSON->new;
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
    my $pList=$h5v->load_anyten();
    print_response(200, $h5v->send_uber_list($pList));
  }elsif($ENV{REQUEST_METHOD} eq 'PUT' or $ENV{REQUEST_METHOD} eq 'POST'){
    my $h5v=H5V::Write->new;
    my $message;
    # no more than 100 kilobytes of json. thanks!
    if($ENV{CONTENT_LENGTH}<102400){
      read(STDIN, $message, $ENV{CONTENT_LENGTH});
      # testing, testing 1 2 3
      # print_response(200, $j->decode($message));
    }else{
      show_error(400, "Excessive content length");
    }
    unless($message){ # but >nada
      show_error(400, 'Zero length body');
    }elsif($ENV{REQUEST_METHOD} eq 'POST'){
      my $error=$h5v->create($j->decode($message));
      ($error) ? show_error(500, $error) : print_response(201, {status=>'Created'});
    }elsif($ENV{REQUEST_METHOD} eq 'PUT'){
      my $error=$h5v->update_metadata($j->decode($message));
      ($error) ? show_error(500, $error) : print_response(200, {status=>'Success'});      
    }
  }else{
    show_error(405, $ENV{REQUEST_METHOD}. ' method not allowed');
  }
}elsif($url=~m#^$filterUrl.*#){
  my $filter=$ENV{QUERY_STRING};  # term=a
  $filter=~s/^term=//;
  if($ENV{REQUEST_METHOD} eq 'GET'){
    my $h5v=H5V::Read->new;
    my $pList=$h5v->search($filter);
    if(scalar(@$pList)){
      # watch-out for side-effect of this test. pList changes from [] to [{}] 
      if (exists($pList->[0]->{error})){  
        show_error(400, $pList->[0]->{error});
      }else{
        print_response(200, $h5v->send_uber_list($pList));
      }
    }else{
      print_response(200, $h5v->send_uber_list($pList));
    }
  }else{
    show_error(405, 'Method not allowed');
  }
}else{
  show_error(404, 'Page not found');
}
sub print_response {
  my ($statusCode, $body)=@_;
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
