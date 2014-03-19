package H5V::Read;
use strict;
use Data::Dumper;
use File::Find;
use File::Basename;
use Image::ExifTool;
use constant CONF=>{
  SERVICE_URL=>'http://h5v.fnarg.net', # web root
  HOME_DIR=>'/opt/git/h5v'             # working dir
};
# hypermedia controls
my %m=(
 addControl=>{id=>'add', rel=>'add', name=>'links', url=>'/playlists/', action=>'append', model=>'term={text}'},
 filterControl=>{id=>'search', rel=>'search', name=>'links', url=>'/playlists/search', action=>'read', model=>'?term={text}'},
 listControl=>{id=>'list', rel=>'collection', name=>'links', url=>'/playlists/', action=>'read'},
 posterControl=>{id=>'poster', rel=>'icon', url=>'http://'. CONF->{SERVICE_URL}. '/images/html5_poster.jpg', action=>'read'},
);
# global vars required by File::Find
my $candidate;
my $success;
# custom tags stored in media file
my @h5vTags=qw(Title Producer Artist Rating Album Genre TrackNumber);
# @request
#   new(dirName)            read files OR die
sub new{
  my ($proto, $docRoot)=@_;
  my $class=ref($proto)||$proto;
  my $self={
    DOC_ROOT=>$docRoot,
  };
  bless ($self, $class);
  return $self;
}
sub load_anyten{
  my $self=shift;
  my $randomItems=$self->find_random();
  my @anyTen;
  foreach my $fileName (keys %$randomItems){
    my $data=$randomItems->{$fileName};
    $data->{Source}=CONF->{SERVICE_URL}. "/video/$fileName";
    my $imageFile=$fileName;
    $imageFile=~s/\.(.+)$/.jpg/;
#    $data->{Caption}=CONF->{SERVICE_URL}. '/captions/'. $imageFile;
    $data->{Caption}=CONF->{SERVICE_URL}. '/captions/';
    $data->{Caption}.=(-f CONF->{HOME_DIR}. '/www/captions/'. $imageFile) ? $imageFile : 'video-placeholder.jpg';
    push @anyTen, $data;
  }
  return $self->send_uber_list(\@anyTen);
}
sub search{
  my ($self, $term)=@_;
  return{error=>'Search term required'} unless $term;
  my $videoData=$self->read_video_dir();
  my @videoFiles=keys %{$videoData};
  my @found;
  foreach my $f(@videoFiles){
    my $done=$self->check_if_done($f);
    next unless $done; # not sure if this is needed, won't the search just fail anyway?
    my $toSearch;
    foreach my $tag(@h5vTags){
      $toSearch.=$videoData->{$f}->{$tag};
    }
    if ($term=~/$toSearch/){
      $videoData->{Source}=CONF->{SERVICE_URL}. "/video/$f";
      my $imageFile=$f;
      $imageFile=~s/\.(.+)$/.jpg/;
      $videoData->{Caption}=CONF->{SERVICE_URL}. '/captions/';
      $videoData->{Caption}.=(-f CONF->{HOME_DIR}. '/www/captions/'. $imageFile) ? $imageFile : 'video-placeholder.jpg';
      push @found, $videoData;
    }
  }
  return $self->send_uber_list(\@found);
}
# @request
#    [{uberList1},{uberList2} ... ]
sub send_uber_list {
  my ($self, $uberList)=@_;
  my %list=(
    uber=>{
      version=>'1.0',
      data=>[
        { id=>'links',
          data=>[]
        },
        { id=>'playlists',
          data=>[]
        }
      ]
    }
  );
  push @{$list{uber}->{data}->[0]->{data}}, $m{posterControl};
  #no point offering links to stuff unless there is stuff
  if (@{$uberList}){
    push @{$list{uber}->{data}->[0]->{data}}, $m{listControl};
    push @{$list{uber}->{data}->[0]->{data}}, $m{filterControl};
  }
  push @{$list{uber}->{data}->[0]->{data}}, $m{addControl};
  # construct the playlist response
  my $i=0;
  foreach my $uber (@$uberList) {
    my %a=(id=>'video#'. $i, rel=>'item', name=>'playlists');
    my %b=(rel=>'replace', url=>'/playlists/', model=>'id='. $i, action=>'replace');
    my %c=(data=>[
      {name=>'source'}, $uber->{Source}, 
      {name=>'type'}, $uber->{MIMEType},
      {name=>'caption'}, $uber->{Caption},
      {name=>'title'}, $uber->{Title},
      {name=>'artist'}, $uber->{Artist},
      {name=>'album'}, $uber->{Album},
      {name=>'rating'}, $uber->{Rating},
      {name=>'trackNumber'}, $uber->{TrackNumber},
      {name=>'producer'}, $uber->{Producer},
      {name=>'genre'}, $uber->{Genre}
    ]);
    # quick fix for m4v mime type
    # $c{data}->[3]=~s#video/x-m4v#video/mp4#g;
    $c{data}->[3]='video/mp4';
    push @{$list{uber}->{data}->[1]->{data}}, (\%a, [\%b, \%c]);
    $i++;
  }
  return \%list;
}
# @request
#   {fn=>'filename',ext=>'.mp4'}
# @response
#   1=ok or 0=error
sub check_if_done{
  my ($self, $fn)=@_;
  my $doneDir=CONF->{HOME_DIR}. "/done";
  $candidate=join '/', ($doneDir, $fn);
  $success=0;
  find(\&wanted, $doneDir);
  return $success;
}
###############################################################################
#  open (LOG, ">>/tmp/h5v.log") or die $!;
#  print LOG $candidate. "\t\t". $success. "\n";
#  close LOG;
###############################################################################
sub find_random{
  my $self=shift;
  my $videoData=$self->read_video_dir();
  # pick a random number
  srand(time);
  my @keys=keys %{$videoData};
  my (@lookups, %found);
  for my $i(0..9){
    my $rndNumber=int(rand(@keys));
    $keys[$rndNumber]=~tr/\\/\//; # replace backslash with a forwards one
    push @lookups, $keys[$rndNumber];
  }
  foreach(@lookups){
    my $done=$self->check_if_done($videoData->{$_}->{Genre}, $_);
    $videoData->{$_}->{Title}='__DONE__' if $done;
    $found{$_}=$videoData->{$_};
  }
  return \%found;
}
# @request
#   read_video_dir()
# @response
#   [{filename1=>{mdat}}, {filename2=>{mdat}}]
#   mdat is the video file metadata represented as a hash of tag/vals
sub read_video_dir{
  my $self=shift;
  my $videoDir=CONF->{HOME_DIR}. "/www/video";
  chdir $videoDir;
  my @files=<*.*>;
  chdir CONF->{HOME_DIR}. '/perl'; # otherwise 'use Blah' will fail
  my $found;
  my @exifTags=qw(MIMEType); # standard stuff we need, maybe add Duration, Height, Width later
  foreach my $f(@files){
    my $videoFile=$videoDir. "/$f";
    my $e=Image::ExifTool->new;
    $found->{$f}=$e->ImageInfo($videoFile, (@h5vTags, @exifTags));
  }
  return $found;
}
# private
# reads and writes to global vars
sub wanted{
  return unless -f;
  my $test=join '/', ($File::Find::dir, $_);
  $success=1 if ($candidate eq $test);
  #print $candidate. "\n";
  #print $test. "\n\n";
}
1;