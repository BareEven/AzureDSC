Configuration Deploy-Winbast {
    Param (
        [Parameter(Mandatory)]
        [String] $domainFQDN,

        [Parameter(Mandatory)]
        [String] $computerName,

        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential] $adminCredential
    )
    
    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'
    Import-DscResource -ModuleName 'ComputerManagementDsc'
    Import-DscResource -ModuleName 'ActiveDirectoryDsc'

    # Create the NetBIOS name and domain credentials based on the domain FQDN
    [System.Management.Automation.PSCredential] $domainCredential = New-Object System.Management.Automation.PSCredential ($adminCredential.UserName, $adminCredential.Password)
    &ipconfig /renew

    Node localhost
    {
        LocalConfigurationManager 
        {
            ConfigurationMode = 'ApplyOnly'
            RebootNodeIfNeeded = $true
        }
        
        WindowsFeature InstallDNSTools {
            Ensure = 'Present'
            Name = 'RSAT-DNS-Server'
        }

        WindowsFeature InstallADDSTools {
            Ensure = 'Present'
            Name = 'RSAT-ADDS-Tools'
        }

        WaitForADDomain ADForestReady {
            DomainName = $domainFQDN
            RestartCount = 5
            Credential = $domainCredential
            WaitForValidCredentials = $true
            WaitTimeout = 1800
        }

        Computer JoinDomain
        {
            Name = $computerName 
            DomainName = $domainFQDN
            Credential = $domainCredential
            DependsOn = '[WaitForADDomain]ADForestReady'
        }

        PendingReboot RebootAfterJoiningDomain
        {
            Name = 'RebootAfterJoiningDomain'
            DependsOn = "[Computer]JoinDomain"
        }
    }
}
