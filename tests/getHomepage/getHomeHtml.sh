#!/bin/bash
: ${SERVICE_URL:?"Need to set SERVICE_URL non-empty"}
# http://h5v.mingus.local
headers=""
method="GET"
name="Get Homepage as Html"
url="$SERVICE_URL/index.php"

echo $name
curl -v -X GET -H "$headers" $url
