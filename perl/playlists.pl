#!/usr/bin/perl
use Data::Dumper;
use JSON;
use H5V::Read;
use H5V::Write;
my $j=JSON->new;
my $h5v=H5V::Write->new;
my $message;
# check incoming content
# no more than 100 kilobytes of json. thanks!
if($ENV{CONTENT_LENGTH}<102400){
  read(STDIN, $message, $ENV{CONTENT_LENGTH});
  # testing, testing 1 2 3
  # print_response(200, $j->decode($message));
} else{
  show_error(400, "Bad Request", "Excessive content length");
}
unless($message){ # but >nada
  show_error(400, 'Bad Request', 'Zero length body');
}
# process incoming
if($ENV{REQUEST_METHOD} eq 'POST'){
  my $response=$h5v->create($j->decode($message));
  (exists($response->{error})) ? 
    show_error(500, 'Internal Server Error', $response->{error}) : 
    print_response(201, $response);
#  my $error=$h5v->create($j->decode($message));
#  ($error) ? show_error(500, $error) : print_response(201, {status=>201, messsage=>'Created'});
} elsif($ENV{REQUEST_METHOD} eq 'PUT'){
  my $error=$h5v->update_metadata($j->decode($message));
  ($error) ? 
    show_error(500, 'Internal Server Error', $error) : 
    print_response(200, {status=>200, title=>'OK', message=>'Update successful'});
} else{
  show_error(405, 'Method Not Allowed', $ENV{REQUEST_METHOD});
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
  my ($status, $title, $msg)=@_;
  print_response($status, {status=>$status, title=>$title, message=>$msg});
  exit;
}
sub show_error2{
  my ($status, $msg)=@_;
  my $errorMessage={uber=>{version=>'1.0', error=>{data=>[{id=>'status', status =>undef}, {id=>'message', message=>undef}]}}};
  $errorMessage->{uber}->{error}->{data}->[0]->{status}=$status;
  $errorMessage->{uber}->{error}->{data}->[1]->{message}=$msg;
  print_response($status, $errorMessage);
  exit;
}
