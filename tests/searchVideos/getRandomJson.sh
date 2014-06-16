#!/bin/bash
: ${SERVICE_URL:?"Need to set SERVICE_URL non-empty"}
# http://h5v.mingus.local
name="Get Random Videos as Json"
headers="Accept: application/json"
method="GET"
url="$SERVICE_URL/index.php/search?term=a"
# url="$SERVICE_URL/index.php/videos/"


echo $name
curl -v -X GET -H "$headers" $url
