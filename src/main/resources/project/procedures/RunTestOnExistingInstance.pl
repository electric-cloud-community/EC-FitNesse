##########################
# RunTestOnExistingInstance.pl
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
$opts->{target_page}   = q{$[target_page]};
$opts->{target_type}   = q{$[target_type]};
$opts->{results}       = q{$[results]};
$opts->{stop_instance} = q{$[stop_instance]};
$opts->{timeout}       = q{$[timeout]};

$[/myProject/procedure_helpers/preamble]

$fitnesse->runTestOnExistingInstance();
if ($opts->{exitcode}) {
    exit($opts->{exitcode});
}
1;
