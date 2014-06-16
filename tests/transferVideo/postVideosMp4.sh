#!/bin/bash
${SERVICE_URL:?"Need to set SERVICE_URL non-empty"}
${BASE_DIR:?"Need to set BASE_DIR non-empty"}
name="Mingus Post Videos Mp4" 
header="Accept: video/mp4" 
method="POST" 
url="$SERVICE_URL/index.php/videos/"    
fileupload=449230816

echo $name
echo "ls ../incoming/small.mp4"
ls ../incoming/small.mp4

curl -v \
  -X $method --form "$fileupload=@${BASE_DIR}/tests/transferVideo/small.mp4" \
  -H "$header" \
  $url

echo ""
echo "now do"
echo "sudo rm ../incoming/small.mp4"
echo "and run it again"