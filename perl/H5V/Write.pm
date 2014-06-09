package H5V::Write;
use parent 'H5V';
use strict;
use Data::Dumper;
use Image::ExifTool;
sub new{
  my $proto=shift;
  my $class=ref($proto)||$proto;
  my $self={};
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
#   2 if file was written but no changes made
sub create_new{
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
    #$dstFile=CONF->{WWW_DIR}. '/'. $fn. $id. $newFn->{ext};
  } elsif(-f $srcFile && -r $srcFile) {
    $dstFile=$srcFile;
  } else {
    return{error=>'Cannot write metadata(2):'. $srcFile};
  }
  my $outcome=$self->update_metadata($mdat);
  if($outcome){
    return {error=>'Cannot write metadata(3 or 4):'. $outcome->{error}};
  }
  #print($srcFile, $dstFile, "\n");
  if($srcFile eq $dstFile){
  }else{
    #$success=$exif->WriteInfo($srcFile, $dstFile);
  }
  if($success and _mark_as_done($mdat->{genre}, $newFn, $dstFile)){
    return {}; # success
  }elsif($success){
    return{error=>'Cannot write metadata(5): symlink was not created'};
  }else{
    return{error=>'Cannot write metadata(4):'. undef };
  }
  return{body=>'update ok'};
}
sub update_metadata{
  my($self, $mdat)=@_;
  # source is a web path, convert to file
  my $splitFn=$self->SUPER::web_to_file($mdat->{source});
  my $filename=$splitFn->{dir}. '/'. $splitFn->{filename}. $splitFn->{extn};
  my $exif=Image::ExifTool->new;
  my $error;
  #set new values for each given tag
  foreach my $tag(keys %{$mdat}){
    my ($ok, $e)=$exif->SetNewValue($tag, $mdat->{$tag});
    if (! $ok){
      $error=$tag. ':'. $e;
      last;
    }
  }
  return $error if($error);
  # WriteInfo returns 1 if file was written OK, 2 if file was written but no changes made, 0 on file write error
  # TODO consider a http 200 for 1 and a http 204 (no content) for 2
  my $responseCode=$exif->WriteInfo($filename);
  if($responseCode){
    return undef; # success
  }else{
    return $exif->GetValue('Error');
  }
}
sub new_filename{
  my ($self, $exif)=@_;
  my ($artist, $album, $id, $tmpFile);
  $artist=$exif->{artist}||'anon';
  $artist=lcfirst($artist);
  $artist=make_string($artist);
  $album=$exif->{album}||$exif->{producer}||$exif->{genre}||'unknown';
  $album=ucfirst($album);
  $album=make_string($album);
  my $file=$self->SUPER::split_filename($exif->{source});
  $file->{tmpFile}=$artist. $album;
  return $file;
}
# similar to Read::read_video_dir but hash has different keys
sub get_wwwdir_filenames{
  my $self=shift;
  my $videoDir=$self->SUPER::get_video_filenames();
  my $found;
  foreach my $f(@{$videoDir->{files}}){
    $f=~s/\d\d\d\.(.+)$//;
    $found->{$f}++;
  }
  return $found;
}
# @request
#   'genre', {fn=>'filename',ext=>'.m4v'}
# @response
#   1=ok or 0=error
sub mark_as_done{
  my $self=shift;
  my ($genre, $f, $dstFile)=@_;
  my $isOk=0;
  $genre=~s/mTeam.+/mTeam/; # trim the mTeamers
  my $symlink=$self->SUPER::get_done_filename($f->{fn}); # FIX THIS
  return symlink($dstFile, $symlink) or $isOk;
  return 1; # success
}
###############################################################################
# private
# @request
#   [{mdat1},{mdat2}]
# @response
#   string, e.g. milesDavisKindofblue001
#
# string has 3 logical parts
# . artist e.g. milesDavis OR role (trumpet, guitar ..) OR anon
# . album OR producer OR genre OR unknown
# . 3 digit identifier
sub make_string{
  my @names=split ' ', $_[0];
  my $first=shift @names;
  my @ucNames=map(ucfirst, @names);
  my $s=join '', @ucNames;
  $s=$first. $s;
  substr $s, 0, 12; 
  $s=~s/\./-/g;
  return $s;
}
1;