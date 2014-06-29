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
sub create{
  my($self, $mdat)=@_;
  # gather the parts
  my $splitFn=$self->SUPER::web_to_file($mdat->{source});
  my $src=$self->SUPER::get_incoming_filename($splitFn);
  my $dst=$self->new_filename($splitFn, $mdat);
  # create new file as a side effect of update
  my $error=$self->update_metadata($mdat, $src, $dst);
  if($error){
    return {error=>'Cannot write metadata: '. $error};
  }
  my $symlink=$self->SUPER::get_done_filename($splitFn);
  if(! -f $dst or -f $symlink){ # file must exist, link must not
    return {error=>'Cannot mark as done'};    
  }
  symlink($dst, $symlink);
  return undef; # success
}
sub update_metadata{
  my($self, $mdat, $src, $dst, $error);
  if(@_>2){  # create makes its own filepath based on /incoming
    ($self, $mdat, $src, $dst)=@_;
  }else{     # updates are applied in situ
    ($self, $mdat)=@_;
    # source is a web path, convert to file
    my $splitFn=$self->SUPER::web_to_file($mdat->{source});
    $src=$splitFn->{dir}. '/'. $splitFn->{filename}. $splitFn->{extn};    
  }
  logger($src, $dst, "\n");
  # create EndUser tag as an XMP:struct ~phil/exiftool/TagNames/XMP.html#EndUser
  my $endUser={};
  $endUser->{EndUserID}=delete($mdat->{tw_id_str});
  $endUser->{EndUserName}=delete($mdat->{tw_screen_name});
  $mdat->{'XMP:EndUser'}=$endUser;
  my $exif=Image::ExifTool->new;
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
  my $responseCode=($dst) ? $exif->WriteInfo($src, $dst) : $exif->WriteInfo($src);

  if($responseCode){
    return undef; # success
  }else{
    return $exif->GetValue('Error');
  }
}
sub new_filename{
  my ($self, $splitFn, $exif)=@_;
  my ($artist, $album, $id, $fn, $fileList);
  # make name from metadata
  $artist=$exif->{artist}||'anon';
  $artist=lcfirst($artist);
  $artist=make_string($artist);
  $album=$exif->{album}||$exif->{producer}||$exif->{genre}||'unknown';
  $fn=$artist. make_string(ucfirst($album));
  # construct unique id
  $fileList=$self->get_wwwdir_filenames();
  $fileList->{$fn}++;
  $id=sprintf "%04d", ($fileList->{$fn}-1);
  # replace original name
  return $splitFn->{dir}. '/'. $fn. $id. $splitFn->{extn};
}
# similar to Read::read_video_dir but hash has different keys
sub get_wwwdir_filenames{
  my $self=shift;
  my $videoDir=$self->SUPER::get_video_filenames();
  my $found;
  foreach my $f(@{$videoDir->{files}}){
    $f=~s/\d\d\d\d\.(.+)$//;
    $found->{$f}++;
  }
  return $found;
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
sub logger{
  my $logmsg=join ' ', @_;
  open (LOG, ">>/tmp/h5v.log") or die $!;
  print LOG time. "\n". $logmsg. "\n";
  close LOG;
}
1;