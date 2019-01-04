use warnings;
use strict;


my $pluginName = "@PLUGIN_NAME@";
if ($promoteAction ne '') {
    my @objTypes = ('projects', 'resources', 'workspaces');
    my $query    = $commander->newBatch();
    my @reqs     = map { $query->getAclEntry('user', 'project: $pluginName', { systemObjectName => $_ }) } @objTypes;
    push @reqs, $query->getProperty('/server/ec_hooks/promote');
    $query->submit();

    foreach my $type (@objTypes) {
        if ($query->findvalue(shift @reqs, 'code') ne 'NoSuchAclEntry') {
            $batch->deleteAclEntry('user', 'project: $pluginName', { systemObjectName => $type });
        }
    }

        foreach my $type (@objTypes) {
            $batch->createAclEntry(
                                   'user',
                                   'project: $pluginName',
                                   {
                                      systemObjectName           => $type,
                                      readPrivilege              => 'allow',
                                      modifyPrivilege            => 'allow',
                                      executePrivilege           => 'allow',
                                      changePermissionsPrivilege => 'allow'
                                   }
                                  );
        }
}

# The plugin is being promoted, create a property reference in the server's property sheet
        # Data that drives the create step picker registration for this plugin.
my %CreateFitNesseInstance = (
                              label       => "FitNesse - Create Instance",
                              procedure   => "CreateFitNesseInstance",
                              description => "Create a new FitNesse instance using CLI.",
                              category    => "Test"
                             );
my %RunTestOnNewInstance = (
                            label       => "FitNesse - Run Test (New Instance)",
                            procedure   => "RunTestOnNewInstance",
                            description => "Run FitNesse tests and suites creating a new fitnesse instance.",
                            category    => "Test"
                           );
my %RunTestOnExistingInstance = (
                                 label       => "FitNesse - Run Test (Existing Instance)",
                                 procedure   => "RunTestOnExistingInstance",
                                 description => "Run FitNesse tests and suites on an existing fitnesse instance.",
                                 category    => "Test"
                                );
my %StopFitNesseInstance = (
                            label       => "FitNesse - Stop Instance",
                            procedure   => "StopFitNesseInstance",
                            description => "Stop a running fitnesse instance.",
                            category    => "Test"
                           );

$batch->deleteProperty("/server/ec_customEditors/pickerStep/FitNesse - Create Instance");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/FitNesse - Run Test (New Instance)");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/FitNesse - FitNesse - Run Test (Existing Instance)");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/FitNesse - FitNesse - Stop Instance");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/EC-FitNesse - CreateFitNesseInstance");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/EC-FitNesse - RunTestOnNewInstance");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/EC-FitNesse - RunTestOnExistingInstance");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/EC-FitNesse - StopFitNesseInstance");
        
@::createStepPickerSteps = (\%CreateFitNesseInstance, \%RunTestOnNewInstance, \%RunTestOnExistingInstance, \%StopFitNesseInstance);

1;
