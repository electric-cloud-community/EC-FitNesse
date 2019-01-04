use ElectricCommander;

push(
    @::gMatchers,

    {
       id      => "fitnesse_instance",
       pattern => q{^FitNesse\sinstance\srunning\son\s(.+)},
       action  => q{
         
                              my $desc = ((defined $::gProperties{"summary"}) ? $::gProperties{"summary"} : '');

                              $desc .= "FitNesse Instance: \'$1\'";
                              
                              setProperty("summary", $desc . "\n");
                             },
    },
    
    {
       id      => "fitnesse_error",
       pattern => q{\[ERROR\]\s(.+)},
       action  => q{
         
                              my $desc = ((defined $::gProperties{"summary"}) ? $::gProperties{"summary"} : '');

                              $desc .= "ERROR: \'$1\'";
                              
                              setProperty("summary", $desc . "\n");
                              setProperty("outcome", 'error');
                             },
    },
    
    {
       id      => "command_error",
       pattern => q{Command\snot\sfound},
       action  => q{
         
                              my $desc = ((defined $::gProperties{"summary"}) ? $::gProperties{"summary"} : '');

                              $desc .= "ERROR: \'Command not found\'";
                              
                              setProperty("summary", $desc . "\n");
                              setProperty("outcome", 'error');
                             },
    },
    
    

    {
       id      => "fitnesse_version",
       pattern => q{^FitNesse\sVersion\:\s(.+)},
       action  => q{
         
                              my $desc = ((defined $::gProperties{"summary"}) ? $::gProperties{"summary"} : '');

                              $desc .= "FitNesse Version: \'$1\'";
                              
                              setProperty("summary", $desc . "\n");
                             },
    },
    {
       id      => "suite_name",
       pattern => q{^Suite\sName\:\s(.+)},
       action  => q{
         
                              my $desc = ((defined $::gProperties{"summary"}) ? $::gProperties{"summary"} : '');

                              $desc .= "Suite Name: \'$1\'";
                              
                              setProperty("summary", $desc . "\n");
                             },
    },

    {
       id      => "tests_name",
       pattern => q{^Test\sName\:\s(.+)},
       action  => q{
         
                              my $desc = ((defined $::gProperties{"summary"}) ? $::gProperties{"summary"} : '');

                              $desc .= "Test Name: \'$1\'";
                              
                              setProperty("summary", $desc . "\n");
                             },
    },

    {
       id      => "tests_right",
       pattern => q{^Total\sRight\:\s(.+)},
       action  => q{
         
                              my $desc = ((defined $::gProperties{"summary"}) ? $::gProperties{"summary"} : '');

                              $desc .= "Total Right Tests: \'$1\'";
                              
                              setProperty("summary", $desc . "\n");
                             },
    },
    {
       id      => "tests_wrong",
       pattern => q{^Total\sWrong\:\s(.+)},
       action  => q{
         
                              my $desc = ((defined $::gProperties{"summary"}) ? $::gProperties{"summary"} : '');

                              $desc .= "Total Wrong Tests: \'$1\'";
                              
                              setProperty("summary", $desc . "\n");
                             },
    },
    {
       id      => "tests_ignored",
       pattern => q{^Total\sIgnores\:\s(.+)},
       action  => q{
         
                              my $desc = ((defined $::gProperties{"summary"}) ? $::gProperties{"summary"} : '');

                              $desc .= "Total Ignored Tests: \'$1\'";
                              
                              setProperty("summary", $desc . "\n");
                             },
    },
    {
       id      => "tests_exceptions",
       pattern => q{^Total\sExceptions\:\s(.+)},
       action  => q{
         
                              my $desc = ((defined $::gProperties{"summary"}) ? $::gProperties{"summary"} : '');

                              $desc .= "Total Exceptions Tests: \'$1\'";
                              
                              setProperty("summary", $desc . "\n");
                             },
    },
    {
       id      => "fitnesse_stop",
       pattern => q{^FitNesse.*at\s(.+)\sstopped\ssuccessfully},
       action  => q{
         
                              my $desc = ((defined $::gProperties{"summary"}) ? $::gProperties{"summary"} : '');

                              $desc .= "FitNesse at \'$1\' stopped.";
                              
                              setProperty("summary", $desc . "\n");
                             },
    },

);
