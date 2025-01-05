#https://www.sqlservercentral.com/articles/install-sql-server-using-powershell-desired-state-configuration-dsc

#Interesting, but used DSC instead: https://medium.com/trendyol-tech/sql-server-unattended-installation-with-powershell-d12c7a732b00

#Zip the SQL2022 folder, upload it to Research-DC, Expand-Archive
#Re-work this so it runs via Invoke-Command -VMName "Research-DC" -FileName ".\Install-SQL.ps1"
#Should install SQL Server on Dave-PC at that point using research\break.glass creds

#Expand-Archive -Path "C:\SQL2022.zip" -DestinationPath "C:\"

#Install PowerShell Desired State Configuration (DSC)
#Install-Module -Name SqlServerDsc
#Import-Module -Name PSDesiredStateConfiguration
#Import-Module -Name PSDscResources
#Import-Module -Name PowerShellGet
Import-Module -Name SqlServerDsc

#DSC
Configuration InstallSQLServer
{
Import-DscResource -ModuleName SqlServerDsc
   Node "Research-SQL"
    {
       WindowsFeature 'NetFramework45'
          {
                Name   = 'NET-Framework-45-Core'
                Ensure = 'Present'
          }
  
      SqlSetup SQLInstall
         {
                InstanceName = "MSSQLSERVER"
                Features = "SQLENGINE"
                SourcePath = "C:\SQL2022"
                SQLSysAdminAccounts = @("research\Administrator","research\SQL.Admin")
                DependsOn = "[WindowsFeature]NetFramework45"
}
}
}

# Compile the DSC configuration file
InstallSQLServer -OutputPath "C:\DSC"

# Apply the DSC configuration
Start-DscConfiguration -Path "C:\DSC" -Wait -Verbose -Force