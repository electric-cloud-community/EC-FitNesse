##########################
# RunTestOnNewInstance.pl
##########################
use warnings;
use strict;
use Encode;
use utf8;
use open IO => ':encoding(utf8)';
use ElectricCommander;

my $opts;

$opts->{java_path}     = q{$[java_path]};
$opts->{java_args}     = q{$[java_args]};
$opts->{fitnesse_jar}  = q{$[fitnesse_jar]};
$opts->{fitnesse_root} = q{$[fitnesse_root]};
$opts->{instance_port} = q{$[instance_port]};
$opts->{target_page}   = q{$[target_page]};
$opts->{target_type}   = q{$[target_type]};
$opts->{results}       = q{$[results]};
$opts->{timeout}       = q{$[timeout]};

$[/myProject/procedure_helpers/preamble]

$fitnesse->runTestOnNewInstance();
if ($opts->{exitcode}) {
    exit($opts->{exitcode});
}
1;
