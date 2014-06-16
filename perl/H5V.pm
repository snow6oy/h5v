package H5V;
# base package for Read and Write
# /opt/git/h5v
# /opt/git/h5v/www
# /opt/git/h5v/videos/:id
# /opt/git/h5v/captions/:id
# /opt/git/h5v/incoming
# /opt/git/h5v/done
# /opt/git/h5v/perl
use strict;
use Data::Dumper;
use File::Basename;
use constant CONF=>{
  SERVICE_URL=>'http://rudy.local', # web root
  BASE_DIR=>'/opt/git/h5v'          # working dir
#  SERVICE_URL=>'http://dishyzee.com',
#  BASE_DIR=>'/home/dishyzee/h5v'
};
# note exif names are Proper Case but H5V names are lowercase
use constant TAGS=>qw(
  Title Producer Artist Rating Album Genre TrackNumber Permissions EndUserID EndUserName
);
# @calledBy Read::read_video_dir Read::search
sub get_tags{
  return TAGS;
}
# @calledBy Read::load_anyten Read::search Write::create
sub file_to_web{
  my ($self, $filename)=@_;
  my %webPath;
  $webPath{source}=CONF->{SERVICE_URL}. "/videos/$filename";
  my $imageFile=$filename;
  $imageFile=~s/\.(.+)$/.png/;
  $webPath{caption}=CONF->{SERVICE_URL}. '/captions/';
  $webPath{caption}.=(-f CONF->{BASE_DIR}. '/www/captions/'. $imageFile) ? $imageFile : 'video-placeholder.png';
  return \%webPath;
}
# @request
#   http://example.com/y/z.ogv
# @response
# {'filename' => 'small', 'extn' => '.mp4', 'dir' => '/opt/git/h5v/videos'}
# @calledBy Write::update_metadata Write::create
sub web_to_file{
  my ($self, $webPath)=@_;
  my $serviceUrl=CONF->{SERVICE_URL}; # better way to use a constant in a regex?
  $webPath=~s/$serviceUrl//;
  my $splitFn=$self->split_filename($webPath);
  $splitFn->{dir}=CONF->{BASE_DIR}. '/videos';
  return $splitFn;
}
# @request
#   {fn=>z,dir=>/x/y,extn=>ogv}
# @response
#   {dir=>/x/y/done, filename=>/x/y/done/z.ogv} 
# @calledBy Read::check_if_done
sub get_done_candidate{
  my ($self, $splitFn)=@_;
  my $doneDir=CONF->{BASE_DIR}. "/done";
  my $candidate=join '/', ($doneDir, $splitFn->{filename}. $splitFn->{extn});
  return {dir=>$doneDir, filename=>$candidate};
}  
# @calledBy Read::read_video_dir Write::get_wwwdir_filenames
sub get_video_filenames{
  my $self=shift;
  my $videoDir=CONF->{BASE_DIR}. "/videos";
  chdir $videoDir;
  my @files=<*.mp4>;
  chdir CONF->{BASE_DIR}. '/perl'; # otherwise 'use Blah' will fail
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
sub get_incoming_filename{
  my ($self, $f)=@_;
  return CONF->{BASE_DIR}. '/incoming/'. $f->{filename}. $f->{extn};
}
# @request
#   {fn=>z,dir=>/x/y,extn=>ogv}
# @response
#   /x/y/done/z.ogv
# @calledBy Write::mark_as_done
#sub get_done_filename{
#  my ($self, $f)=@_;
#  return CONF->{BASE_DIR}. '/done/'. $f->{filename}. $f->{extn};
#}
1;
