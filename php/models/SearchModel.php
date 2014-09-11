<?php
/*
 * search videos on user input
 **/
include 'h5vIO.php';
class SearchModel extends h5vIO {
  function searchData($control) {
    $content_type='application/json';
    $path='search.pl';
    $params=$control;
    $method='GET';
    $playlist=json_decode($this->request($content_type, $path, $params, $method));
    $items=array();
    foreach($playlist as $p){
      array_push($items, $this->jsonToItem($p));
    }
    return $items;
  }
}
?>