<?php
class TextView {
  public function render($content){
    header('Content-Type: text/plain; charset=utf8');
    print_r($content);
  }
  public function error($content){
    header('Content-Type: text/plain; charset=utf8'); 
    echo $content->getCode(). ' '. $content->getMessage(). "\n";
/*
    echo '-d-e-b-u-g-g-e-r---------------------------------------------------'. "\n";
    echo '-------------------------------------------------------------------'. "\n";    
    print_r($content);
    echo '-------------------------------------------------------------------'. "\n";
*/
    return true;
  }
}
?>
