<?php
/*
 * @file
 * A single location to store configuration.
 * keys from dev.twitter.com @dishyzee
 **/
define('CONSUMER_KEY', 'mBADgvTeYbjlBULmV1C3goFOm');
define('CONSUMER_SECRET', 'KVElLbsgl56YB6p1dj8PDAYJcR0kNf2Esh2KDkQQHw0H23Fdjh');
define('OAUTH_CALLBACK', 'http://'. $_SERVER['HTTP_HOST']. '/callback.php');
/*
 * environment setup
 * rudy.local OR dishyzee.com 
 **/

define('BASE_DIR', '/opt/git/h5v');
define('SERVICE_URL', 'http://rudy.local');
define('API_URL', 'http://api.rudy.local/cgi-bin/');

/*
if($_SERVER['HTTP_HOST']=='rudy.local'){
  define('TEST_TMPL', '/opt/git/h5v/templates/test.html');
  define('LIVE_TMPL', '/opt/git/h5v/templates/index.html');
}else{ 
  define('BASE_DIR', '/home/dishyzee/h5v');  
  define('SERVICE_URL', 'http://dishyzee.com');
  define('API_URL', 'http://api.dishyzee.com/cgi-bin/');

  define('TEST_TMPL', '/home/dishyzee/h5v/templates/test.html');
  define('LIVE_TMPL', '/home/dishyzee/h5v/templates/index.html');
}
*/
