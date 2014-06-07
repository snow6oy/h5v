package H5V::Write;
use strict;
use Data::Dumper;
use File::Basename;
use Image::ExifTool;
#use constant CONF=>{
#  SERVICE_URL=>'http://h5v.fnarg.net', # web root
#  HOME_DIR=>'/opt/git/h5v'             # working dir
#};
use constant CONF=>{
  DOC_ROOT=>'/home/gavin/zz/m4v/',    # media source. provided at runtime as ZzMeta->new(/path/to/video)
  DONE_DIR=>'/home/gavin/zz/done',    # contains symlinks that map old to new filenames
  HOME_DIR=>'/opt/zzmeta',            # the runtime environment
  WWW_DIR=>'/home/gavin/zz/www',      # where updated files go, when MOVE_OK is false
  SERVICE_IP=>'192.168.1.100',         # server images and video
  SERVICE_URL=>'http://192.168.1.100/zz/' # combination of DOCROOT and IP
};

# @request
#   new(dirName)            read files OR die
#   new(dirName, moveOk)   write files in WWW_DIR if moveOk=1
sub new{
  my ($proto, $docRoot, $moveOk)=@_;
  my $class=ref($proto)||$proto;
  my $self={
    DOC_ROOT=>$docRoot,
    MOVE_OK=>$moveOk
  };
  bless ($self, $class);
  return $self;
}
# @params
#   write_metadata($srcDir)
#   write_metadata($srcDir, $moveOk)
# @response 
#   success {}
#   error   {error=>string} 
#   exif returns
#   0 on file write error
#   1 if file was written OK, 
#   2 if file was written but no changes made, 
#sub write_metadata {

sub update_playlist{
  my($self, $mdat)=@_;
  my($srcFile, $dstFile, $fn, $success);
  # source directory must exist and be readable to continue
  unless(-d $self->{DOC_ROOT} && -r $self->{DOC_ROOT}) {
    return{error=>'Cannot write metadata(1):'. $self->{DOC_ROOT}};
  }
  my $newFn=_new_filename($mdat);
  $srcFile=$self->{DOC_ROOT}. $mdat->{genre}. "/". $newFn->{fn}. $newFn->{ext};
  if($self->{MOVE_OK} && -f $srcFile && -r $srcFile) {
    my $fileList=_get_wwwdir_filenames();
    my $fn=$newFn->{tmpFile};
    $fileList->{$fn}++;
    my $id=sprintf "%03d", ($fileList->{$fn}-1);
    $dstFile=CONF->{WWW_DIR}. '/'. $fn. $id. $newFn->{ext};
  } elsif(-f $srcFile && -r $srcFile) {
    $dstFile=$srcFile;
  } else {
    return{error=>'Cannot write metadata(2):'. $srcFile};
  }
  #print($srcFile, $dstFile, "\n");
  my $e=Image::ExifTool->new;
  #set a new value for a tag (errors go to STDERR)
  foreach my $tag (keys %{$mdat}) {
    unless($e->SetNewValue($tag, $mdat->{$tag})) {
      $success->{error}=$e->GetValue('Error');
      last;
    }
  }
  if(exists($success->{error})){
    return{error=>'Cannot write metadata(3):'. $success->{error}};
  }elsif($srcFile eq $dstFile){
    $success=$e->WriteInfo($srcFile);
  }else{
    $success=$e->WriteInfo($srcFile, $dstFile);
  }
  if($success and _mark_as_done($mdat->{genre}, $newFn, $dstFile)){
    return {}; # success
  }elsif($success){
    return{error=>'Cannot write metadata(5): symlink was not created'};
  }else{
    return{error=>'Cannot write metadata(4):'.  $e->GetValue('Error')};
  }
  return{body=>'update ok'});
}
###############################################################################
# stubs
sub new_filename{
  my ($self, $mdat)=@_;
  return _new_filename($mdat);
}
sub get_wwwdir_filenames{
  my $self=shift;
  return _get_wwwdir_filenames();
}
sub mark_as_done{
  my $self=shift;
  return _mark_as_done(@_);
}
###############################################################################
# private

# @request
#   'genre', {fn=>'filename',ext=>'.m4v'}
# @response
#   1=ok or 0=error
sub _mark_as_done{
  my ($genre, $f, $dstFile)=@_;
  my $isOk=0;
  $genre=~s/mTeam.+/mTeam/; # trim the mTeamers
  my $symlink=CONF->{DONE_DIR}. '/'. $genre. '/'. $f->{fn}. $f->{ext};
  #print "$newFn\t$symlink\n";
  return $isOk if(! -f $dstFile or -f $symlink); # file must exist, link must not
  return symlink($dstFile, $symlink) or $isOk;
  return 1; # success
}
# @request
#   [{mdat1},{mdat2}]
# @response
#   string, e.g. milesDavisKindofblue001
#
# string has 3 logical parts
# . artist e.g. milesDavis OR role (trumpet, guitar ..) OR anon
# . album OR producer OR genre OR unknown
# . 3 digit identifier
sub _new_filename{
#  my ($exif, $id)=@_;
  my $exif=shift;
  my ($artist, $album, $id, $tmpFile);
  $artist=$exif->{artist}||'anon';
  $artist=lcfirst($artist);
  $artist=_make_string($artist);
  $album=$exif->{album}||$exif->{producer}||$exif->{genre}||'unknown';
  $album=ucfirst($album);
  $album=_make_string($album);
  $tmpFile=$artist. $album;
  my ($fn, $dir, $ext)=fileparse($exif->{source}, '\.(avi|m4v|mp4|webm)');
  return{tmpFile=>$tmpFile, fn=>$fn, dir=>$dir, ext=>$ext};
}
sub _make_string{
  my @names=split ' ', $_[0];
  my $first=shift @names;
  my @ucNames=map(ucfirst, @names);
  my $s=join '', @ucNames;
  $s=$first. $s;
  substr $s, 0, 12; 
  $s=~s/\./-/g;
  return $s;
}
sub _get_wwwdir_filenames{
  chdir CONF->{WWW_DIR};
  my @files=<*.*>;
  chdir CONF->{HOME_DIR};
  my %seen;
  foreach(@files){
    s/\d\d\d\.(.+)$//;
    $seen{$_}++;
    # print; print "\n";
  }
  return \%seen;
}
1;