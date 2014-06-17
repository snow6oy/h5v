<?php
/* JsonView is passed a json encoded string from apiIO or
 * an array. we check the array for $status_code. 
 * leaving it empty has nasty side affect as header then defaults to text/html  
 *      [status] => Accepted
 *      [code] => 202
 *      [name] => blackberry-test7-wavetlan-com.mp4 uploaded ok
 **/
class JsonView {
  public function render($content){
    $doc=$this->cjDoc(); // create a template 
    // determine the status
    if(isset($content['data'][0]['status'])){
      $status=$content['data'][0]['status'];
    } else if(isset($content['status'])){
      $status=$content['status'];
    } else{
      $status=200; // optimistic?
    }
    // prepare for the worst
    $error=(isset($content['title'])&& $status>=500) ?
      $content['title']. '|'. $content['message'] :
      'Internal Server Error';
    /* set navigational links only for homepage json
    if(isset($content['addLinks'])&& $content['addLinks']){ // replace the items with links section. if requested
      unset($content['addLinks']); // remove boolean from payload
      $content=$doc['collection']['items']; // swap it out and then put it back .. crazy huh?
    } else{
      unset($doc['collection']['links']);
    } */
    // dump header and content based on status
    switch($status){
      case 200:
      case 202:
        $doc['collection']['items']=$content;
        header('Content-Type: application/vnd.collection+json; charset=utf8', TRUE, $status); 
        echo json_encode($doc);          
        break;
      case 201:
        header('Location: '. $content['location'], TRUE, $status);
        break;
      case 500:
        throw new Exception($error, 500);
      default:
        throw new Exception('Unknown Error', $status);
    }
    return true;      
  }
  public function error($e){
    $doc=array('collection'=> 
      array(
        "version"=>"1.0",
        "href"=>SERVICE_URL. "/"
      ),
    );
    /* use a | to split title from message */
    if(preg_match('/^(.+)\|(.*)$/', $e->getMessage(), $matches)){
      $t=$matches[1];
      $m=$matches[2];
    } else{
      $t=$e->getMessage();
      $m="";
    }
    $doc['collection']['error']=array(
      'title'=>$t,
      'code'=>$e->getCode(), 
      'message'=>$m /* custom fault */
    );
    header('Content-Type: application/vnd.collection+json; charset=utf8', TRUE, $e->getCode());    
    echo json_encode($doc);
    return true;
  }
  // template for a Collection+JSON document
  function cjDoc() {
    $qdata=array(
      'name'=>"term",
      'value'=>""
    );
    $queries=array(
      "href"=>SERVICE_URL. "/index.php/search",
      "rel"=>"search",
      "prompt"=>"Enter search term or empty for random",
      "data"=>array($qdata)
    );
    $tdata=array(
      array("name"=>"title",    "prompt"=>"Track Title"),
      array("name"=>"artist",   "prompt"=>"Artist"),
      array("name"=>"genre",    "prompt"=>"Genre"),                
      array("name"=>"album",    "prompt"=>"Album"),
      array("name"=>"track",    "prompt"=>"Track#"),
      array("name"=>"producer", "prompt"=>"Producer"),
      array("name"=>"rating",   "prompt"=>"Rating"),
      array("name"=>"scope",    "prompt"=>"Shared With"),
      array("name"=>"mediatype","prompt"=>"Media Type")
    );
    $ldata=array(
      array("href"=>SERVICE_URL. "/",                      "rel"=> "self",    "prompt"=> "Home",                  "render"=> "link"),
      array("href"=>SERVICE_URL. "/",                      "rel"=> "index",   "prompt"=> "View Homepage",         "render"=> "link"),
      array("href"=>SERVICE_URL. "/index.php/videos",      "rel"=> "upload",  "prompt"=> "Upload Video",          "render"=> "image"),
      array("href"=>SERVICE_URL. "/index.php/videos",      "rel"=> "edit",    "prompt"=> "Create Video Metadata", "render"=> "link"),
      array("href"=>SERVICE_URL. "/index.php/videos/{id}", "rel"=> "item",    "prompt"=> "View Video",            "render"=> "image"),
      array("href"=>SERVICE_URL. "/index.php/videos/{id}", "rel"=> "item",    "prompt"=> "View Video Page",       "render"=> "link"),
      array("href"=>SERVICE_URL. "/index.php/videos/{id}", "rel"=> "edit",    "prompt"=> "Edit Video Metadata",   "render"=> "link"),
      array("href"=>SERVICE_URL. "/index.php/videos/{id}", "rel"=> "delete",  "prompt"=> "Remove Video From View","render"=> "link"),
      array("href"=>SERVICE_URL. "/captions/{id}",         "rel"=> "caption", "prompt"=> "View Video Caption",    "render"=> "image")
    );
    return array('collection'=> 
      array(
        "version"=>"1.0",
        "href"=>SERVICE_URL. "/",
        'links'=>$ldata,
        'template'=>array("data"=>$tdata),
        'queries'=>array($queries)        
      ),
    );
  }  
}
?>
