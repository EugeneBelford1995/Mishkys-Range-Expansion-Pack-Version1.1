Import-Module ActiveDirectory
Set-Location AD:

$Objects = (Get-ADObject -Filter * -Properties *).DistinguishedName
ForEach($Object in $Objects)
{
If((Get-Acl $Object).Access | Where-Object {$_.AccessControlType -eq "Deny"})
{
$Object
(Get-Acl $Object).Access | Where-Object {$_.AccessControlType -eq "Deny"}
}
}