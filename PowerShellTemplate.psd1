@{
    ModuleVersion          = "0.0.1"

    # Modules that must be imported into the global environment prior to importing this module
    RequiredModules        = @()

    # Functions to export. Populated by Optimize-Module during the build step.
    FunctionsToExport      = @()

    # ID used to uniquely identify this module
    GUID                   = 'af8481bc-5027-4bbf-a8bf-42ccadd4c885'
    Description            = 'The Questionmark PowerShell Template Module'

    # The main script module that is automatically loaded as part of this module
    RootModule             = 'PowerShellTemplate.psm1'

    # Common stuff for all our modules:
    CompanyName            = 'Questionmark Computing Limited'
    Author                 = 'Team Forge'
    Copyright              = "Copyright 2018 Questionmark Computing Limited"

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion      = '5.1'
    # Minimum version of the .NET Framework required by this module
    DotNetFrameworkVersion = '4.0'
    # Minimum version of the common language runtime (CLR) required by this module
    CLRVersion             = '4.0.30319'
}