<?php
/* 
 * provides html or json content for home page
 **/
class HomeModel {
  function homeData($control) {
    return $control; // pass addLinks boolean to JsonView. HtmlView ignores it 
  }
}
?>