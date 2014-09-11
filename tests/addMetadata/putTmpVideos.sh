#!/bin/bash
: ${API_URL:?"Need to set API_URL"}
: ${BASE_DIR:?"Need to set BASE_DIR"}
name="Put Tmp Videos Json" 
header="Accept: application/json" 
method="PUT"
#url="$ENV/index.php/videos/"    
url="$API_URL/index.php/videos/wSJ8H6.mp4"

echo $name

curl -v \
  -X $method \
  -H "$header" \
  --data @"$BASE_DIR/tests/addMetadata/putTmpVideos.json" \
  $url

echo ""
echo Expected
echo ./incoming/wSJ8H6.mp4
echo './videos/evinhaOya[0000-9999].mp4'
echo './exiftool.sh evinhaOya[0000-9999].mp4'