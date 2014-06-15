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
# @calledBy Read::read_video_dir Read::search
sub get_tags{
  return TAGS;
}
# @calledBy Read::load_anyten Read::search
sub file_to_web{
  my ($self, $filename)=@_;
  my %webPath;
  $webPath{Source}=CONF->{SERVICE_URL}. "/videos/$filename";
  my $imageFile=$filename;
  $imageFile=~s/\.(.+)$/.jpg/;
  $webPath{Caption}=CONF->{SERVICE_URL}. '/captions/';
  $webPath{Caption}.=(-f CONF->{HOME_DIR}. '/www/captions/'. $imageFile) ? $imageFile : 'video-placeholder.jpg';
  return \%webPath;
}
# @request
#   http://example.com/y/z.ogv
# @response
#   {fn=>z,dir=>/x/y,extn=>ogv}
# @calledBy Write::update_metadata
sub web_to_file{
  my ($self, $webPath)=@_;
  my $serviceUrl=CONF->{SERVICE_URL}; # better way to use a constant in a regex?
  $webPath=~s/$serviceUrl//;
  my $splitFn=$self->split_filename($webPath);
  $splitFn->{dir}=CONF->{HOME_DIR}. '/www/videos';
  return $splitFn;
}
# @request
#   {fn=>z,dir=>/x/y,extn=>ogv}
# @response
#   {dir=>/x/y/done, filename=>/x/y/done/z.ogv} 
# @calledBy Read::check_if_done
sub get_done_candidate{
  my ($self, $splitFn)=@_;
  my $doneDir=CONF->{HOME_DIR}. "/done";
  my $candidate=join '/', ($doneDir, $splitFn->{filename}. $splitFn->{extn});
  return {dir=>$doneDir, filename=>$candidate};
}  
# @calledBy Read::read_video_dir Write::get_wwwdir_filenames
sub get_video_filenames{
  my $self=shift;
  my $videoDir=CONF->{HOME_DIR}. "/www/videos";
  chdir $videoDir;
  my @files=<*.mp4>;
  chdir CONF->{HOME_DIR}. '/perl'; # otherwise 'use Blah' will fail
  return {name=>$videoDir, files=>\@files};
}
# @request
#   /x/y/z.ogv
# @response
#   {fn=>z,dir=>/x/y,extn=>ogv}
# @calledBy Write::new_filename
sub split_filename{
  my ($self, $filepath)=@_;
  my ($fn, $dir, $ext)=fileparse($filepath, '\.(avi|m4v|mp4|webm|3gp|ogv)');
  return {filename=>$fn, dir=>$dir, extn=>$ext};
}
# @request
#   {fn=>z,dir=>/x/y,extn=>ogv}
# @response
#   /x/y/done/z.ogv
# @calledBy Write::mark_as_done
sub get_done_filename{
  my ($self, $f)=@_;
  return CONF->{HOME_DIR}. '/done/'. $f->{filename}. $f->{extn};
}
sub get_incoming_filename{
  my ($self, $f)=@_;
  return CONF->{HOME_DIR}. '/incoming/'. $f->{filename}. $f->{extn};
}
1;