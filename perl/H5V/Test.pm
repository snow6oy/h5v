package H5V::Test;
use parent 'H5V';
use strict;
use Data::Dumper;
use File::Compare;

sub new{
  my $proto=shift;
  my $class=ref($proto)||$proto;
  my $scriptName=shift;
  my $self=init($scriptName);
  bless ($self, $class);
  return $self;
}

# usage $t->get_before_after($0)
# relative to BASE_DIR/tests
# ./selectVideoItem/getVideoItem.pl
sub init{
  # my ($self, $scriptName)=@_;
  my $scriptName=shift;
  my $self;
  $scriptName=~s#^\./([^/]+)/##;
  my $testGroup=$1;
  $scriptName=~s/\.pl$/.txt/;

  my $aft='/tmp/'. $scriptName;
  $self->{AFTER}=$aft;
  unlink $aft; # clear up from previous run

  $self->{BEFORE}='/tests/'. $testGroup. '/'. $scriptName;
  return $self;
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
  my $base_dir=$self->conf('BASE_DIR');
  my $bfr=$base_dir. $self->{BEFORE};
  my $result=(compare($aft, $bfr)==0) ? "Ok" : "FAIL" ;
  return $result. "\n";
}

# expose some parent methods
sub conf{
  my($self, $param)=@_;
  return $self->SUPER::CONF->{$param};
}
sub web_to_file{
  my($self, $f)=@_;
  return $self->SUPER::web_to_file($f);
}
#
1;
