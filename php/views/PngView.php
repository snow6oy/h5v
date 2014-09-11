<?php

class PngView {
  public function render($src){
    // echo '<img src="', $src, '">';
    $replace_header=true;
    if($src){
      echo $src;
    } else{
      header('Content-Type: text/html', $replace_header, 404); 
    }
  }
}
?>
