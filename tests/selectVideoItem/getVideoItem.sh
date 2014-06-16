#!/bin/bash
: ${SERVICE_URL:?"Need to set SERVICE_URL non-empty"}
# http://h5v.mingus.local
#headers="Accept: video/mp4"
headers="Accept: text/html"
method="GET"
name="H5v Get VideoItem"
url="$SERVICE_URL/index.php/videos/borisLegoCollection0003"

echo $name
curl -v -X GET -H "$headers" $url
