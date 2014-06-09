package H5V::Read;
use parent 'H5V';
use strict;
use Data::Dumper;
use File::Find;
use Image::ExifTool;
# hypermedia controls
my %m=(
 addControl=>{id=>'add', rel=>'add', name=>'links', url=>'/playlists/', action=>'append', model=>'term={text}'},
 filterControl=>{id=>'search', rel=>'search', name=>'links', url=>'/playlists/search', action=>'read', model=>'?term={text}'},
 listControl=>{id=>'list', rel=>'collection', name=>'links', url=>'/playlists/', action=>'read'},
 posterControl=>{id=>'poster', rel=>'icon', url=>'http://h5v.fnarg.net/images/dzlogo.png', action=>'read'},
);
# global vars required by File::Find
my $candidate;
my $success;
sub new{
  my $proto=shift;
  my $class=ref($proto)||$proto;
  my $self={};
  bless ($self, $class);
  return $self;
}
sub load_anyten{
  my $self=shift;
  my $randomItems=$self->find_random();
  my @anyTen;
  foreach my $filename(keys %$randomItems){
    my $data=$randomItems->{$filename};
    my $webPath=$self->SUPER::file_to_web($filename);
    $data->{Source}=$webPath->{Source};
    $data->{Caption}=$webPath->{Caption};
    push @anyTen, $data;
  }
  return \@anyTen;
  #return $self->send_uber_list(\@anyTen);
}
sub search{
  my ($self, $term)=@_;
  return [{error=>'Search term required'}] unless $term;
  my $videoData=$self->read_video_dir();
  my @videoFiles=keys %{$videoData};
  my @tags=$self->SUPER::get_tags();
  my @found=();
  foreach my $f(@videoFiles){
    # not sure if this is needed, won't the search just fail anyway?
    # my $done=$self->check_if_done($f);
    # next unless $done; 
    my $toSearch;
    foreach my $tag(@tags){
      $toSearch.=$videoData->{$f}->{$tag};
    }
    if ($toSearch=~/$term/i){
      # print $toSearch. '<=>'. $term. " $f\n";
      my $match=$videoData->{$f};
      my $webPath=$self->SUPER::file_to_web($f);
      $match->{Source}=$webPath->{Source};
      $match->{Caption}=$webPath->{Caption};
      push @found, $match;
    }
  }
  return \@found;
  #return $self->send_uber_list(\@found);
}
# TODO move this into PHP once OAuth done
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
    # $c{data}->[3]='video/mp4';
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
  my ($self, $splitFn)=@_;
  my $doneCandidate=$self->SUPER::get_done_candidate($splitFn);
  $candidate=$doneCandidate->{filename};
  $success=0;
  find(\&wanted, $doneCandidate->{dir});
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
  for my $i(0..2){
    my $rndNumber=int(rand(@keys));
    $keys[$rndNumber]=~tr/\\/\//; # replace backslash with a forwards one
    push @lookups, $keys[$rndNumber];
  }
  foreach(@lookups){
    my $done=$self->check_if_done({filename=>$_});
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
  my $videoDir=$self->SUPER::get_video_filenames();
  my @tags=$self->SUPER::get_tags();
  my $found;
  my @exifTags=qw(MIMEType); # standard stuff we need, maybe add Duration, Height, Width later
  foreach my $f(@{$videoDir->{files}}){
    my $videoFile=$videoDir->{name}. "/$f";
    my $e=Image::ExifTool->new;
    $found->{$f}=$e->ImageInfo($videoFile, (@tags, @exifTags));
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