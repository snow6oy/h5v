<?php

$errorCodes=array( 
  0=>"There is no error, the file uploaded with success", 
  1=>"The uploaded file exceeds the upload_max_filesize directive in php.ini", 
  2=>"The uploaded file exceeds the MAX_FILE_SIZE directive that was specified in the HTML form",
  3=>"The uploaded file was only partially uploaded", 
  4=>"No file was uploaded",
  6=>"Missing a temporary folder"
); 

if(isset($_FILES['myFile'])){
  $error=$_FILES['myFile']['error'];
  if($error){
    $data=array('error'=>$errorCodes[$error]);
    header('Content-Type: application/json', TRUE, 500);
  }else{
    move_uploaded_file( $_FILES['myFile']['tmp_name'], "/opt/git/h5v/incoming/" . $_FILES['myFile']['name']);
    $data=array('body'=>'Created','location'=>'/video/:id','error'=>$error);
    header('Content-Type: application/json', TRUE, 201);
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