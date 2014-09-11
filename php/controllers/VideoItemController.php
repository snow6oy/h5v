<?php
/* 
 *                      text/html   app/json  video/mp4   image/png
 * GET     /videos/:id    200         415       200        415     # SPA with :id loaded, raw vid
 * PUT     /videos/:id    415         200       415        415     # TODO better than {source:foo.mp4} use PUT /videos/foo
*  PUT     /videos        415         200       415        415     # update playlist as {id:aB0, new:value}

 * DELETE  /videos/:id    415         200       415        415     # remove from shared view
 **/
class VideoItemController {
  function canSupport($request) {
    switch($request->verb){
      case 'GET':
        switch($request->accept){
          case 'text/html':
            break;    
          case 'video/mp4':
            throw new Exception('Not Implemented', 501);          
            break;
          default:
            throw new Exception('Unsupported Media Type', 415);
        }
        break;
      case 'PUT':
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
  function getAction($request){
    if(isset($request->url_elements[1]))  // e.g. /videos/borisLegoCollection0003.mp4
      return array('read', array('source'=>$request->url_elements[1])); // call VideoItemModel->readData
    throw new Exception("Bad Request|Missing video filename in URL", 400);
  }
  function putAction($request) {
    $body=$source=null;
    if (isset($request->parameters['body']))
      $body=$request->parameters['body'];
    if(isset($request->url_elements[1]))  // trap requests like /captions/123.png
      $source=$request->url_elements[1];
    if(empty($body)||empty($source))
      throw new Exception("Bad Request|Missing Parameters '". $source. "'", 400);
    return array('update', array('body'=>$body, 'source'=>$source)); // call VideoItemModel->updateData {this:that}
  }
}
?>