#!/bin/bash
: ${API_URL:?"Need to set API_URL non-empty"}
name="Mingus Put Playlists Json" 
header="Accept: application/json" 
method="PUT" 
url="$API_URL/cgi-bin/playlists.pl"

echo $name

curl -v \
  -X $method \
  -H "$header" \
  --data @"$BASE_DIR/tests/updateMetadata/playlists.json" \
  $url

echo ""
echo Checking Metadata
echo ""
./exiftool.sh borisLegoCollection0003.mp4