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
    [String] $domainNetBIOSName = (Get-NetBIOSName -DomainFQDN $domainFQDN)
    [System.Management.Automation.PSCredential] $domainCredential = New-Object System.Management.Automation.PSCredential ("${domainNetBIOSName}\$($adminCredential.UserName)", $adminCredential.Password)

    $interface = Get-NetAdapter | Where-Object Name -Like "Ethernet*" | Select-Object -First 1
    $interfaceAlias = $($interface.Name)

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
            DependsOn = '[WindowsFeature]InstallDNS'
        }

        WindowsFeature InstallADDSTools {
            Ensure = 'Present'
            Name = 'RSAT-ADDS-Tools'
            DependsOn = '[WindowsFeature]InstallADDS'
        }

        WaitForADDomain ADForestReady {
            DomainName = $domainFQDN
            RestartCount = 5
            Credential = $domainCredential
            WaitForValidCredentials = $true
            WaitTimeout = 1800
            DependsOn = '[WindowsFeature]InstallADDS'
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

function Get-NetBIOSName {
    [OutputType([string])]
    param(
        [string] $domainFQDN
    )

    if ($domainFQDN.Contains('.')) {
        $length = $domainFQDN.IndexOf('.')
        if ( $length -ge 16) {
            $length = 15
        }
        return $domainFQDN.Substring(0, $length)
    }
    else {
        if ($domainFQDN.Length -gt 15) {
            return $domainFQDN.Substring(0, 15)
        }
        else {
            return $domainFQDN
        }
    }
}