<?php
/* 
 * video data model
 **/
include 'h5vIO.php';
class VideosModel extends h5vIO {
// $control is ignored at the moment but will include run-time data from user
  function playlistData($control){
    $content_type='application/json';
    $path='playlists.pl';
    $params=null;
    $method='GET';
    return $this->request($content_type, $path, $params, $method);
  }
  function createVideoData($control){
    $file=$_FILES[$control];
    if(preg_match('/^\/tmp\/php(.+)$/', $file['tmp_name'], $matches)){
      $fn=$matches[1]. '.mp4';
    } else{
      throw new Exception('Internal Server Error|Upload error', 500);
    }
    move_uploaded_file($file['tmp_name'], BASE_DIR. '/incoming/'. $fn);
    $data=array();
    $data['status']=202;
    $data['title']='Accepted';
    $data['message']=$file['name']. ' uploaded ok. Add metadata to create resource';
    return array("href"=>SERVICE_URL. '/videos/'. $fn, "data"=>array($data));
  }
  function metaData($control){
    $content_type='application/json';
    $path='playlists.pl';
    $method=$control['method'];
    $payload=$this->cjToH5V($control['body']);
    if(!$payload)
      throw new Exception('Bad Request|Incoming payload has unknown format', 400);
    $params=json_encode($payload);
    $json=json_decode($this->request($content_type, $path, $params, $method));
    if(property_exists($json, "status") && $json->status==201){
      return array('status'=>201, 'location'=>$json->location);      
    } else if(isset($json)){
      throw new Exception('Internal Server Error|'. $json->message, $json->status);
    }
    throw new Exception('Internal Server Error', 500);
  }
  /* internal testing */
  function testApiIOData($control) {
    $headers='text/plain';
    $params=null;
    $path='/hello.pl';
    $json=$this->request($headers, $path, $params, null);
    $json_data=json_decode($json);
    $json_data['code']=200;
    return json_encode($json_data);
  }
}
?>