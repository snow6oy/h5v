<?php
$t='/tmp/phpAweFGA5df9';
// we want AweFGA5df9

if(preg_match('/^\/tmp\/php(.+)$/', $t, $matches)){
  $fn=$matches[1];
} else{
  print "fail\n";
}
print $fn. "\n";
?>
