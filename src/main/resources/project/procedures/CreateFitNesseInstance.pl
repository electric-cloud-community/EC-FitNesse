##########################
# CreateFitNesseInstance.pl
##########################
use warnings;
use strict;
use Encode;
use utf8;
use open IO => ':encoding(utf8)';
use ElectricCommander;

my $opts;

$opts->{java_path}     = qq{$[java_path]};
$opts->{java_args}     = qq{$[java_args]};
$opts->{fitnesse_jar}  = qq{$[fitnesse_jar]};
$opts->{fitnesse_root} = qq{$[fitnesse_root]};
$opts->{instance_port} = qq{$[instance_port]};
$opts->{timeout}       = qq{$[timeout]};

$[/myProject/procedure_helpers/preamble]

$fitnesse->createFitNesseInstance();
if ($opts->{exitcode}) {
    exit($opts->{exitcode});
}
1;
