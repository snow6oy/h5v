#!/bin/bash
# load vars for env
u=$USER
if [ $u = "gavin" ]; then
  export SERVICE_URL=http://rudy.local
  export API_URL=http://api.rudy.local
  export BASE_DIR=/opt/git/h5v
elif [ $u = "dishyzee" ]; then
  export SERVICE_URL=http://dishyzee.com
  export API_URL=http://api.dishyzee.com
  export BASE_DIR=/home/dishyzee/h5v
else
  echo "unknown user. panic"
  exit
fi
#echo $SERVICE_URL
#echo $API_URL
#echo $BASE_DIR
OPTIONS="
quit
./error.sh
./getHomepage/getHomeJson.sh
./getHomepage/getHomeHtml.sh
./searchVideos/searchRandom.pl
./searchVideos/searchVideos.pl
./searchVideos/readVideoDir.pl
./searchVideos/getPlaylistsJson.sh
./searchVideos/getRandomJson.sh
./searchVideos/getSearchJson.sh
./selectVideoItem/getVideoItem.sh
./transferVideo/postVideosMp4.sh
./addMetadata/create.pl
./addMetadata/postPlaylistsJson.sh
./addMetadata/putTmpVideos.sh
./addMetadata/getWwwDirFilenames.pl
./updateMetadata/updateMetadata.pl
./updateMetadata/putPlaylistsJson.sh
./updateMetadata/putVideoItem.sh
"
#./updateMetadata/putVideosJson.sh
#./updateMetadata/putVideoItemJsonTemplate.sh
select opt in $OPTIONS; do
  if [ "$opt" = "quit" ]; then
    echo bye bye
    exit
  elif [ "$opt" = "./error.sh" ]; then
./error.sh    
  elif [ "$opt" = "./getHomepage/getHomeJson.sh" ]; then
./getHomepage/getHomeJson.sh
  elif [ "$opt" = "./getHomepage/getHomeHtml.sh" ]; then
./getHomepage/getHomeHtml.sh
  elif [ "$opt" = "./searchVideos/searchRandom.pl" ];then
./searchVideos/searchRandom.pl
  elif [ "$opt" = "./searchVideos/searchVideos.pl" ];then
./searchVideos/searchVideos.pl
  elif [ "$opt" = "./searchVideos/readVideoDir.pl" ];then
./searchVideos/readVideoDir.pl
  elif [[ "$opt" = "./searchVideos/getPlaylistsJson.sh" ]]; then
./searchVideos/getPlaylistsJson.sh
  elif [ "$opt" = "./searchVideos/getRandomJson.sh" ];then
./searchVideos/getRandomJson.sh
  elif [ "$opt" = "./searchVideos/getSearchJson.sh" ];then
./searchVideos/getSearchJson.sh
  elif [ "$opt" = "./selectVideoItem/getVideoItem.sh" ];then
./selectVideoItem/getVideoItem.sh
  elif [ "$opt" = "./transferVideo/postVideosMp4.sh" ];then
./transferVideo/postVideosMp4.sh
  elif [ "$opt" = "./addMetadata/getWwwDirFilenames.pl" ];then
./addMetadata/getWwwDirFilenames.pl
  elif [ "$opt" = "./addMetadata/create.pl" ];then
./addMetadata/create.pl
  elif [ "$opt" = "./addMetadata/postPlaylistsJson.sh" ];then
./addMetadata/postPlaylistsJson.sh
  elif [ "$opt" = "./addMetadata/putTmpVideos.sh" ];then
./addMetadata/putTmpVideos.sh
  elif [ "$opt" = "./updateMetadata/updateMetadata.pl" ];then
./updateMetadata/updateMetadata.pl
  elif [ "$opt" = "./updateMetadata/putPlaylistsJson.sh" ];then
./updateMetadata/putPlaylistsJson.sh
  elif [ "$opt" = "./updateMetadata/putVideoItem.sh" ];then
./updateMetadata/putVideoItem.sh
  else
    clear
    echo bad option
  fi
done
