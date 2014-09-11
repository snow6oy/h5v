<?php
$a='text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8';
$b=explode(',', $a);
$c=array_shift($b);
$d=array_shift(explode(',', $a));
echo $a. "\n";
print_r($b);
print $c. "\n";
print $d. "\n";
?>
