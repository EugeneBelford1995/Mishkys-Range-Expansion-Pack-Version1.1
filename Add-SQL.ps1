#VM's local admin after re-naming the computer:
[string]$userName = "Dave-PC\Administrator"
[string]$userPassword = 'ExtraSecretLocalAdminPassword!!'
# Convert to SecureString
[securestring]$secStringPassword = ConvertTo-SecureString $userPassword -AsPlainText -Force
[pscredential]$DavePCLocalCredObject = New-Object System.Management.Automation.PSCredential ($userName, $secStringPassword)

#resarch.local Ent Admin:
[string]$userName = "research\Break.Glass"
[string]$userPassword = 'ExtraSafeDomainPassword1234!@#$'
# Convert to SecureString
[securestring]$secStringPassword = ConvertTo-SecureString $userPassword -AsPlainText -Force
[pscredential]$CousinDomainAdminCredObject = New-Object System.Management.Automation.PSCredential ($userName, $secStringPassword)

Set-Location "C:\VM_Stuff_Share\Lab\CousinDomain"
Enable-VMIntegrationService "Guest Service Interface" -VMName "Research-SQL"
Copy-VMFile "Research-SQL" -SourcePath ".\SQL2022.zip" -DestinationPath "C:\SQL2022.zip" -CreateFullPath -FileSource Host
Start-Sleep -Seconds 180
# Install PowerShell Desired State Configuration (DSC)
Invoke-Command -VMName "Research-SQL" {Install-Module -Name SqlServerDsc} -Credential $CousinDomainAdminCredObject
Invoke-Command -VMName "Research-SQL" -FilePath ".\Install-SQL.ps1" -Credential $CousinDomainAdminCredObject
Invoke-Command -VMName "Research-DC" -FilePath ".\Create-SQLUser.ps1" -Credential $CousinDomainAdminCredObject
Invoke-Command -VMName "Research-SQL" -FilePath ".\Config-SQL.ps1" -Credential $CousinDomainAdminCredObject