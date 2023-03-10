Configuration Deploy-DomainServices
{
    Param
    (
        [Parameter(Mandatory)]
        [String] $domainFQDN,

        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential] $adminCredential,
        [String]$role = "pdc",
        [String]$otherDNSip
    )

    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'
    Import-DscResource -ModuleName 'ActiveDirectoryDsc'
    Import-DscResource -ModuleName 'ComputerManagementDsc'
    Import-DscResource -ModuleName 'NetworkingDsc'
    Import-DscResource -ModuleName 'StorageDsc'

    # Create the NetBIOS name and domain credentials based on the domain FQDN
    [System.Management.Automation.PSCredential] $domainCredential = New-Object System.Management.Automation.PSCredential ("$($domainFQDN)`\$($adminCredential.UserName)", $adminCredential.Password)

    $interface = Get-NetAdapter | Where-Object Name -Like "Ethernet*" | Select-Object -First 1
    $interfaceAlias = $($interface.Name)

    Node localhost {
        LocalConfigurationManager {
            ConfigurationMode = 'ApplyOnly'
            RebootNodeIfNeeded = $true
        }

        WindowsFeature InstallDNS { 
            Ensure = 'Present'
            Name = 'DNS'
        }

        WindowsFeature InstallDNSTools {
            Ensure = 'Present'
            Name = 'RSAT-DNS-Server'
            DependsOn = '[WindowsFeature]InstallDNS'
        }

        if($role -eq "pdc") {
            DnsServerAddress SetDNS { 
                Address = '127.0.0.1'
                InterfaceAlias = $interfaceAlias
                AddressFamily = 'IPv4'
                DependsOn = '[WindowsFeature]InstallDNS'
            }
        } else {
            DnsServerAddress SetDNS { 
                Address = $otherDNSip
                InterfaceAlias = $interfaceAlias
                AddressFamily = 'IPv4'
                DependsOn = '[WindowsFeature]InstallDNS'
            }
        }

        WaitforDisk waitForDisk2
        {
            DiskId = 2
            RetryIntervalSec = 30
            RetryCount = 20
        }

        Disk ADDataDisk {
            DiskId = 2
            DriveLetter = "F"
            DependsOn = "[WaitForDisk]waitForDisk2"
        }

        WindowsFeature InstallADDS {
            Ensure = 'Present'
            Name = 'AD-Domain-Services'
            DependsOn = '[WindowsFeature]InstallDNS'
        }

        WindowsFeature InstallADDSTools {
            Ensure = 'Present'
            Name = 'RSAT-ADDS-Tools'
            DependsOn = '[WindowsFeature]InstallADDS'
        }

        if($role -eq "pdc") {
            ADDomain CreateADForest {
                DomainName = $domainFQDN
                Credential = $domainCredential
                SafemodeAdministratorPassword = $domainCredential
                ForestMode = 'WinThreshold'
                DatabasePath = 'F:\NTDS'
                LogPath = 'F:\NTDS'
                SysvolPath = 'F:\SYSVOL'
                DependsOn = '[DnsServerAddress]SetDNS', '[WindowsFeature]InstallADDS'
            }

            PendingReboot RebootAfterCreatingADForest {
                Name = 'RebootAfterCreatingADForest'
                DependsOn = '[ADDomain]CreateADForest'
            }

            WaitForADDomain WaitForDomainController {
                DomainName = $domainFQDN
                WaitTimeout = 300
                RestartCount = 3
                Credential = $domainCredential
                WaitForValidCredentials = $true
                DependsOn = '[PendingReboot]RebootAfterCreatingADForest'
            }
        } else {
            WaitForADDomain ADForestReady {
                DomainName = $domainFQDN
                RestartCount = 5
                Credential = $domainCredential
                WaitForValidCredentials = $true
                WaitTimeout = 1800
                DependsOn = '[WindowsFeature]InstallADDS'
            }
            
            ADDomainController AddOtherDC {
                DomainName = $domainFQDN
                Credential = $domainCredential
                SafemodeAdministratorPassword = $domainCredential
                DatabasePath = 'F:\NTDS'
                LogPath = 'F:\NTDS'
                SysvolPath = 'F:\SYSVOL'
                DependsOn = '[WaitForADDomain]ADForestReady','[DnsServerAddress]setDNS', '[WindowsFeature]InstallADDS'
            }
            
            PendingReboot RebootAfterCreatingDC {
                Name = 'RebootAfterCreatingADForest'
                DependsOn = '[ADDomainController]AddOtherDC'
            }
        }
    }
}