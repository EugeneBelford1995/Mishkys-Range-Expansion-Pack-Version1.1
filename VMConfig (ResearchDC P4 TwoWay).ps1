#resarch.local Ent Admin:
[string]$userName = "research\Break.Glass"
[string]$userPassword = 'ExtraSafeDomainPassword1234!@#$'
# Convert to SecureString
[securestring]$secStringPassword = ConvertTo-SecureString $userPassword -AsPlainText -Force
[pscredential]$CousinDomainAdminCredObject = New-Object System.Management.Automation.PSCredential ($userName, $secStringPassword)

#lab.local Ent Admin:
[string]$userName = "lab\Break.Glass"
[string]$userPassword = 'SuperSecureDomainPassword1234!@#$'
# Convert to SecureString
[securestring]$secStringPassword = ConvertTo-SecureString $userPassword -AsPlainText -Force
[pscredential]$ParentDomainAdminCredObject = New-Object System.Management.Automation.PSCredential ($userName, $secStringPassword)

# Domain 1 (where you are running the command)
$Domain1 = "lab.local"
$Domain1Credentials = $ParentDomainAdminCredObject

# Domain 2
$Domain2 = "research.local"
$Domain2Credentials = $CousinDomainAdminCredObject

# Create the trust from Domain 1 to Domain 2
New-ADTrust -Name $Domain2 -Type Forest -Direction TwoWay -PartnerDNSName $Domain2 -Credential $Domain1Credentials

# Create the trust from Domain 2 to Domain 1
New-ADTrust -Name $Domain1 -Type Forest -Direction TwoWay -PartnerDNSName $Domain1 -Credential $Domain2Credentials