# hypermedia controls
my %m=(
 addControl=>{id=>'add', rel=>'add', name=>'links', url=>'/playlists/', action=>'append', model=>'term={text}'},
 filterControl=>{id=>'search', rel=>'search', name=>'links', url=>'/playlists/search', action=>'read', model=>'?term={text}'},
 listControl=>{id=>'list', rel=>'collection', name=>'links', url=>'/playlists/', action=>'read'},
 posterControl=>{id=>'poster', rel=>'icon', url=>'/static/dzlogo.png', action=>'read'},
);
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
      {name=>'genre'}, $uber->{Genre},
      {name=>'permissions'}, $uber->{Permissions}
    ]);
    # quick fix for m4v mime type
    # $c{data}->[3]=~s#video/x-m4v#video/mp4#g;
    # $c{data}->[3]='video/mp4';
    push @{$list{uber}->{data}->[1]->{data}}, (\%a, [\%b, \%c]);
    $i++;
  }
  return \%list;
}
