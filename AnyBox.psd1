@{
    # Script module or binary module file associated with this manifest.
    ModuleToProcess = 'AnyBox.psm1'

    # Version number of this module.
    ModuleVersion = '0.5.1'

    # Supported PSEditions
    # CompatiblePSEditions = 'Desktop'

    # ID used to uniquely identify this module
    GUID = '2d4d8fd0-36c3-48e9-b6ac-48df0f9bc7ab'

    # Author of this module
    Author = 'Fresh2dev'

    # Company or vendor of this module
    # CompanyName = 'Unknown'

    # Copyright statement for this module
    Copyright = '(c) 2022 Fresh2.dev'

    # Description of the functionality provided by this module
    Description = 'The easiest way to develop apps for Windows.'

    # Minimum version of the PowerShell engine required by this module
    PowerShellVersion = '3.0'

    # Name of the PowerShell host required by this module
    # PowerShellHostName = ''

    # Minimum version of the PowerShell host required by this module
    # PowerShellHostVersion = ''

    # Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    # DotNetFrameworkVersion = ''

    # Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    # CLRVersion = ''

    # Processor architecture (None, X86, Amd64) required by this module
    # ProcessorArchitecture = ''

    # Modules that must be imported into the global environment prior to importing this module
    # RequiredModules = @()

    # Assemblies that must be loaded prior to importing this module
    RequiredAssemblies = 'System.Windows.Forms.dll', 'System.Drawing.dll', 'PresentationFramework.dll', 'PresentationCore.dll', 'WindowsBase.dll'

    # Script files (.ps1) that are run in the caller's environment prior to importing this module.
    # ScriptsToProcess = ''

    # Type files (.ps1xml) to be loaded when importing this module
    # TypesToProcess = @()

    # Format files (.ps1xml) to be loaded when importing this module
    # FormatsToProcess = @()

    # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
    # NestedModules = @()

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport = @(
        'Get-Base64',
        'Get-DictSubset',
        'New-AnyBoxPrompt',
        'ConvertTo-AnyBoxPrompts',
        'New-AnyBoxButton',
        'Show-AnyBox'
    )

    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport = @()

    # Variables to export from this module
    VariablesToExport = @()

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport = @(
        'anybox',
        'New-Prompt',
        'New-Button'
    )

    # DSC resources to export from this module
    # DscResourcesToExport = @()

    # List of all modules packaged with this module
    # ModuleList = @()

    # List of all files packaged with this module
    FileList = @(
        'AnyBox.psd1',
        'AnyBox.psm1',
        'Types\AnyBox.cs',
        'Types\AnyBox.ps1',
        'Public\Show-AnyBox.ps1',
        'Public\New-AnyBoxPrompt.ps1',
        'Public\ConvertTo-AnyBoxPrompts.ps1'
        'Public\New-AnyBoxButton.ps1',
        'Public\Get-Base64.ps1',
        'Public\Get-DictSubset.ps1',
        'Private\ConvertTo-BitmapImage.ps1',
        'Private\ConvertTo-Long.ps1',
        'Private\New-TextBlock.ps1',
        'Private\Test-ValidInput.ps1'
    )

    # HelpInfo URI of this module
    HelpInfoURI = 'https://fresh2.dev/doc/AnyBox'

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData = @{
        PSData = @{
            # Tags applied to this module. These help with module discovery in online galleries.
            Tags = 'GUI', 'WPF', 'Forms'

            # A URL to the license for this module.
            LicenseUri = 'https://github.com/fresh2dev/AnyBox/blob/main/CHANGELOG.md'

            # A URL to the main website for this project.
            ProjectUri = 'https://github.com/fresh2dev/AnyBox'

            # A URL to an icon representing this module.
            IconUri = 'https://fresh2.dev/favicon.ico'

            # ReleaseNotes of this module
            ReleaseNotes = 'https://github.com/fresh2dev/AnyBox/blob/main/CHANGELOG.md'
        }
    }

    # Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
    # DefaultCommandPrefix = ''
}