<?php
/* 
 *                    text/html   app/json  video/mp4   image/png
 *  POST  /videos        415         415       202        415     # mp4 uploader
 *  PUT   /videos        415         201       415        415     # mp4 uploader
 *
 *  controller for these not done yet
 *  GET   /videos        415         200       415        415     # random three as uber. html for search engine?
 *  GET     /captions/:id  415         415       415        200     # static image (OR maybe /videos/:id Accept:image/png)
 **/
class VideosController {
  function canSupport($request) {
    switch($request->verb){
      case 'PUT':
        switch($request->accept){
          case 'application/json':          
            break;
          default:
            throw new Exception('Unsupported Media Type', 415);
        }      
        break;        
      case 'POST':
        switch($request->accept){
          case 'video/mp4':
            break;
          default:
            throw new Exception('Unsupported Media Type', 415);
        }      
        break;
      default:
        throw new Exception('Method Not Allowed|'. $request->verb, 405);
    }
    return true;
  }
  function putAction($request){
    $body=null;
    if (isset($request->parameters['body'])){
      $body=$request->parameters['body'];
    }
    return array('meta', array('body'=>$body, 'method'=>'PUT', 'status'=>'201'));
  }  
  /* video uploader code ... deep breath
   * POST /videos/ HTTP/1.1
   * Host: dishyzee.com
   * Accept: text/html,application/xhtml+xml,application/xml;q=0.9 etcetera
   * Accept-Encoding: gzip, deflate
   * Content-Length: 3256992
   * Content-Type: multipart/form-data; boundary=---------------------------19990871613338
   * Cookie: PHPSESSID=3994449e69b3b50da4240d9bb94a2896
   * Connection: keep-alive
   * Content-Disposition: form-data; name="myFile"; filename="barralCellar.jpg" Content-Type: image/jpeg
   * POST Content-Length of 8566470 bytes exceeds the limit of 8388608 bytes (8 mbs)
   * /etc/php5/apache2/php.ini is 8 MB but files of 2.3 MB throw error->[1]
   * $_FILES[something]
   *        [name] => dizzy.mp4
   *        [type] => video/mp4
   *        [tmp_name] => /tmp/phpF7nL9H
   *        [error] => 0
   *        [size] => 1599094
   **/

  function postAction($request){
    $error=array( 
      0=>"There is no error, the file uploaded with success", 
      1=>"The uploaded file exceeds the upload_max_filesize directive in php.ini", 
      2=>"The uploaded file exceeds the MAX_FILE_SIZE directive that was specified in the HTML form",
      3=>"The uploaded file was only partially uploaded", 
      4=>"No file was uploaded",
      5=>"Odd, there is no five?",
      6=>"Missing a temporary folder"
    );
    $this->sessionOk();
    // $upFilename=$_SESSION['access_token']['user_id'];
    $upFile="449230816";      // FAKE IT
    if(!isset($_FILES[$upFile]))
      throw new Exception("Bad Request|Missing content", 400);      
    if($_FILES[$upFile]['error']){
      $code=$_FILES[$upFile]['error'];
      throw new Exception("Internal Server Error|". $error[$code], 500);      
    }
//    return array('createVideo', $_FILES[$upFile]);
    return array('createVideo', $upFile);
  }
  function sessionOk(){
    // If access tokens are not available drop out.
    if(empty($_SESSION['access_token']) 
    || empty($_SESSION['access_token']['oauth_token']) 
    || empty($_SESSION['access_token']['oauth_token_secret'])) {
      throw new Exception('Authorization Required|Video was not uploaded', 401);
      return false;
    }
    return true;
  }  

  /*
  function putAction($request){
    $body=null;
    if (isset($request->parameters['body'])){
      $body=$request->parameters['body'];
    }
    return array('meta', array('body'=>$body, 'method'=>'PUT', 'status'=>'200'));
  }
    */
  /* can be GET /videos or GET /videos/:id 
  function getAction($request) {
    $id=null;
    if (isset($request->parameters['id'])) {
      $id=$request->parameters['id'];
    }
    return array('playlist', $id); // call Model->playlistData
  }
  
   * TODO decide if /videos/:id should move to VideoItemController.php
   */  
}
?>