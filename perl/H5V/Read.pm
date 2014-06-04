package H5V::Read;
use strict;
use Data::Dumper;
use File::Find;
use File::Basename;
use Image::ExifTool;
use constant CONF=>{
  DOC_ROOT=>'/opt/git/h5v/www/video',  # media source. provided at runtime as ->new(/path/to/video)
  DONE_DIR=>'/opt/git/h5v/done',       # contains symlinks that map old to new filenames
  SERVICE_URL=>'http://h5v.fnarg.net', # combination of DOCROOT and IP
  HOME_DIR=>'/opt/git/h5v/perl'        # working dir
};
# hypermedia controls
my %m=(
 addControl=>{id=>'add', rel=>'add', name=>'links', url=>'/playlists/', action=>'append', model=>'text={text}'},
 filterControl=>{id=>'search', rel=>'search', name=>'links', url=>'/playlists/search', action=>'read', model=>'?text={text}'},
 listControl=>{id=>'list', rel=>'collection', name=>'links', url=>'/playlists/', action=>'read'},
 posterControl=>{id=>'poster', rel=>'icon', url=>'http://'. CONF->{SERVICE_URL}. '/images/html5_poster.jpg', action=>'read'},
);
# global vars required by File::Find
my $candidate;
my $success;
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
    $data->{Source}=CONF->{SERVICE_URL}. $randomItems->{$fileName}->{Genre}. "/$fileName";
    my $imageFile=$fileName;
    $imageFile=~s/\.(.+)$/.jpg/;
    $data->{Caption}=CONF->{SERVICE_URL}. '/captions/'. $imageFile;
    push @anyTen, $data;
  }
  return $self->send_uber_list(\@anyTen);
}
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
    # quick fix for m4v
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
#   {fn=>'filename',ext=>'.m4v'}
# @response
#   1=ok or 0=error
sub check_if_done{
  my ($self, $fn)=@_;
  $candidate=join '/', (CONF->{DONE_DIR}, $fn);
  $success=0;
  find(\&wanted, (CONF->{DONE_DIR}));
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
#   load_m3u($filename)
# @response
#   [{filename1=>{mdat}}, {filename2=>{mdat}}]
sub read_video_dir{
  my $self=shift;
  chdir CONF->{DOC_ROOT};
  my @files=<*.*>;
  chdir CONF->{HOME_DIR};
  my $found;
  # tags maintained by this script
  my @h5vTags=qw(Title Producer Artist Rating Album Genre TrackNumber);
  my @exifTags=qw(MIMEType); # standard stuff we need, maybe add Duration, Height, Width later
  foreach my $f(@files){
    my $vidFile=$self->{DOC_ROOT}. $f;
    my $e=Image::ExifTool->new;
    $found->{$f}=$e->ImageInfo($vidFile, (@h5vTags, @exifTags));
  }
  return $found;
}
# reads and writes to global vars
sub wanted{
  return unless -f;
  my $test=join '/', ($File::Find::dir, $_);
  $success=1 if ($candidate eq $test);
  #print $candidate. "\n";
  #print $test. "\n\n";
}
1;