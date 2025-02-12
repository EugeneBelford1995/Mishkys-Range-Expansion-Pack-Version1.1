#resarch.local Ent Admin:
[string]$userName = "research\Break.Glass"
[string]$userPassword = 'ExtraSafeDomainPassword1234!@#$'
# Convert to SecureString
[securestring]$secStringPassword = ConvertTo-SecureString $userPassword -AsPlainText -Force
[pscredential]$CousinDomainAdminCredObject = New-Object System.Management.Automation.PSCredential ($userName, $secStringPassword)

#Establish a connection to the Exchange server:
#$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://Research-SQL.research.local/PowerShell/ -Authentication Kerberos -Credential $CousinDomainAdminCredObject
Import-PSSession $Session -DisableNameChecking
Invoke-Command -Session $Session -ScriptBlock {Enable-Mailbox -Identity Dave}
Invoke-Command -Session $Session -ScriptBlock {Enable-Mailbox -Identity SQL.Admin}
Invoke-Command -Session $Session -ScriptBlock {Add-MailboxPermission -Identity "SQL.Admin" -User "Dave" -AccessRights FullAccess -InheritanceType All}

Import-Module ActiveDirectory
Set-Location AD:
$ADRoot = (Get-ADDomain).DistinguishedName

#Remove Dave's reset password rights on SQL.Admin
Set-Location AD:
#Remove Dave's Password reset & re-enable over SQL.Admin
$victim = (Get-ADUser "SQL.Admin").DistinguishedName
$acl = Get-ACL $victim
$user = New-Object System.Security.Principal.SecurityIdentifier (Get-ADUser -Identity "Dave").SID
#Remove specific password reset
$acl.RemoveAccessRule((New-Object System.DirectoryServices.ActiveDirectoryAccessRule $user,"ExtendedRight","ALLOW",([GUID]("00299570-246d-11d0-a768-00aa006e0529")).guid,"None",([GUID]("00000000-0000-0000-0000-000000000000")).guid))
#Remove specific WriteProperty on the Enabled attribute
$acl.RemoveAccessRule((New-Object System.DirectoryServices.ActiveDirectoryAccessRule $user,"WriteProperty","ALLOW",([GUID]("a8df73f2-c5ea-11d1-bbcb-0080c76670c0")).guid,"None",([GUID]("00000000-0000-0000-0000-000000000000")).guid))
#Apply above ACL rules
Set-ACL $victim $acl