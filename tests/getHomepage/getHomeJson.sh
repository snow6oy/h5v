#!/bin/bash
: ${SERVICE_URL:?"Need to set SERVICE_URL non-empty"}
# http://h5v.mingus.local
headers="Accept: application/json"
method="GET"
name="Dishyzee Get Home as Json"
payload=""
url="$SERVICE_URL/"

echo $name
curl -v -X GET -H "$headers" $url