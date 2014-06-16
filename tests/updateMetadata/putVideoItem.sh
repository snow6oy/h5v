#!/bin/bash
: ${SERVICE_URL:?"Need to set SERVICE_URL non-empty"}
name="Put Video Item as Json" 
header="Accept: application/json" 
method="PUT" 
url="$SERVICE_URL/index.php/videos/borisLegoCollection0003"

echo $name

#  --data @/opt/git/h5v/tests/updateMetadata/putVideoItem.json \

curl -v \
  -X $method \
  -H "$header" \
  --data @"$BASE_DIR/tests/updateMetadata/putVideoItem.json" \
  $url

echo ""
echo Checking Metadata
echo ""
./exiftool.sh borisLegoCollection0003.mp4