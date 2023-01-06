@{
    # Version number of this module.
    moduleVersion        = '5.1.0'

    # ID used to uniquely identify this module
    GUID                 = '00d73ca1-58b5-46b7-ac1a-5bfcf5814faf'

    # Author of this module
    Author               = 'DSC Community'

    # Company or vendor of this module
    CompanyName          = 'DSC Community'

    # Copyright statement for this module
    Copyright            = 'Copyright the DSC Community contributors. All rights reserved.'

    # Description of the functionality provided by this module
    Description          = 'DSC resources for managing storage on Windows Servers.'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion    = '4.0'

    # Minimum version of the common language runtime (CLR) required by this module
    CLRVersion           = '4.0'

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport    = @()

    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport      = @()

    # Variables to export from this module
    VariablesToExport    = @()

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport      = @()

    # DSC resources to export from this module
    DscResourcesToExport = @('DiskAccessPath','MountImage','OpticalDiskDriveLetter','WaitForDisk','WaitForVolume','Disk')

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData          = @{
        PSData = @{
            # Set to a prerelease string value if the release should be a prerelease.
            Prerelease   = 'preview0001'

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags         = @('DesiredStateConfiguration', 'DSC', 'DSCResource', 'Disk', 'Storage', 'Partition', 'Volume')

            # A URL to the license for this module.
            LicenseUri   = 'https://github.com/dsccommunity/StorageDsc/blob/main/LICENSE'

            # A URL to the main website for this project.
            ProjectUri   = 'https://github.com/dsccommunity/StorageDsc'

            # A URL to an icon representing this module.
            IconUri      = 'https://dsccommunity.org/images/DSC_Logo_300p.png'

            # ReleaseNotes of this module
            ReleaseNotes = '## [5.1.0-preview0001] - 2021-04-10

### Changed

- Renamed `master` branch to `main` - Fixes [Issue #250](https://github.com/dsccommunity/StorageDsc/issues/250).
- Added support for publishing code coverage to `CodeCov.io` and
  Azure Pipelines - Fixes [Issue #255](https://github.com/dsccommunity/StorageDsc/issues/255).
- Updated build to use `Sampler.GitHubTasks` - Fixes [Issue #254](https://github.com/dsccommunity/StorageDsc/issues/254).

### Fixed

- MountImage:
  - Corrected example `1-MountImage_DismountISO.ps1` for dismounting
    ISO - Fixes [Issue #221](https://github.com/dsccommunity/StorageDsc/issues/221).
- Updated `GitVersion.yml` to latest pattern - Fixes [Issue #252](https://github.com/dsccommunity/StorageDsc/issues/252).

'
        } # End of PSData hashtable
    } # End of PrivateData hashtable
}




