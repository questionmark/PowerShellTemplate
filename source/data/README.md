# Data Files

The data directory is optional, and is used to store files that are not a functional part of the module.

If included, the `build.psd1` should be modified to contain `CopyDirectories = 'data'`.

## Examples

- CSV or other data files containing information used by the module (e.g. Questionmark.Configuration)
- dotnet templates (e.g. PowerShellTemplate)
- XSLT files (e.g. Questionmark.EnvironmentVariables)