#!/bin/bash
: ${ENV:?"Need to set ENV non-empty"}

name="Mingus Put Playlists Json" 
header="Accept: application/json" 
method="PUT" 
url="$ENV/cgi-bin/playlists.pl"    
fileupload=449230816

echo $name

curl -v \
  -X $method \
  -H "$header" \
  -d '{"title":"test","artist":"Post ","genre":"Alternative","album":"To","producer":"Videos","rating":"1","trackNumber":"4","source":"small.mp4","permissions":"2","tw_id_str":"449230816","tw_screen_name":"nature6oy"}' \
  $url

echo ""
echo Check Metadata
echo ""
echo './exiftool.sh small.mp4'
