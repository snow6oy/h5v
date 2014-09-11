<?php
// $t='Success|File upload ok';
$t='Internal Server Error';

if(preg_match('/^(.+)\|(.+)$/', $t, $matches)){
  $c=$matches[1];
  $d=$matches[2];
} else{
  $c=$t;
  $d="";
}
print $c. "\n";
print $d. "\n";
?>
