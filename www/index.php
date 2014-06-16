<?php
/*
 *  200 Ok
 *  405 Method Not Allowed      ok = GET, POST, PUT or DELETE
 *  415 Unsupported Media Type  ok = text, html, json, mp4 or png
 **/
include 'config.php';
spl_autoload_register('classAutoload');
// Add exception handler
set_exception_handler('handleException');
$request=new Request;
session_start();
require_once('twitteroauth/twitteroauth.php');
if(CONSUMER_KEY==='' 
 || CONSUMER_SECRET===''
 || CONSUMER_KEY==='CONSUMER_KEY_HERE'
 || CONSUMER_SECRET === 'CONSUMER_SECRET_HERE'){
  echo 'You need a consumer key and secret to test the sample code. Get one from <a href="https://dev.twitter.com/apps">dev.twitter.com/apps</a>';
  exit; /* Exit with an error message if the config does not define either CONSUMER_KEY or CONSUMER_SECRET */
}
if(isset($_SESSION['access_token'])){       /* User has successfully authenticated with Twitter. Access tokens saved to session and DB. */
  $access_token=$_SESSION['access_token'];  /* Get user access tokens out of the session. */
  $connection=new TwitterOAuth(             /* Create a TwitterOauth object with consumer/user tokens. */
    CONSUMER_KEY, CONSUMER_SECRET, $access_token['oauth_token'], $access_token['oauth_token_secret']
  );
  $request->account=$connection->get('account/verify_credentials');
} else{                                     /* Testing only */
  $account=new stdClass();
  $account->{'screen_name'}="test6oy";
  $account->{'profile_image_url'}="http://pbs.twimg.com/profile_images/2284174758/v65oai7fxn47qv9nectx_normal.png";
  $account->{'id_str'}="449230816";
  $account->{'name'}="test6oy";
  $request->account=$account;

  $_SESSION['status']=true;
  $_SESSION['status']='verified';
// echo session_id(); print_r($_SESSION); echo "\n------------\n";
}
routeV1($request);

function handleException($e) {
  // pull the correct format before we bail
  global $request, $view;
  // header('Status: '. $e->getCode(), false, $e->getCode());
  header('Content-Type: application/json', false, $e->getCode());
  $view=(isset($view)) ? new $view : new JsonView;
  $view->error($e);
}

function classAutoload($classname) {
  // echo '<h2>classname '. $classname. "</h2>\n";
  if (preg_match('/[a-zA-Z]+Controller$/', $classname)) {
    include dirname(__FILE__) . '/php/controllers/' . $classname . '.php';
    return true;
  } elseif (preg_match('/[a-zA-Z]+Model$/', $classname)) {
    include dirname(__FILE__) . '/php/models/' . $classname . '.php';
    return true;
  } elseif (preg_match('/[a-zA-Z]+View$/', $classname)) {
    include dirname(__FILE__) . '/php/views/' . $classname . '.php';
    return true;
  }
}
/* 
 * route the request to the right place
 **/
function routeV1($request) {
  global $view; // set the view first in case of thrown errors
  $view_name=ucfirst($request->format) . 'View';
  // echo 'view:'. $view_name. "\n";
  if(class_exists($view_name))
    $view=new $view_name();
  // print_r($request). "\n";
  $classes=urlToClassName($request->url_elements);
  if(class_exists($classes['controller'])){
    $controller=new $classes['controller'];
    $controller->canSupport($request); // OR stop everything right here
    $action_name=strtolower($request->verb). 'Action';
    $control=$controller->$action_name($request);
  } else{
    throw new Exception('Not Found', 404);
  }
  // echo 'model:'. $classes['model']. "\n";
  if (class_exists($classes['model'])) {
    $model=new $classes['model'];
    $data_name=array_shift($control). 'Data';
  }
  $result=$model->$data_name(array_shift($control));
  $view->render($result);
}
/* 
 * url_elements[0] => '', [1] => index.php, [2] => /abc [3] => /xyz
 * /abc = AbcsClass /abc/xyz = AbcItemClass or HomeController if empty
 **/
function urlToClassName($elem){
  $noun=null;
  $known_urls=array('videos', 'search', 'captions');
  if(empty($elem))
    $noun='Home';
  if(in_array($elem[0], $known_urls)){
    if(isset($elem[1])&& $elem[0]=='videos'){
      $noun='VideoItem';
    } else if(isset($elem[1])&& $elem[0]=='captions'){
      $noun='CaptionItem';
    } else{
      $noun=ucfirst($elem[0]);
    }
  }
  return array(
    'controller'=>$noun. 'Controller',
    'model'=>$noun. 'Model'
  );
}

class Request {
  public $url_elements;
  public $verb;
  public $accept;
  public $parameters;
  public function __construct() {
    $this->verb=$_SERVER['REQUEST_METHOD'];
    if(isset($_SERVER['PATH_INFO'])){
      $this->url_elements=preg_split('/\//', $_SERVER['PATH_INFO'], -1, PREG_SPLIT_NO_EMPTY);
    }
    // initialise html as default format
    $this->format='html';
    $this->parseIncomingParams();
    /* do we need this - why would users request a different format in a cgi request ?? */
    if (isset($this->parameters['format'])) {
      $this->format=$this->parameters['format'];
    }
    return true;
  }
  public function parseIncomingParams() {
    $parameters=array();
    // first of all, pull the GET vars
    if (isset($_SERVER['QUERY_STRING'])) {
      parse_str($_SERVER['QUERY_STRING'], $parameters);
    }
    // now how about PUT/POST bodies? These override what we got from GET
    $body=file_get_contents('php://input');
    // this used to be content-type
    $http_accept=null;
    if(isset($_SERVER['HTTP_ACCEPT'])){
      // firefox sends accept header as >>text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8<<
      $http_accept=array_shift(explode(',', $_SERVER['HTTP_ACCEPT']));
      $this->accept=$http_accept; // for closer inspection later
    }
    switch($http_accept) {
      case 'text/plain':
        $this->format='text';
        break;
      case '*/*':  
      case 'text/html':
        $parameters['body']=$body;
        $this->format='html';
        break;
      case 'application/json':
        $parameters['body']=$body;
        $this->format='json';
        break;
      case 'video/mp4':
      /* this is a content-type not an Accept header
      case 'application/x-www-form-urlencoded':
        parse_str($body, $postvars);
        foreach($postvars as $field => $value) {
          $parameters[$field]=$value; 
        } */
        $this->format='json'; // quick fix for uploader
        break;
      case 'image/png':
        $this->format='png';
	break;
      default:
        throw new Exception('Unsupported Media Type', 415);
        break;
    }
    $this->parameters=$parameters;
  }
}
/*
 * inspiration from
 * http://www.lornajane.net/posts/2012/building-a-restful-php-server-understanding-the-request
 **/
?>
