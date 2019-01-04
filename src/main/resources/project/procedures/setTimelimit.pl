##########################
# setTimelimit.pl
##########################
use strict;
use warnings;
use ElectricCommander;

use constant {
    FALSE => 0,
    TRUE  => 1,

    DEFAULT_TIMEOUT          => '',
    DEFAULT_TIMEOUT_LOCATION => '/myCall/fitnesse_timelimit',
             };

my $ec = ElectricCommander->new();
$ec->abortOnError(0);

my $timelimit = ($ec->getProperty("/myCall/timeout"))->findvalue('//value')->string_value;

if (!defined($timelimit) || !isNumber($timelimit) || $timelimit <= 0) {
    $timelimit = DEFAULT_TIMEOUT;
}

my $setResult = $ec->setProperty(DEFAULT_TIMEOUT_LOCATION, $timelimit);

if ($setResult eq '') {
    print "An error occured when setting timeout to step\n";
}
else {
    if ($timelimit eq '') {
        print "No timeout set\n";
    }
    else {
        print "Timeout set to $timelimit minute(s)\n";
    }
}

###############################
# isNumber - Determine if a variable is a number or not
#
# Arguments:
#   var
#
# Returns:
#   1 if true, 0 false
#
################################
sub isNumber {
    my ($var) = @_;
    if ($var =~ /^[+-]?\d+$/) {
        return TRUE;
    }
    else {
        return FALSE;
    }
}

1;