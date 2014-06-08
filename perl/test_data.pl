our($updateMetadata);
$updateMetadata=[
  {
    source=>'/opt/git/h5v/www/video/small.mp4',
    title=>'a small vehicle of lego',
    artist=>'tank man',
    album=>'lego collection',
    rating=>'2',
    trackNumber=>'4',
    producer=>'lego.com',
    genre=>'family',
  },
  {
    source=>'/opt/git/h5v/www/video/dizzy.mp4',
    title=>'cat chasing a reflection',
    rating=>'1',
    trackNumber=>'0',
    genre=>'family',
  },
  {
    source=>'/opt/git/h5v/www/video/dizzy.mp4',    
    title=>'cat chasing a reflection',
    rating=>undef,
    trackNumber=>'three'    
  },  
  {source=>'/x/y.z'},
  {source=>'/opt/git/h5v/www/video/dizzy.webm'}
];
$putMetadata='{"source":"http://h5v.fnarg.net/video/elephants-dream.mp4","title":"Elephants Dream","artist":"A","album":"B","rating":"1","trackNumber":"0","producer":"blender.org","genre":"animation"}';