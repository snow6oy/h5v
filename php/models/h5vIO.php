<?php
/*
 * h5v IO functions
 **/
class h5vIO {
  function request($content_type, $path, $params, $method) {
    $url=API_URL. "/$path";
    $header=array('Content-Type:'. $content_type);
    /* debugger */
      echo '-----------------------------------------------'. "\n";
      echo $method. ' '. $url. "\n";
      echo $header. ' '. "\n\n";
      var_dump($params);
      echo '-----------------------------------------------'. "\n";
    /**/
    $ch = curl_init(); 
    if (isset($method) and $method=='POST') { 
      curl_setopt($ch, CURLOPT_POST, true);
      curl_setopt($ch, CURLOPT_POSTFIELDS, $params);
    } else if (isset($method) and $method=='PUT') {
      curl_setopt($ch, CURLOPT_CUSTOMREQUEST, 'PUT');
      curl_setopt($ch, CURLOPT_POSTFIELDS, $params);
    } else if (isset($params)) { // curl defaults to GET
      $url=$url. '?'. $params;
    }
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true); 
    curl_setopt($ch, CURLINFO_HEADER_OUT, true);
    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);  // bad idea on a production site
    curl_setopt($ch, CURLOPT_HTTPHEADER, $header); 
    $output=curl_exec($ch);
    // var_dump(curl_getinfo($ch,CURLINFO_HEADER_OUT));
    if (curl_errno($ch)) {
      throw new Exception('No results, maybe the wire snapped: '. curl_error($ch), 500);
    }
    curl_close($ch);      
    // echo "\nresponse\n\n". $output;
    return $output;
  }
  /* convert C+J names to H5V 
   * remove collection+json from payload beforing firing off 
   **/
  function cjToH5V($input){
    $tdata=array(
      'title'=>"Title",
      'artist'=>"Artist",
      'genre'=>"Genre",
      'album'=>"Album",
      'track'=>"TrackNumber",
      'producer'=>"Producer",
      'rating'=>"Rating",
      'scope'=>"Permissions",
      'type'=>"MIMEType",
      'source'=>'source'      
    );
    $cj=json_decode($input);
    if(empty($cj) || !property_exists($cj, "template"))
      return false;
    $payload=array();
    foreach($cj->template->data as $d){
      $payload[$tdata[$d->name]]=$d->value;
    }
    if(empty($payload['MIMEType']))
      unset($payload['MIMEType']); // better to let exif default
    // TODO add these "tw_id_str":"449230816","tw_screen_name":"nature6oy"
    return $payload;
  }
  /* convert json from H5V storage to collection+json item array */
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
        case 'source':
          $href=$val;
          break;
        case 'caption':
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
}
?>
