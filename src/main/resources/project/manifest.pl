@files = (
    ['//property[propertyName="postp_matchers"]/value', 'postp_matchers.pl'],

    ['//procedure[procedureName="CreateFitNesseInstance"]/propertySheet/property[propertyName="ec_parameterForm"]/value', 'ui_forms/CreateFitNesseInstance.xml'],
    ['//step[stepName="CreateFitNesseInstance"]/command',                                                                 'procedures/CreateFitNesseInstance.pl'],
    ['//step[stepName="SetTimelimit"]/command',                                                                           'procedures/setTimelimit.pl'],

    ['//procedure[procedureName="RunTestOnNewInstance"]/propertySheet/property[propertyName="ec_parameterForm"]/value', 'ui_forms/RunTestOnNewInstance.xml'],
    ['//step[stepName="RunTestOnNewInstance"]/command',                                                                 'procedures/RunTestOnNewInstance.pl'],
    ['//step[stepName="SetTimelimit"]/command',                                                                         'procedures/setTimelimit.pl'],

    ['//procedure[procedureName="RunTestOnExistingInstance"]/propertySheet/property[propertyName="ec_parameterForm"]/value', 'ui_forms/RunTestOnExistingInstance.xml'],
    ['//step[stepName="RunTestOnExistingInstance"]/command',                                                                 'procedures/RunTestOnExistingInstance.pl'],
    ['//step[stepName="SetTimelimit"]/command',                                                                              'procedures/setTimelimit.pl'],

    ['//procedure[procedureName="StopFitNesseInstance"]/propertySheet/property[propertyName="ec_parameterForm"]/value', 'ui_forms/StopFitNesseInstance.xml'],
    ['//step[stepName="StopFitNesseInstance"]/command',                                                                 'procedures/StopFitNesseInstance.pl'],
    ['//step[stepName="SetTimelimit"]/command',                                                                         'procedures/setTimelimit.pl'],

    ['//property[propertyName="preamble"]/value', 'preamble.pl'],
    ['//property[propertyName="FitNesse"]/value', 'FitNesse.pm'],

    ['//property[propertyName="ec_setup"]/value', 'ec_setup.pl'],

         );
         


