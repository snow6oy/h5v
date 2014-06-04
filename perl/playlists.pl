#!/usr/bin/perl
use Data::Dumper;
print <<EOF;
Content-type: plain/text

EOF
print Dumper \%ENV;