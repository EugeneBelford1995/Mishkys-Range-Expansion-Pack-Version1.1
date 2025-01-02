$ADRoot = (Get-ADDomain).DistinguishedName
$FQDN = (Get-ADDomain).DNSRoot

#Store a password for users
[string]$DSRMPassword = 'ExtraSafeDomainPassword1234!@#$'
# Convert to SecureString
[securestring]$UserPassword = ConvertTo-SecureString $DSRMPassword -AsPlainText -Force

$User = "Break.Glass"

New-ADUser -SamAccountName $User -Name $User -UserPrincipalName "$User@$FQDN" -AccountPassword $UserPassword -Enabled $true -Description "Backup Ent Admin" -PasswordNeverExpires $true
Add-ADGroupMember -Identity "Enterprise Admins" -Members "$User"
Add-ADGroupMember -Identity "Domain Admins" -Members "$User"
Add-ADGroupMember -Identity "Schema Admins" -Members "$User"
Add-ADGroupMember -Identity "Administrators" -Members "$User"

New-ADOrganizationalUnit -Name "PlaceHolder" -Path "$ADRoot"
New-ADGroup "ADCSAdmins" -GroupScope Universal -GroupCategory Security -Path "ou=PlaceHolder,$ADRoot"
New-ADGroup "CTRs" -GroupScope Universal -GroupCategory Security -Path "ou=PlaceHolder,$ADRoot"
New-ADComputer -Name "Research-Client" -SAMAccountName "Research-Client" -DisplayName "Research-Client" -Path "ou=PlaceHolder,$ADRoot"
New-ADComputer -Name "Dave-PC" -SAMAccountName "Dave-PC" -DisplayName "Dave-PC" -Path "ou=PlaceHolder,$ADRoot"
New-ADComputer -Name "Research-SQL" -SAMAccountName "Research-SQL" -DisplayName "Research-SQL" -Path "ou=PlaceHolder,$ADRoot"

#Store a password for users
[string]$DSRMPassword = 'SuperSecretCertPassword12!@'
# Convert to SecureString
[securestring]$OtherUserPassword = ConvertTo-SecureString $DSRMPassword -AsPlainText -Force

$OtherUser = "ADCS.admin"
New-ADUser -SamAccountName $OtherUser -Name $OtherUser -UserPrincipalName "$OtherUser@$FQDN" -AccountPassword $OtherUserPassword -Enabled $true -Description "AD CS Admin" -PasswordNeverExpires $true -Path "ou=PlaceHolder,$ADRoot"
Add-ADGroupMember -Identity "ADCSAdmins" -Members "ADCS.admin"
Add-ADGroupMember -Identity "CTRs" -Members "ADCS.admin"

#Store a password for Dave
[string]$DSRMPassword = 'PasswordReuseIsFun!'
# Convert to SecureString
[securestring]$LastUserPassword = ConvertTo-SecureString $DSRMPassword -AsPlainText -Force
$LastUser = "Dave"
New-ADUser -SamAccountName $LastUser -Name $LastUser -UserPrincipalName "$LastUser@$FQDN" -AccountPassword $LastUserPassword -Enabled $true -Description "email me at dave@research.local" -PasswordNeverExpires $true -Path "ou=PlaceHolder,$ADRoot"