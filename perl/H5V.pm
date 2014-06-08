package H5V;
# base package for Read and Write
use strict;
use Data::Dumper;
use File::Basename;
use constant CONF=>{
  SERVICE_URL=>'http://h5v.fnarg.net', # web root
  HOME_DIR=>'/opt/git/h5v'             # working dir
};
use constant TAGS=>qw(Title Producer Artist Rating Album Genre TrackNumber);

sub get_service_url{
  return CONF->{SERVICE_URL};
}
sub get_tags{
  return TAGS;
}
sub file_to_web{
  my ($self, $filename)=@_;
  my %webPath;
  $webPath{Source}=CONF->{SERVICE_URL}. "/video/$filename";
  my $imageFile=$filename;
  $imageFile=~s/\.(.+)$/.jpg/;
  $webPath{Caption}=CONF->{SERVICE_URL}. '/captions/';
  $webPath{Caption}.=(-f CONF->{HOME_DIR}. '/www/captions/'. $imageFile) ? $imageFile : 'video-placeholder.jpg';
  return \%webPath;
}
sub get_done_candidate{
  my ($self, $filename)=@_;
  my $doneDir=CONF->{HOME_DIR}. "/done";
  my $candidate=join '/', ($doneDir, $filename);
  return {doneDir=>$doneDir, candidate=>$candidate};
}
sub get_video_filenames{
  my $self=shift;
  my $videoDir=CONF->{HOME_DIR}. "/www/video";
  chdir $videoDir;
  my @files=<*.*>;
  chdir CONF->{HOME_DIR}. '/perl'; # otherwise 'use Blah' will fail
  return ($videoDir, \@files);
}
sub split_filename{
  my ($self, $filepath)=@_;
  my ($fn, $dir, $ext)=fileparse($filepath, '\.(avi|m4v|mp4|webm|3gp|ogv)');
  return {filename=>$fn, dir=>$dir, extn=>$ext};
}
sub get_done_filename{
  my $self=shift;
  my ($f, $wwwFile)=@_;
  my $isOk=0;
  my $symlink=CONF->{HOME_DIR}. '/done/'. $f->{filename}. $f->{ext};
  #print "$newFn\t$symlink\n";
  return $isOk if(! -f $wwwFile or -f $symlink); # file must exist, link must not
  return $symlink; # success
}
1;