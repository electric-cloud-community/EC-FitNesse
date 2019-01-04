# -------------------------------------------------------------------------
# Package
#    FitNesse.pm
#
# Purpose
#    Run FitNesse tests and suites from Electric Commander
#
# Plugin Version
#    1.0
#
# Date
#    03/16/2012
#
# Engineer
#    Andres Arias
#
# Copyright (c) 2011 Electric Cloud, Inc.
# All rights reserved
# -------------------------------------------------------------------------

package FitNesse;

# -------------------------------------------------------------------------
# Includes
# -------------------------------------------------------------------------
use warnings;
use ElectricCommander::PropDB;
use strict;
use lib $ENV{COMMANDER_PLUGINS} . '/@PLUGIN_NAME@/agent/lib';
use Cwd;
use LWP::UserAgent;
use MIME::Base64;
use Encode;
use utf8;
use Net::Ping;
use open IO => ':encoding(utf8)';

use Readonly;
use XML::XPath;
use Data::Dumper;
use Proc::Background;
use File::Path qw(mkpath);

# -------------------------------------------------------------------------
# Constants
# -------------------------------------------------------------------------

Readonly my $DEFAULT_DEBUG => 1;       
Readonly my $ERROR => 1;      
Readonly my $SUCCESS => 0;             
             

# -------------------------------------------------------------------------
# Globals
# -------------------------------------------------------------------------
$::broswer = undef;       # used to hold the main browser object
$::cwd     = getcwd();    # used to hold the main browser object

################################
# new - Object constructor for FitNesse
#
# Arguments:
#   opts hash
#
# Returns:
#   -
#
################################

sub new {
    my $class = shift;
    my $self = {
                 _cmdr => shift,
                 _opts => shift,
               };
    bless $self, $class;
}

###############################
# myCmdr - Get ElectricCommander instance
#
# Arguments:
#   none
#
# Returns:
#   ElectricCommander instance
#
###############################
sub myCmdr {
    my ($self) = @_;
    return $self->{_cmdr};
}

################################
# opts - Get opts hash
#
# Arguments:
#   -
#
# Returns:
#   opts hash
#
################################
sub opts {
    my ($self) = @_;
    return $self->{_opts};
}

################################
# ecode - Get exit code
#
# Arguments:
#   -
#
# Returns:
#   exit code number
#
################################
sub ecode {
    my ($self) = @_;
    return $self->opts()->{exitcode};
}

################################
# initialize - Set initial values
#
# Arguments:
#   -
#
# Returns:
#   -
#
################################
sub initialize {
    my ($self) = @_;

    $self->{_props} = ElectricCommander::PropDB->new($self->myCmdr(), "");

    # Set defaults
    $self->opts->{debug}    = $DEFAULT_DEBUG;
    $self->opts->{exitcode} = $SUCCESS;
    $self->opts->{JobId}    = $ENV{COMMANDER_JOBID};

    return;
}

###############################
# validateParams - validate parameters
#
# Arguments:
#   none
#
# Returns:
#   none
#
###############################
sub validateParams {

    my ($self) = @_;

    my $dir;

    if ($self->opts->{fitnesse_jar} =~ m/(.*)(fitnesse.jar)/imsg) {
        $self->opts->{fitnesse_jar} = $1;
    }

    chdir $self->opts->{fitnesse_jar};
    $dir = $self->opts->{fitnesse_jar};

    if ($self->opts->{fitnesse_root} =~ m/^$dir.*/imsg) {
        $self->opts->{fitnesse_root} =~ s/$dir//imsg;
    }

    return;
}

###############################
# myProp - Get PropDB
#
# Arguments:
#   none
#
# Returns:
#   PropDB
#
###############################
sub myProp {
    my ($self) = @_;
    return $self->{_props};
}

###############################
# setProp - Use stored property prefix and PropDB to set a property
#
# Arguments:
#   location - relative location to set the property
#   value    - value of the property
#
# Returns:
#   setResult - result returned by PropDB->setProp
#
###############################
sub setProp {
    my ($self, $location, $value) = @_;
    my $setResult = $self->myProp->setProp($self->opts->{PropPrefix} . $location, $value);
    return $setResult;
}

###############################
# getProp - Use stored property prefix and PropDB to get a property
#
# Arguments:
#   location - relative location to get the property
#
# Returns:
#   getResult - property value
#
###############################
sub getProp {
    my ($self, $location) = @_;
    my $getResult = $self->myProp->getProp($self->opts->{PropPrefix} . $location);
    return $getResult;
}

###############################
# deleteProp - Use stored property prefix and PropDB to delete a property
#
# Arguments:
#   location - relative location of the property to delete
#
# Returns:
#   delResult - result returned by PropDB->deleteProp
#
###############################
sub deleteProp {
    my ($self, $location) = @_;
    my $delResult = $self->myProp->deleteProp($self->opts->{PropPrefix} . $location);
    return $delResult;
}

################################
# createFitNesseInstance - Create a new instance
#
# Arguments:
#   -
#
# Returns:
#   -
#
################################
sub createFitNesseInstance {
    my ($self) = @_;
    $self->validateParams();
    $self->initialize();
    $self->debugMsg(1, '---------------------------------------------------------------------');
    if ($self->opts->{exitcode}) { return; }

    my $commandline;
    my $proc2;

    #-----------------------------
    # CREATE COMMAND LINE
    #-----------------------------
    $commandline = $self->createCommandLine();
    if ($self->ecode) { return; }

    #-----------------------------
    # EXECUTE COMMAND
    #-----------------------------

    $commandline = "ecdaemon -- " . $commandline;
    $self->debugMsg(1, 'Starting FitNesse instance...');
    eval {

        $proc2 = Proc::Background->new("$commandline");

    };
    if ($self->ecode) { return; }

    #-----------------------------
    # Get server name
    #-----------------------------
    my $xml      = $self->myCmdr->getProperty('/myResource');
    my $resource = $xml->findvalue('//value')->string_value;

    $resource =~ m/.*host=(.*),lastRunTime.*/ixms;
    my $hostname = $1;

    if ($hostname eq '') {
        $self->opts->{exitcode} = $ERROR;
        return;
    }

    #-----------------------------
    # Check server status
    #-----------------------------
    $self->debugMsg(5, "- Ping to server: http://" . $hostname);
    if (!$self->checkserver("http://" . $hostname)) {

        $self->debugMsg(0, "[ERROR] " . "http://" . $hostname . ":" . $self->opts->{instance_port} . " is not reachable.");
        $self->opts->{exitcode} = $ERROR;
        return;
    }
    $self->debugMsg(2, "- Ping successfull!!");

    $self->debugMsg(1, "FitNesse instance running on http://" . $hostname . ":" . $self->opts->{instance_port});

    $self->opts->{fitnesse_host} = $hostname;

    return;
}

################################
# runTestOnExistingInstance - connect to an existing instance and run tests
#
# Arguments:
#   -
#
# Returns:
#   -
#
################################
sub runTestOnExistingInstance {
    my ($self) = @_;
    $self->initialize();
    $self->debugMsg(1, '---------------------------------------------------------------------');
    if ($self->opts->{exitcode}) { return; }

    my $xml;
    $self->debugMsg(1, 'Running FitNesse Test...');

    #-----------------------------
    # Create new LWP browser
    #-----------------------------
    $::browser = LWP::UserAgent->new(agent => 'perl LWP', cookie_jar => {});

    #-----------------------------
    # Create url for request
    #-----------------------------
    $self->debugMsg(1, 'Creating REST url...');

    #http://host:port/resource?responder&inputs
    my $url_request = "http://" . $self->opts->{fitnesse_host} . ":" . $self->opts->{instance_port} . "/" . $self->opts->{target_page} . "?" . $self->opts->{target_type} . "&format=xml";

    $self->debugMsg(1, 'URL: ' . $url_request);

    $xml = $self->issueRequest("GET", $url_request, "", "");
    if ($self->ecode) { return; }

    $self->debugMsg(5, 'Response XML: \n' . $xml);

    $self->opts->{result_log} = qq{};

    if ($self->opts->{target_type} eq 'suite') {
        $self->parseSuiteXML($xml);
    }
    else {
        $self->parseTestXML($xml);
    }

    $self->myCmdr->setProperty("/myJob/logs/fitnesse_report", $self->opts->{result_log});

    #Save Results
    my $result_report;
    if ($self->opts->{results} ne '' && $self->opts->{results} =~ m/(.+\/|.+\\)(.*)\..+$/ixsmg) {

        #Save File to custom location
        $self->debugMsg(1, 'Saving results to ' . $1 . $2 . ".xml");
        $self->writeResult($1 . $2 . ".xml", $xml);
        if ($self->ecode) { warn; }

        #Save File to workspace
        $self->debugMsg(1, 'Saving results to ' . $::cwd . "/$2.xml");
        $self->writeResult($::cwd . "/$2.xml", $xml);
        if ($self->ecode) { warn; }
        $result_report = $::cwd . "/$2.xml";

    }
    else {
        $self->debugMsg(1, 'Saving results to ' . $::cwd . '/result.xml');
        $self->writeResult($::cwd . '/result.xml', $xml);
        if ($self->ecode) { warn; }
        $result_report = $::cwd . "/result.xml";

    }

    #Create Report
    $self->registerReports($result_report);

    # Stop instance after test?
    if ($self->opts->{stop_instance}) {
        $self->stopFitNesseInstance();
        if ($self->ecode) { return; }
    }

    return;
}

################################
# runTestOnNewInstance - create a new instance and run test
#
# Arguments:
#   -
#
# Returns:
#   -
#
################################
sub runTestOnNewInstance {
    my ($self) = @_;

    $self->validateParams();
    $self->initialize();
    if ($self->opts->{exitcode}) { return; }

    $self->createFitNesseInstance();
    if ($self->ecode) { return; }

    $self->runTestOnExistingInstance();
    if ($self->ecode) { return; }

    $self->stopFitNesseInstance();
    if ($self->ecode) { return; }

    return;
}

################################
# stopFitNesseInstance - shut down an existing instance
#
# Arguments:
#   -
#
# Returns:
#   -
#
################################
sub stopFitNesseInstance {
    my ($self) = @_;
    $self->initialize();
    $self->debugMsg(1, '---------------------------------------------------------------------');
    if ($self->opts->{exitcode}) { return; }

    my $xml;
    $self->debugMsg(1, 'Stopping FitNesse instance...');

    #-----------------------------
    # Create new LWP browser
    #-----------------------------
    $::browser = LWP::UserAgent->new(agent => 'perl LWP', cookie_jar => {});

    #-----------------------------
    # Create url for request
    #-----------------------------
    $self->debugMsg(1, 'Creating REST url...');

    #http://host:port/resource?responder&inputs
    my $url_request = "http://" . $self->opts->{fitnesse_host} . ":" . $self->opts->{instance_port} . "/?shutdown&format=xml";

    $self->debugMsg(1, 'URL: ' . $url_request);

    $xml = $self->issueRequest("GET", $url_request, "", "");
    if ($self->ecode) { return; }
    my $xPath = XML::XPath->new($xml);
    $self->debugMsg(5, 'Response XML: \n' . $xml);

    #-----------------------------
    # Check server status
    #-----------------------------
    $self->debugMsg(5, "- Ping to server: http://" . $self->opts->{fitnesse_host});
    if ($self->checkserver("http://" . $self->opts->{fitnesse_host})) {

        $self->debugMsg(0, "[ERROR] " . "http://" . $self->opts->{fitnesse_host} . " still running.");
        $self->opts->{exitcode} = $ERROR;
        return;
    }

    $self->debugMsg(0, "FitNesse instance at http://" . $self->opts->{fitnesse_host} . ":" . $self->opts->{instance_port} . " stopped successfully.");

    return;
}

# -------------------------------------------------------------------------
# Helper functions
# -------------------------------------------------------------------------

################################
# createCommandLine - create the command line to create a new instance
#
# Arguments:
#
#   -
#
# Returns:
#   -
#
################################
sub createCommandLine {
    my ($self) = @_;

    $self->debugMsg(1, 'Creating command for new FitNesse instance...');

    my @cmd;

    #java
    if (!$self->IsEmptyOrNull($self->opts->{java_path})) {
        my $java = $self->opts->{java_path};
        push(@cmd, qq{"$java/java"});
    }
    else {
        push(@cmd, 'java');
    }

    #java extra args
    if (!$self->IsEmptyOrNull($self->opts->{java_args})) {
        push(@cmd, $self->opts->{java_args});
    }
    push(@cmd, '-jar');

    #fitnesse.jar
    if (!$self->IsEmptyOrNull($self->opts->{fitnesse_jar})) {
        push(@cmd, 'fitnesse.jar');
    }

    #port
    if (!$self->IsEmptyOrNull($self->opts->{instance_port})) {
        push(@cmd, '-p ' . $self->opts->{instance_port});
    }

    #root
    if (!$self->IsEmptyOrNull($self->opts->{fitnesse_root})) {
        push(@cmd, '-d ' . $self->opts->{fitnesse_root});
    }

    #generate the command to execute in console
    my $commandLine = join(" ", @cmd);

    $self->debugMsg(5, 'Command: ' . $commandLine);
    $self->myCmdr->setProperty("/myCall/commandLine", $commandLine);

    return $commandLine;
}

###############################
# debugMsg - Print a debug message
#
# Arguments:
#   errorlevel - number compared to $self->opts->{Debug}
#   msg        - string message
#
# Returns:
#   -
#
################################
sub debugMsg {
    my ($self, $errlev, $msg) = @_;
    if ($self->opts->{debug} ge $errlev) { print "$msg\n"; }
    return;
}

###############################
# getError - Print a detailed error message
#
# Arguments:
#   error      - response content
#
# Returns:
#   -
#
################################
sub getError {
    my ($self, $error) = @_;

    my $xPath        = XML::XPath->new($error);
    my $nodeset      = $xPath->find('/Error');
    my $node         = $nodeset->get_node(1);
    my $errorCode    = $node->findvalue('@minorErrorCode')->string_value;
    my $errorMessage = $node->findvalue('@message')->string_value;
    $self->debugMsg(0, 'Error: ' . $errorCode . ' with message \'' . $errorMessage . '\'');
    return;
}

###############################
# issueRequest - issue the HTTP request, do special processing, and return result
#
# Arguments:
#   req      - the HTTP req
#
# Returns:
#   response - the HTTP response
###############################
sub issueRequest {
    my ($self, $postType, $urlText, $contentType, $content) = @_;

    my $url;
    my $req;
    my $response;

    if ($urlText eq "") {
        $self->debugMsg(0, "Error: blank URL in issueRequest.");
        $self->opts->{exitcode} = $ERROR;
        return "";
    }

    $url = URI->new($urlText);
    if ($postType eq "POST") {
        $req = HTTP::Request->new(POST => $url);
    }
    elsif ($postType eq "DELETE") {
        $req = HTTP::Request->new(DELETE => $url);
    }
    else {
        $req = HTTP::Request->new(GET => $url);
    }

    if ($contentType ne "") {
        $req->content_type($contentType);
    }
    if ($content ne "") {
        $req->content($content);
    }

    $self->debugMsg(6, "\nHTTP Request:" . $req->as_string);
    $response = $::browser->request($req);
    $self->debugMsg(6, "\nHTTP Response:" . $response->content);

    if ($response->is_error) {
        $self->debugMsg(0, $response->status_line);
        $self->getError($response->content);
        $self->opts->{exitcode} = $ERROR;
        return ("");
    }
    my $xml = $response->content;
    return $xml;
}

########################################################################
# IsEmptyOrNull - validate null or empty values
#
# Arguments:
#   -values: variable you want to validate
#
#
# Returns:
#   -0 / 1
#
########################################################################
sub IsEmptyOrNull {
    my $self  = shift;
    my $value = shift;
    if ($value && $value ne '') {
        return 0;
    }
    return 1;
}

###############################################################################
# checkserver - Checks if the server is reachable
#
# Arguments:
#   server name
#
# Returns:
#   true if the server is reachable, 0 if is not.
#
###############################################################################
sub checkserver {

    my ($self, $server) = @_;
    $server =~ s/(.*:\/\/)?(\w{3}\.)?//ixms;
    
    my $ping = Net::Ping->new();
    $ping->hires();
    $ping->port_number($self->opts->{instance_port});
    my ($ret, $duration, $ip) = $ping->ping($server);
    $ping->close();
    
    
    
    if (defined $ret && $ret eq '1') {
    
    print "$ip\n"; 
    
        if ($ip =~ m/\d*\.\d*\.\d*\.\d*/ixms) {
        
            return 1;
        }
    }
    
    return 0;
}

########################################################################
# parseSuiteXML - parse the xml response
#
# Arguments:
#   -none
#
# Returns:
#   -nothing
#
########################################################################
sub parseSuiteXML {
    my ($self, $xml) = @_;
    my $xPath = XML::XPath->new($xml);

    my $fitnesse_version = $xPath->find('/testResults/FitNesseVersion');
    my $suite            = $xPath->find('/testResults/rootPath');
    my $totalRight       = $xPath->find('/testResults/finalCounts[1]/right');
    my $totalWrong       = $xPath->find('/testResults/finalCounts[1]/wrong');
    my $totalIgnores     = $xPath->find('/testResults/finalCounts[1]/ignores');
    my $totalExceptions  = $xPath->find('/testResults/finalCounts[1]/exceptions');

    $self->debugMsg(0, '---------------------------------------------------------------------');
    $self->debugMsg(0, 'FitNesse Version: ' . $fitnesse_version);
    $self->debugMsg(0, 'Suite Name: ' . $suite);
    $self->debugMsg(0, 'Total Right: ' . $totalRight);
    $self->debugMsg(0, 'Total Wrong: ' . $totalWrong);
    $self->debugMsg(0, 'Total Ignores: ' . $totalIgnores);
    $self->debugMsg(0, 'Total Exceptions: ' . $totalExceptions);
    $self->debugMsg(0, '');

    $self->opts->{result_log} .= qq{FitNesse Version: $fitnesse_version \n};
    $self->opts->{result_log} .= qq{Suite Name: $suite \n};
    $self->opts->{result_log} .= qq{  Total Right: $totalRight \n};
    $self->opts->{result_log} .= qq{  Total Wrong: $totalWrong \n};
    $self->opts->{result_log} .= qq{  Total Ignores: $totalIgnores \n};
    $self->opts->{result_log} .= qq{  Total Exceptions: $totalExceptions \n\n};

    my $nodeset = $xPath->find('/testResults/result');

    foreach my $node ($nodeset->get_nodelist) {
        my $test       = $node->findvalue('relativePageName');
        my $right      = $node->findvalue('counts[1]/right');
        my $wrong      = $node->findvalue('counts[1]/wrong');
        my $ignores    = $node->findvalue('counts[1]/ignores');
        my $exceptions = $node->findvalue('counts[1]/exceptions');

        $self->debugMsg(0, '-----------------------------------------------------------');
        $self->debugMsg(0, 'Test: ' . $test);
        $self->debugMsg(0, 'Right: ' . $right);
        $self->debugMsg(0, 'Wrong: ' . $wrong);
        $self->debugMsg(0, 'Ignores: ' . $ignores);
        $self->debugMsg(0, 'Exceptions: ' . $exceptions);

        $self->opts->{result_log} .= qq{      ___________________________________________________________\n\n};
        $self->opts->{result_log} .= qq{          Test: $test \n};
        $self->opts->{result_log} .= qq{          Right: $right \n};
        $self->opts->{result_log} .= qq{          Wrong: $wrong \n};
        $self->opts->{result_log} .= qq{          Ignores: $ignores \n};
        $self->opts->{result_log} .= qq{          Exceptions: $exceptions \n};

    }
    return;

}

########################################################################
# parseTestXML - parse the xml response
#
# Arguments:
#   -none
#
# Returns:
#   -nothing
#
########################################################################
sub parseTestXML {
    my ($self, $xml) = @_;
    my $xPath = XML::XPath->new($xml);

    my $fitnesse_version = $xPath->find('/testResults/FitNesseVersion');
    my $test             = $xPath->find('/testResults/result[1]/relativePageName');
    my $totalRight       = $xPath->find('/testResults/result[1]/counts[1]/right');
    my $totalWrong       = $xPath->find('/testResults/result[1]/counts[1]/wrong');
    my $totalIgnores     = $xPath->find('/testResults/result[1]/counts[1]/ignores');
    my $totalExceptions  = $xPath->find('/testResults/result[1]/counts[1]/exceptions');

    $self->debugMsg(0, '---------------------------------------------------------------------');
    $self->debugMsg(0, 'FitNesse Version: ' . $fitnesse_version);
    $self->debugMsg(0, 'Test Name: ' . $test);
    $self->debugMsg(0, 'Total Right: ' . $totalRight);
    $self->debugMsg(0, 'Total Wrong: ' . $totalWrong);
    $self->debugMsg(0, 'Total Ignores: ' . $totalIgnores);
    $self->debugMsg(0, 'Total Exceptions: ' . $totalExceptions);
    $self->debugMsg(0, '');

    $self->opts->{result_log} .= qq{FitNesse Version: $fitnesse_version \n};
    $self->opts->{result_log} .= qq{Test Name: $test \n};
    $self->opts->{result_log} .= qq{  Total Right: $totalRight \n};
    $self->opts->{result_log} .= qq{  Total Wrong: $totalWrong \n};
    $self->opts->{result_log} .= qq{  Total Ignores: $totalIgnores \n};
    $self->opts->{result_log} .= qq{  Total Exceptions: $totalExceptions \n\n};

    return;

}

########################################################################
# registerReports - creates a link for registering the generated report
# in the job step detail
#
# Arguments:
#   -none
#
# Returns:
#   -nothing
#
########################################################################
sub registerReports {
    my ($self, $current_dir) = @_;

    $self->debugMsg(5, 'Creating results report...');

    # Get the root of log files
    my $ws = ($self->myCmdr->getProperty("/myWorkspace/agentUncPath"))->findvalue('//value')->string_value;

    if ($^O ne "MSWin32") {
        $ws = ($self->myCmdr->getProperty("/myWorkspace/agentUnixPath"))->findvalue('//value')->string_value;
    }

    my $jobpath = $ws . '/' . ($self->myCmdr->getProperty("/myJob/jobName"))->findvalue('//value')->string_value;
    my $jobId = ($self->myCmdr->getProperty("/myJob/jobId"))->findvalue('//value')->string_value;

    my $filename;
    $current_dir =~ m/(.+\/|.+\\)(.*)\..+$/imsg;
    $filename = $2 . '.xml';

    $self->myCmdr->setProperty("/myJob/results/Result file", "../../jobSteps/$[jobStepId]/" . $filename);

    my $xpath      = $self->myCmdr->getPlugin('@PLUGIN_NAME@');
    my $pluginName = $xpath->findvalue('//pluginName')->value;

    $self->myCmdr->setProperty("/myJob/artifactsDirectory", '');

    my $prop   = "/myJob/report-urls/@PLUGIN_KEY@ Report";
    my $target = "/commander/pages/$pluginName/reports?jobId=$jobId";

    $self->myCmdr->setProperty($prop, $target);

    $self->debugMsg(5, 'Report succesfully created...');
    return;

}

########################################################################
# writeResult - writes xml on a file
#
# Arguments:
#   -none
#
# Returns:
#   -nothing
#
########################################################################
sub writeResult {
    my ($self, $result_file, $xml) = @_;

    my $path;
    $result_file =~ m/(.+\/|.+\\)(.*)\..+$/ixsmg;
    $path = $1;

    mkpath "$path";

    if (open my $fout, q{>}, $result_file )
    {
        print $fout $xml;
        close $fout;
    
    }
    else{
    
        warn("Error: Cannot Open File");
        return;
    } 
    
    return;
}

1;

