#!/bin/bash
: ${API_URL:?"Need to set API_URL non-empty"}

name="Get Random Videos as Json"
headers="Accept: application/json"
method="GET"
url="$API_URL/cgi-bin/search.pl?term=v"
echo $name
curl -v -X GET -H "$headers" $url