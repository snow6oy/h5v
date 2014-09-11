#!/usr/bin/perl
use Data::Dumper;
use JSON;
use H5V::Read;
use H5V::Write;
my $h5v=H5V::Read->new;
my $j=JSON->new;
my $filter=$ENV{QUERY_STRING};  # term=a
$filter=~s/^term=//;
if($filter and $ENV{REQUEST_METHOD} eq 'GET'){
  my $pList=$h5v->search($filter);
  if(scalar(@$pList)){
    # watch-out for side-effect of this test. pList changes from [] to [{}] 
    if (exists($pList->[0]->{error})){  
      show_error(400, $pList->[0]->{error});
    }else{
      print_response(200, $pList);
      #print_response(200, $h5v->send_uber_list($pList));
    }
  }else{
    print_response(200, $pList);
  }
}elsif($ENV{REQUEST_METHOD} eq 'GET'){
  my $pList=$h5v->load_anyten();
  print_response(200, $pList);
}else{
  show_error(405, 'Method not allowed');
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
  my ($status, $title)=@_;
  print_response($status, {status=>$status, title=>$title});
  exit;
}