package H5V::Test;
use parent 'H5V';
use strict;
use Data::Dumper;
use File::Compare;

sub new{
  my $proto=shift;
  my $class=ref($proto)||$proto;
  my $self={};
  bless ($self, $class);
  return $self;
}

# usage $t->get_before_after($0)
# relative to BASE_DIR/tests
# ./selectVideoItem/getVideoItem.pl
sub get_before_after{
  my ($self, $scriptName)=@_;

  $scriptName=~s#^\./([^/]+)/##;
  my $testGroup=$1;
  $scriptName=~s/\.pl$/.txt/;

  my $aft='/tmp/'. $scriptName;
  $self->{AFTER}=$aft;
  unlink $aft; # clear up from previous run

  my $base_dir=$self->conf('BASE_DIR');
  $self->{BEFORE}=$base_dir. '/tests/'. $testGroup. '/'. $scriptName;
  return 1;
}

sub set_after{
  my ($self, $data)=@_;
  my $aft=$self->{AFTER};
  open(RESPONSE, ">>$aft") or die $!;
  print RESPONSE $data;
  close RESPONSE;
}

sub cmp_before_after{
  my $self=shift;
  my $aft=$self->{AFTER};
  my $bfr=$self->{BEFORE};
  my $result=(compare($aft, $bfr)==0) ? "Ok" : "FAIL" ;
  return $result. "\n";
}

# expose config
sub conf{
  my($self, $param)=@_;
  return $self->SUPER::CONF->{$param};
}
1;
