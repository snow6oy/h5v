#!/bin/bash
: ${SERVICE_URL:?"Need to set SERVICE_URL non-empty"}
# http://h5v.mingus.local
headers="Accept: application/json"
# headers="Accept: application/vnd.collection+json"
method="GET"
name="Get Search as Json"
payload=""
url="$SERVICE_URL/index.php/search?term=evinha"

echo $name
curl -v -X GET -H "$headers" $url
