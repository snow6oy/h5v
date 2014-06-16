<?php
/* 
 *                      text/html   app/json  video/mp4   image/png
 *  GET   /                200         200       415        415     # SPA, uber home doc
 *  POST, PUT, DELETE      405
 **/
class HomeController {
  function canSupport($request) {
    switch($request->verb){
      case 'GET':
        // echo 'get'. "\n";
        switch($request->accept) {
          case '*/*':
          case 'text/html':
          case 'application/json':          
            // echo 'accepted'. "\n";
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
    return 
      array(
        'home', 
        array(
          'addLinks'=>true, /* addLinks triggers a JSON homepage in hypermedia style */
          'screen_name'=>@$request->account->{'screen_name'}, /* the @ is to supress warnings in dev */
          'profile_image_url'=>@$request->account->{'profile_image_url'}, 
          'id_str'=>@$request->account->{'id_str'},
          'name'=>@$request->account->{'name'}
        )
      );
  }
}
?>
