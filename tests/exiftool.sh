#!/bin/bash

FILE=$1
#EXIF=/usr/local/lib/site_perl/Image-ExifTool-9.58/
BASE_DIR=/opt/git/h5v
#EXIF=/home/dishyzee/h5v/perl/Image-ExifTool-9.58/
#VID_DIR=/home/dishyzee/h5v/videos
echo "extracting exif from $FILE"
exiftool -Title -Artist -Album -Rating -TrackNumber -Producer -Genre -MIMEType -Permissions -EndUserID -EndUserName "$BASE_DIR/videos/$FILE"
