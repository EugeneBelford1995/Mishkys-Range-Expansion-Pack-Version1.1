Import-Module ActiveDirectory
$ADRoot = (Get-ADDomain).DistinguishedName

#setup MSSQL for SQL on Dave-PC
$Password = (ConvertTo-SecureString -AsPlainText 'SuperSafeLogin1234!@#$' -Force)
New-ADUser -Name "MSSQL" -Description "runs MSSQL on the Research-SQL DB server" -SamAccountName "MSSQL" -UserPrincipalName "MSSQL@$ADRoot" -Path "ou=PlaceHolder,$ADRoot" -AccountPassword $Password -PasswordNeverExpires $true -Enabled $true
Set-ADUser -Identity "MSSQL" -ServicePrincipalNames @{Add="MSSQL/research.local"}

#Create a "SQL manager" account that will have SQL Administrator rights on Research-SQL
$Password = (ConvertTo-SecureString -AsPlainText 'NoOneWillEverGuessThis1234!@#$' -Force)
$Description = "SQL Administrator on Research-SQL"
New-ADUser -Name "SQL.Admin" -Description "$Description" -SamAccountName "SQL.Admin" -UserPrincipalName "SQL.Admin@$ADRoot" -Path "ou=PlaceHolder,$ADRoot" -AccountPassword $Password -PasswordNeverExpires $true -Enabled $true

Set-Location AD:
#Give a Dave Password reset & re-enable over SQL.Admin
$victim = (Get-ADUser "SQL.Admin").DistinguishedName
$acl = Get-ACL $victim
$user = New-Object System.Security.Principal.SecurityIdentifier (Get-ADUser -Identity "Dave").SID
#Allow specific password reset
$acl.AddAccessRule((New-Object System.DirectoryServices.ActiveDirectoryAccessRule $user,"ExtendedRight","ALLOW",([GUID]("00299570-246d-11d0-a768-00aa006e0529")).guid,"None",([GUID]("00000000-0000-0000-0000-000000000000")).guid))
#Allow specific WriteProperty on the Enabled attribute
$acl.AddAccessRule((New-Object System.DirectoryServices.ActiveDirectoryAccessRule $user,"WriteProperty","ALLOW",([GUID]("a8df73f2-c5ea-11d1-bbcb-0080c76670c0")).guid,"None",([GUID]("00000000-0000-0000-0000-000000000000")).guid))
#Apply above ACL rules
Set-ACL $victim $acl