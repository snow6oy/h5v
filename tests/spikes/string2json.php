<?php    
// $json_string=getJsonString();
// echo $json_string;
$json_string=getTemplateString();
$json=json_decode($json_string);
// var_dump($json);
$payload=array();
foreach($json->template->data as $d){
  $key=templateToItem($d);
  $payload[$key]=$d->value;
}
$payload['source']=$json->source;
print_r($payload);
echo json_encode($payload);

exit;
// var_dump($json[0]);
// print_r($tdata);
// echo $tdata['Title']['name']. "\n";
$items=array();
foreach($json as $j){
  array_push($items, jsonToItem($j));
}
echo json_encode($items);

function templateToItem($d){
  $tdata=array(
    'title'=>"Title",
    'artist'=>"Artist",
    'genre'=>"Genre",
    'album'=>"Album",
    'track'=>"TrackNumber",
    'producer'=>"Producer",
    'rating'=>"Rating",
    'scope'=>"Permissions",
    'type'=>"MIMEType"
  );
  // echo $tdata[$d->name]. ':'. $d->value. "\n";
  return $tdata[$d->name];
}

function jsonToItem($json){
  $data=array();
  $href="";
  $links=array();
  $tdata=array(
    "Title"=>array('name'=>'title', "prompt"=>"Track Title"),
    "Artist"=>array("name"=>"artist", "prompt"=>"Artist"),
    "Genre"=>array("name"=>"genre", "prompt"=>"Genre"),                
    "Album"=>array("name"=>"album", "prompt"=>"Album"),
    "TrackNumber"=>array("name"=>"track", "prompt"=>"Track#"),
    "Producer"=>array("name"=>"producer", "prompt"=>"Producer"),
    "Rating"=>array("name"=>"rating", "prompt"=>"Rating"),
    "Permissions"=>array("name"=>"scope", "prompt"=>"Shared With"),
    "MIMEType"=>array("name"=>"type")
  );
  foreach($json as $key=>$val){
    $prompt=(isset($tdata[$key]['prompt'])) ? $tdata[$key]['prompt'] : null;
    switch($key){
      case 'Source':
        $href=$val;
        break;
      case 'Caption':
        $links=array(
          array("rel"=>"caption", "href"=>$val, "prompt"=>"Video Placeholder", "render"=>"image")
        );
        break;
      default:
        $anon=array(
          "name"=>$tdata[$key]['name'],
          "value"=>$val,
          "prompt"=>$prompt
        );
        array_push($data, $anon);
    }
  }
  $item=(array("href"=>$href, "data"=>$data, "links"=>$links));
  return $item;
}

function getJsonString() {
  $string=<<<JSON
[
   {
      "MIMEType" : "video/mp4",
      "Album" : "",
      "Genre" : "Latin",
      "TrackNumber" : "5",
      "Rating" : "1",
      "Artist" : "evinha",
      "Title" : "Test add meta after upload",
      "Caption" : "http://h5v.mingus.local/captions/video-placeholder.png",
      "Source" : "http://h5v.mingus.local/videos/evinhaLatin0002.mp4",
      "Producer" : "",
      "Permissions" : "2"
   },
   {
      "MIMEType" : "video/mp4",
      "Album" : "To",
      "Genre" : "Alternative",
      "TrackNumber" : "4",
      "Rating" : "1",
      "Artist" : "Peter",
      "Title" : "test",
      "Caption" : "http://h5v.mingus.local/captions/video-placeholder.png",
      "Source" : "http://h5v.mingus.local/videos/geniusTo0000.mp4",
      "Producer" : "Videos",
      "Permissions" : "2"
   }
]
JSON;
  return $string;
}

function getTemplateString(){
  $string=<<<JSON
{ "template": 
  { "data": 
    [
      {"name": "title", "value": "new template"},
      {"name": "artist", "value": "evinha"},
      {"name": "genre", "value": "Latin"},
      {"name": "album", "value": "Oya"},
      {"name": "track", "value": "1"},
      {"name": "producer", "value": ""},
      {"name": "rating", "value": "4"},
      {"name": "scope", "value": "2"},
      {"name": "type", "value": ""} 
    ]
  },
  "source": "geniusTo0000.mp4"
}
JSON;
  return $string;  
}

 /*
  *
  * output
  *
      "items": [
          {
              "href": "http://h5v.mingus.local/videos/evinhaLatin0006.mp4",
              "data": [
                  {
                      "name": "title",
                      "value": "Best pop song",
                      "prompt": "Track Title"
                  } ...
              ],
              "links": [
                  {
                      "rel": "caption",
                      "href": "http://h5v.mingus.local/captions/video-placeholder.png",
                      "prompt": "Video Placeholder",
                      "render": "image"
                  }
              ]
  */
?>
