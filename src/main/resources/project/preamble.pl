use ElectricCommander;
use File::Basename;
use ElectricCommander::PropDB;
use ElectricCommander::PropMod;
use Encode;
use utf8;

local $| = 1;

use constant {
    SUCCESS => 0,
    ERROR   => 1,
};

# Create ElectricCommander instance
my $ec = ElectricCommander->new();
$ec->abortOnError(0);


my $pluginKey  = 'EC-FitNesse';
my $xpath      = $ec->getPlugin($pluginKey);
my $pluginName = $xpath->findvalue('//pluginVersion')->value;
print "Using plugin $pluginKey version $pluginName\n";
$opts->{pluginVer} = $pluginName;
$opts->{JobStepId} =  "$[/myJobStep/jobStepId]";

# Load the actual code into this process
if (!ElectricCommander::PropMod::loadPerlCodeFromProperty($ec, '/myProject/fitnesse_driver/FitNesse'))
{
    print 'Could not load FitNesse.pm\n';
    exit ERROR;
}

# Make an instance of the object, passing in options as a hash
my $fitnesse = FitNesse->new($ec, $opts);


