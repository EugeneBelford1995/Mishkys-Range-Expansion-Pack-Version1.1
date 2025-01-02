Import-Module ActiveDirectory
Set-Location AD:
$ADRoot = (Get-ADDomain).DistinguishedName

#Give MSSQL WriteProperty 'ms-DS-Allowed-To-Act-On-Behalf-Of-Other-Identity' on a given computer,
#or comment that line out, give them WriteDACL, and let them figure out how to give themselves the right required
$victim = (Get-ADComputer "cn=Research-Client,ou=PlaceHolder,$ADRoot" -Properties *).DistinguishedName
$acl = Get-ACL $victim
$user = New-Object System.Security.Principal.SecurityIdentifier (Get-ADUser "MSSQL").SID
#$acl.AddAccessRule((New-Object System.DirectoryServices.ActiveDirectoryAccessRule $user,"WriteProperty","ALLOW",([GUID]("3f78c3e5-f79a-46bd-a0b8-9d18116ddc79")).guid,"None",([GUID]("00000000-0000-0000-0000-000000000000")).guid))
$acl.AddAccessRule((New-Object System.DirectoryServices.ActiveDirectoryAccessRule $user,"WriteDACL","ALLOW",([GUID]("00000000-0000-0000-0000-000000000000")).guid,"None",([GUID]("00000000-0000-0000-0000-000000000000")).guid))
#Apply above ACL rules
Set-ACL $victim $acl

#Give MSSQL the ability to create default computer accounts in AD
$victim = (Get-ADObject "cn=computers,$ADRoot" -Properties *).DistinguishedName
$acl = Get-ACL $victim
$user = New-Object System.Security.Principal.SecurityIdentifier (Get-ADUser "MSSQL").SID
$acl.AddAccessRule((New-Object System.DirectoryServices.ActiveDirectoryAccessRule $user,"CreateChild","ALLOW",([GUID]("00000000-0000-0000-0000-000000000000")).guid,"None",([GUID]("00000000-0000-0000-0000-000000000000")).guid))
#Apply above ACL rules
Set-ACL $victim $acl

#Give ADCSAdmins ReadProperty, GenericExecute, Autoenroll, Enroll on HTTPsCertificates
$victim = (Get-ADObject "CN=HTTPsCertificates,CN=Certificate Templates,CN=Public Key Services,CN=Services,CN=Configuration,$ADRoot").DistinguishedName
$acl = Get-ACL $victim
$user = New-Object System.Security.Principal.SecurityIdentifier (Get-ADGroup "ADCSAdmins").SID
$acl.AddAccessRule((New-Object System.DirectoryServices.ActiveDirectoryAccessRule $user,"ReadProperty","ALLOW",([GUID]("00000000-0000-0000-0000-000000000000")).guid,"None",([GUID]("00000000-0000-0000-0000-000000000000")).guid))
$acl.AddAccessRule((New-Object System.DirectoryServices.ActiveDirectoryAccessRule $user,"GenericExecute","ALLOW",([GUID]("00000000-0000-0000-0000-000000000000")).guid,"None",([GUID]("00000000-0000-0000-0000-000000000000")).guid))
$acl.AddAccessRule((New-Object System.DirectoryServices.ActiveDirectoryAccessRule $user,"ExtendedRight","ALLOW",([GUID]("a05b8cc2-17bc-4802-a710-e7c15ab866a2")).guid,"None",([GUID]("00000000-0000-0000-0000-000000000000")).guid))
$acl.AddAccessRule((New-Object System.DirectoryServices.ActiveDirectoryAccessRule $user,"ExtendedRight","ALLOW",([GUID]("0e10c968-78fb-11d2-90d4-00c04f79dc55")).guid,"None",([GUID]("00000000-0000-0000-0000-000000000000")).guid))
#Apply above ACL rules
Set-ACL $victim $acl

#Deny CTRs all Extended rights on HTTPsCertificates
$victim = (Get-ADObject "CN=HTTPsCertificates,CN=Certificate Templates,CN=Public Key Services,CN=Services,CN=Configuration,$ADRoot").DistinguishedName
$acl = Get-ACL $victim
$user = New-Object System.Security.Principal.SecurityIdentifier (Get-ADGroup "CTRs").SID
$acl.AddAccessRule((New-Object System.DirectoryServices.ActiveDirectoryAccessRule $user,"ExtendedRight","DENY",([GUID]("00000000-0000-0000-0000-000000000000")).guid,"None",([GUID]("00000000-0000-0000-0000-000000000000")).guid))
#Apply above ACL rules
Set-ACL $victim $acl

#Give ADCSAdmins WriteProperty Membership Property Set on CTRs
$victim = (Get-ADGroup -Identity "CTRs").DistinguishedName
$acl = Get-ACL $victim
$user = New-Object System.Security.Principal.SecurityIdentifier (Get-ADGroup "ADCSAdmins").SID
$acl.AddAccessRule((New-Object System.DirectoryServices.ActiveDirectoryAccessRule $user,"WriteProperty","ALLOW",([GUID]("bc0ac240-79a9-11d0-9020-00c04fc2d4cf")).guid,"None",([GUID]("00000000-0000-0000-0000-000000000000")).guid))
#Apply above ACL rules
Set-ACL $victim $acl