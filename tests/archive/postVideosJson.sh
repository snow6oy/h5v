#!/bin/bash
: ${ENV:?"Need to set ENV non-empty"}
# http://h5v.mingus.local
name="Post Videos Json" 
header="Accept: application/json" 
# headers="Accept: video/mp4\nContent-Type: multipart/form-data"
method="POST" 
url="$ENV/index.php/videos/"    

echo $name
# --data @/opt/git/h5v/tests/addMetadata/postVideos.json \

curl -v \
  -X $method \
  -H "$header" \
  --data @/home/dishyzee/h5v/tests/addMetadata/postVideos.json \
  $url

echo ""
echo Expected
echo ./incoming/evinha.mp4
echo './videos/evinhaLatin[0000-9999].mp4'
echo './exiftool.sh evinhaLatin[0000-9999].mp4'
