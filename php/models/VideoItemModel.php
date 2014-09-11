<?php
include 'h5vIO.php';
class VideoItemModel extends h5vIO {
  function updateData($control) {
    $payload=$this->cjToH5V($control['body']);
    if(!$payload)
      throw new Exception('Bad Request|Incoming payload has unknown format', 400);
    // TODO determine video type at run-time
    $payload['source']=$control['source']. '.mp4';
    // TODO add these "tw_id_str":"449230816","tw_screen_name":"nature6oy"
    $params=json_encode($payload);
    $content_type='application/json';
    $path='playlists.pl';
    $method='PUT';
    $data=array();
    $json=json_decode($this->request($content_type, $path, $params, $method));
    if(property_exists($json, "status") && $json->status==201){
      return array('status'=>201, 'location'=>$json->location);
    } else if(property_exists($json, "status") && $json->status==200){
      return array('status'=>200);
    } else if(isset($json)){
      throw new Exception('Internal Server Error|'. $json->message, $json->status);
    }
    throw new Exception('Internal Server Error', 500);
  }
  function readData($control){
    $control['source']=$control['source']. '.mp4';
    return $control;    
  }
}
?>