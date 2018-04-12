@{
    ModuleVersion          = "0.0.0.0"

    # Modules that must be imported into the global environment prior to importing this module
    RequiredModules        = @()

    # Functions to export. Populated by Optimize-Module during the build step.
    FunctionsToExport      = @()

    # ID used to uniquely identify this module
    GUID                   = 'db71308b-0ab1-443c-9dbb-69bed337a806'

    # The main script module that is automatically loaded as part of this module
    RootModule             = 'CloneModule.psm1'

    # Common stuff for all our modules:
    CompanyName            = 'Company_Name'
    Author                 = 'Author_Name'
    Copyright              = "Copyright 2018 CompanyName"

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion      = '5.1'
    # Minimum version of the .NET Framework required by this module
    DotNetFrameworkVersion = '4.0'
    # Minimum version of the common language runtime (CLR) required by this module
    CLRVersion             = '4.0.30319'
}