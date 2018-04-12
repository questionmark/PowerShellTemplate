# ModuleBase\classes

Contains classes, enums, and other prerequisites for the module (e.g. #using statements, constant variables, initialization code).

We use filenames with a two digit prefix, such that we can control the order they are added to the PSM1 by Optimize-Module.  
This allows control of prerequisites, as in the case of ModuleFileClass which requires ModuleFileType to have been defined.

## Examples

- #using statements to load enums etc from another module
- Parameters for use within the module (e.g. Questionmark.Azure.Provisioning)
- Enums used for validation / tab-completion in function parameters (e.g. Questionmark.Configuration)
- Classes used for DSC (e.g. UpdateServicesServerDsc)
- Constants for use within the module (e.g. Questionmark.Legacy)