#resarch.local Ent Admin:
[string]$userName = "research\Break.Glass"
[string]$userPassword = 'ExtraSafeDomainPassword1234!@#$'
# Convert to SecureString
[securestring]$secStringPassword = ConvertTo-SecureString $userPassword -AsPlainText -Force
[pscredential]$CousinDomainAdminCredObject = New-Object System.Management.Automation.PSCredential ($userName, $secStringPassword)

Enable-VMIntegrationService "Guest Service Interface" -VMName "Research-SQL"
Start-Sleep -Seconds 30
Set-Location C:\VM_Stuff_Share\Lab_Version1.1\CousinDomain
Copy-VMFile "Research-SQL" -SourcePath ".\Research-SQL.mof" -DestinationPath "C:\DSC\Research-SQL.mof" -CreateFullPath -FileSource Host
Invoke-Command -VMName "Research-SQL" {Start-DscConfiguration -Path "C:\DSC" -Wait -Verbose -Force} -Credential $CousinDomainAdminCredObject