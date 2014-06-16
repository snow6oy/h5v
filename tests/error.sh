#!/bin/bash
# set vars for environment
: ${SERVICE_URL:?"Need to set SERVICE_URL"}

# force error
headers="Accept: x"  
method="GET"
name="Disply Media Type Error"
url="$SERVICE_URL/"

echo $name
curl -v -X GET -H "$headers" $url