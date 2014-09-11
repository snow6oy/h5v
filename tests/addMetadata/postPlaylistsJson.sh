#!/bin/bash
: ${API_URL:?"Need to set API_URL"}

name="Post Json to Playlists" 
header="Accept: application/json" 
method="POST"
url="$API_URL/cgi-bin/playlists.pl"    

echo $name

curl -v \
  -X $method \
  -H "$header" \
  --data @"$BASE_DIR/tests/addMetadata/postPlaylists.json" \
  $url

echo ""
echo Check
echo "./incoming/wSJ8H6.mp4"
echo "./videos/evinhaLatin[0000-9999].mp4"
echo "./exiftool.sh evinhaLatin[0000-9999].mp4"