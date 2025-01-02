#resarch.local Ent Admin:
[string]$userName = "research\Break.Glass"
[string]$userPassword = 'ExtraSafeDomainPassword1234!@#$'
# Convert to SecureString
[securestring]$secStringPassword = ConvertTo-SecureString $userPassword -AsPlainText -Force
[pscredential]$CousinDomainAdminCredObject = New-Object System.Management.Automation.PSCredential ($userName, $secStringPassword)

Invoke-Command -VMName "Research-DC" -FilePath ".\Check-Privs.ps1" -Credential $CousinDomainAdminCredObject

Copy-VMFile "Research-DC" -SourcePath "I:\Installers\Gold-Finer-Mini.zip" -DestinationPath "C:\Gold-Finger-Mini.zip" -CreateFullPath -FileSource Host
Invoke-Command -VMName "Research-DC" {Expand-Archive "C:\Gold-Finger-Mini.zip" -DestinationPath "C:\"}

Invoke-Command -VMName "Research-DC" {Import-Module ActiveDirectory ; Set-Location AD: ; (Get-Acl (Get-ADUser "Dave").DistinguishedName).Access | Where-Object {$_.IdentityReference -like "*Account Operators*"}} -Credential $CousinDomainAdminCredObject
Invoke-Command -VMName "Research-DC" {(Get-Acl "C:\HTTPsCertificates.json").Access} -Credential $CousinDomainAdminCredObject

Invoke-Command -VMName "US-DC" {Import-Module ActiveDirectory ; Set-Location AD: ; (Get-Acl (Get-ADUser "Eugene.Belford").DistinguishedName).Access | Where-Object {$_.IdentityReference -like "*Helpdesk*"}} -Credential $ChildDomainAdminCredObject
Invoke-Command -VMName "US-DC" {Import-Module ActiveDirectory ; Set-Location AD: ; (Get-Acl (Get-ADOrganizationalUnit -Filter {Name -eq "Server_Admins"}).DistinguishedName).Access | Where-Object {$_.IdentityReference -like "*Helpdesk*"} } -Credential $ChildDomainAdminCredObject

Invoke-Command -VMName "Research-DC" -FilePath "C:\VM_Stuff_Share\Lab\CousinDomain\Misconfig-Domain.ps1" -Credential $CousinDomainAdminCredObject
Enable-VMIntegrationService "Guest Service Interface" -VMName "Research-Client"
Copy-VMFile "Research-Client" -SourcePath "C:\VM_Stuff_Share\Lab\CousinDomain\Gold-Finger-Mini.zip" -DestinationPath "C:\" -CreateFullPath -FileSource Host
Invoke-Command -VMName "Research-Client" {Expand-Archive "C:\Gold-Finger-Mini.zip" -DestinationPath "C:\"} -Credential $CousinDomainAdminCredObject