<?php
/* 
 *                      text/html   app/json  video/mp4   image/png
 *  GET     /search?term=x 415         200       415        415     # filtered results as uber
 **/
class SearchController {
  function canSupport($request) {
    switch($request->verb){
      case 'GET':
        switch($request->accept){
          case 'application/json':
            break;
          default:
            throw new Exception('Unsupported Media Type', 415);
        }
        break;
      default:
        throw new Exception('Method Not Allowed', 405);
    }
    return true;
  }
  function getAction($request) {
    $query=null;
    if(isset($request->parameters['term'])){
      $query=$request->parameters['term']; /* blank query returns random */
    } /* else{
      throw new Exception('Bad Request - Missing Search Term', 400);
    }*/
    return array('search', $query);
  }
}
?>