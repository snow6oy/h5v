<?php
/* Load required lib files. */
session_start();
require_once('../twitteroauth/twitteroauth.php');
require_once('../config.php');
/* If access tokens are not available drop out. */
if(empty($_SESSION['access_token']) 
|| empty($_SESSION['access_token']['oauth_token']) 
|| empty($_SESSION['access_token']['oauth_token_secret'])) {
  header('Content-Type: application/json', TRUE, 401);
  echo json_encode(array('error'=>'401 Unauthorized'));
  exit;
}
/* still here? ok lets upload a video */
$errorCodes=array( 
  0=>"There is no error, the file uploaded with success", 
  1=>"The uploaded file exceeds the upload_max_filesize directive in php.ini", 
  2=>"The uploaded file exceeds the MAX_FILE_SIZE directive that was specified in the HTML form",
  3=>"The uploaded file was only partially uploaded", 
  4=>"No file was uploaded",
  6=>"Missing a temporary folder"
);
/* hook Filename up to user_id */
$upFilename=$_SESSION['access_token']['user_id'];
$upFile=$_FILES[$upFilename];
if(isset($upFile)){
  $error=$upFile['error'];
  if($error){
    $data=array('error'=>$errorCodes[$error]);
    header('Content-Type: application/json', TRUE, 500);
  }else{
    move_uploaded_file($upFile['tmp_name'], BASE_DIR. '/incoming/' . $upFile['name']);
    $data=array('status'=>'Accepted');
    header('Content-Type: application/json', TRUE, 202);
  }
}else{
  $data=array('error'=>'unknown error');
  header('Content-Type: application/json', TRUE, 500);
}
echo json_encode($data);
exit;
/* file metadata
 * Content-Disposition: form-data; name="myFile"; filename="barralCellar.jpg" Content-Type: image/jpeg
 * POST Content-Length of 8566470 bytes exceeds the limit of 8388608 bytes (8 mbs)
 * http://us3.php.net/manual/en/ini.core.php#ini.post-max-size
 * Maximum size of POST data that PHP will accept.
 * http://php.net/post-max-size
 * post_max_size = 8M
 * /etc/php5/apache2/php.ini

 * but despite the contents of php.ini 2528 KBs is disallowed
 * 1562 KBs is known to be ok 
 **/
?>