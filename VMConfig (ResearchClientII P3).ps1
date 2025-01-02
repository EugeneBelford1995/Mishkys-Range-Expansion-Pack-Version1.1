#Store a password for local admin
[string]$DSRMPassword = 'ExtraSecretLocalAdminPassword!!'
# Convert to SecureString
[securestring]$SecureStringPassword = ConvertTo-SecureString $DSRMPassword -AsPlainText -Force

Set-LocalUser -Name Administrator -Password $SecureStringPassword
Add-LocalGroupMember -Group "Administrators" -Member "research\Dave"

Restart-Computer -Force