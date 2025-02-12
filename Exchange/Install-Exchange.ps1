#resarch.local Ent Admin:
[string]$userName = "research\Break.Glass"
[string]$userPassword = 'ExtraSafeDomainPassword1234!@#$'
# Convert to SecureString
[securestring]$secStringPassword = ConvertTo-SecureString $userPassword -AsPlainText -Force
[pscredential]$CousinDomainAdminCredObject = New-Object System.Management.Automation.PSCredential ($userName, $secStringPassword)

Set-Location "C:\VM_Stuff_Share\Lab_Version1.1\CousinDomain"
#Pre-Stage Exchange on MSSQL
Enable-VMIntegrationService "Guest Service Interface" -VMName "Research-SQL"
#Invoke-Command -VMName "Research-SQL" {New-Item -ItemType Directory "C:\Exchange"} -Credential $CousinDomainAdminCredObject
Copy-VMFile "Research-SQL" -SourcePath ".\Exchange.zip" -DestinationPath "C:\Exchange\Exchange.zip" -CreateFullPath -FileSource Host
Invoke-Command -VMName "Research-SQL" {Expand-Archive -Path "C:\Exchange\Exchange.zip" -DestinationPath "C:\"} -Credential $CousinDomainAdminCredObject

#Pre-reqs for Exchange
#.Net: https://learn.microsoft.com/en-us/dotnet/core/install/windows
Invoke-Command -VMName "Research-SQL" {Install-WindowsFeature ADLDS, Server-Media-Foundation, NET-Framework-45-Features, RPC-over-HTTP-proxy, RSAT-Clustering, RSAT-Clustering-CmdInterface, RSAT-Clustering-Mgmt, RSAT-Clustering-PowerShell, WAS-Process-Model, Web-Asp-Net45, Web-Basic-Auth, Web-Client-Auth, Web-Digest-Auth, Web-Dir-Browsing, Web-Dyn-Compression, Web-Http-Errors, Web-Http-Logging, Web-Http-Redirect, Web-Http-Tracing, Web-ISAPI-Ext, Web-ISAPI-Filter, Web-Lgcy-Mgmt-Console, Web-Metabase, Web-Mgmt-Console, Web-Mgmt-Service, Web-Net-Ext45, Web-Request-Monitor, Web-Server, Web-Stat-Compression, Web-Static-Content, Web-Windows-Auth, Web-WMI, Windows-Identity-Foundation, RSAT-ADDS} -Credential $CousinDomainAdminCredObject
Restart-VM "Research-SQL" -Force
Start-Sleep -Seconds 180
Copy-VMFile "Research-SQL" -SourcePath ".\dotnet-install.ps1" -DestinationPath "C:\dotnet-install.ps1" -CreateFullPath -FileSource Host
Invoke-Command -VMName "Research-SQL" {C:\dotnet-install.ps1 -Runtime windowsdesktop ; C:\dotnet-install.ps1 -Runtime aspnetcore} -Credential $CousinDomainAdminCredObject
Invoke-Command -VMName "Research-SQL" {Install-Module -Name VcRedist} -Credential $CousinDomainAdminCredObject
#Query to get the URL to pull VC_redist from:
#Get-VcList -Release 2019 -Architecture x64
Invoke-WebRequest "https://aka.ms/vs/16/release/VC_redist.x64.exe" -OutFile ".\VC_redist.x64.exe"
Copy-VMFile "Research-SQL" -SourcePath ".\VC_redist.x64.exe" -DestinationPath "C:\VC_redist.x64.exe" -CreateFullPath -FileSource Host
Invoke-Command -VMName "Research-SQL" {C:\VC_redist.x64.exe /install /quiet /norestart} -Credential $CousinDomainAdminCredObject
Invoke-Command -VMName "Research-SQL" {Restart-Computer -Force} -Credential $CousinDomainAdminCredObject
Start-Sleep -Seconds 30
#Download & install the IIS URL Rewrite Module:
Invoke-WebRequest "https://download.microsoft.com/download/1/2/8/128E2E22-C1B9-44A4-BE2A-5859ED1D4592/rewrite_amd64_en-US.msi" -OutFile ".\rewrite_amd64_en-US.msi"
Copy-VMFile "Research-SQL" -SourcePath ".\rewrite_amd64_en-US.msi" -DestinationPath "C:\rewrite_amd64_en-US.msi" -CreateFullPath -FileSource Host
Invoke-Command -VMName "Research-SQL" {msiexec.exe /i "C:\rewrite_amd64_en-US.msi" /qb | Out-Null} -Credential $CousinDomainAdminCredObject
#Download & install the Unified Communications Managed API 4.0 Runtime
Invoke-WebRequest "https://download.microsoft.com/download/2/C/4/2C47A5C1-A1F3-4843-B9FE-84C0032C61EC/UcmaRuntimeSetup.exe" -OutFile ".\UcmaRuntimeSetup.exe"
Copy-VMFile "Research-SQL" -SourcePath ".\UcmaRuntimeSetup.exe" -DestinationPath "C:\UcmaRuntimeSetup.exe" -CreateFullPath -FileSource Host
Invoke-Command -VMName "Research-SQL" {Start-Process -FilePath C:\UcmaRuntimeSetup.exe -ArgumentList /quiet} -Credential $CousinDomainAdminCredObject
Invoke-Command -VMName "Research-SQL" {Enable-WindowsOptionalFeature -Online -FeatureName IIS-IIS6ManagementCompatibility,IIS-Metabase -All} -Credential $CousinDomainAdminCredObject

#Copy-VMFile "Research-SQL" -SourcePath ".\vcredist_x64 (13).exe" -DestinationPath "C:\vcredist_x64_13.exe" -CreateFullPath -FileSource Host
#Invoke-Command -VMName "Research-SQL" {C:\vcredist_x64_13.exe /install /quiet /norestart} -Credential $CousinDomainAdminCredObject

#https://c7solutions.com/2019/02/exchange-server-dependency-on-visual-c-failing-detection
Invoke-WebRequest "https://download.microsoft.com/download/1/6/B/16B06F60-3B20-4FF2-B699-5E9B7962F9AE/VSU_4/vcredist_x86.exe" -OutFile "vcredist_x64_2012.exe"
Copy-VMFile "Research-SQL" -SourcePath ".\vcredist_x64_2012.exe" -DestinationPath "C:\vcredist_x64_2012.exe" -CreateFullPath -FileSource Host
Invoke-Command -VMName "Research-SQL" {C:\vcredist_x64_2012.exe /install /quiet /norestart} -Credential $CousinDomainAdminCredObject

Invoke-WebRequest "https://download.microsoft.com/download/2/E/6/2E61CFA4-993B-4DD4-91DA-3737CD5CD6E3/vcredist_x64.exe" -OutFile ".\vcredist_x64_2013.exe"
Copy-VMFile "Research-SQL" -SourcePath ".\vcredist_x64_2013.exe" -DestinationPath "C:\vcredist_x64_2013.exe" -CreateFullPath -FileSource Host
Invoke-Command -VMName "Research-SQL" {C:\vcredist_x64_2013.exe /install /quiet /norestart} -Credential $CousinDomainAdminCredObject

Invoke-WebRequest "https://download.microsoft.com/download/c/c/2/cc2df5f8-4454-44b4-802d-5ea68d086676/vcredist_x64.exe" -OutFile ".\vcredits_x64_13UpdateV5.exe"
Copy-VMFile "Research-SQL" -SourcePath ".\vcredits_x64_13UpdateV5.exe" -DestinationPath "C:\vcredits_x64_13UpdateV5.exe" -CreateFullPath -FileSource Host
Invoke-Command -VMName "Research-SQL" {C:\vcredits_x64_13UpdateV5.exe /install /quiet /norestart} -Credential $CousinDomainAdminCredObject

Restart-VM -Name "Research-SQL" -Force

#Install Exchange itself
Invoke-Command -VMName "Research-SQL" {C:\Exchange\Setup.exe /IAcceptExchangeServerLicenseTerms_DiagnosticDataOFF /mode:Install /r:MB /OrganizationName Research} -Credential $CousinDomainAdminCredObject
Start-Sleep -Seconds 60
Invoke-Command -VMName "Research-SQL" {Restart-Computer -Force} -Credential $CousinDomainAdminCredObject

#Create inboxes for Dave & SQL.Admin and delegate Dave control over SQL.Admin's inbox. Additionally, this revokes Dave's password reset right on SQL.Admin.
Invoke-Command -VMName "Research-SQL" -FilePath ".\Config-Exchange.ps1" -Credential $CousinDomainAdminCredObject

#Send a password reset email to SQL.Admin & set SQL.Admin to require password change on next login
Invoke-Command -VMName "Research-SQL" -FilePath ".\Send-Email.ps1" -Credential $CousinDomainAdminCredObject