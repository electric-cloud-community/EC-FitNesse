##########################
# StopFitNesseInstance.pl
##########################
use warnings;
use strict;
use Encode;
use utf8;
use open IO => ':encoding(utf8)';
use ElectricCommander;

my $opts;

$opts->{fitnesse_host} = q{$[fitnesse_host]};
$opts->{instance_port} = q{$[instance_port]};
$opts->{timeout}       = q{$[timeout]};

$[/myProject/procedure_helpers/preamble]

$fitnesse->stopFitNesseInstance();
if ($opts->{exitcode}) {
    exit($opts->{exitcode});
}
1;
