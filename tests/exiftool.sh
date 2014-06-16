#!/bin/bash

FILE=$1
EXIF=/usr/local/lib/site_perl/Image-ExifTool-9.58/
VID_DIR=/opt/git/h5v/videos
#EXIF=/home/dishyzee/h5v/perl/Image-ExifTool-9.58/
#VID_DIR=/home/dishyzee/h5v/videos
echo "extracting exif from $FILE"
$EXIF/exiftool -Title -Artist -Album -Rating -TrackNumber -Producer -Genre -MIMEType -Permissions -EndUserID -EndUserName "$VID_DIR/$FILE"
