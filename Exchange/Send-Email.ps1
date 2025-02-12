#resarch.local Ent Admin:
[string]$userName = "research\SQL.Admin"
[string]$userPassword = 'NoOneWillEverGuessThis1234!@#$'
# Convert to SecureString
[securestring]$secStringPassword = ConvertTo-SecureString $userPassword -AsPlainText -Force
[pscredential]$SQLAdminCredObject = New-Object System.Management.Automation.PSCredential ($userName, $secStringPassword)

#Establish a connection to the Exchange server:
#$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://Research-SQL.research.local/PowerShell/ -Authentication Kerberos -Credential $SQLAdminCredObject
Import-PSSession $Session -DisableNameChecking
New-MailMessage -Subject "Password" -Body "Is my email still NoOneWillEverGuessThis1234!@#$ ? I'm having trouble logging in."

$username = "Break.Glass@research.local"
$password = 'ExtraSafeDomainPassword1234!@#$'
$sstr = ConvertTo-SecureString -string $password -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential -argumentlist $username, $sstr
$EmailBody = "Your password has been reset. Please login with username / Password00!! . You are required to change this password at next login."
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { return $true }
Send-MailMessage -To "SQL.Admin@research.local" -from "Break.Glass@research.local" -Subject 'Password Reset' -Body $EmailBody -smtpserver "Research-SQL" -Credential $cred