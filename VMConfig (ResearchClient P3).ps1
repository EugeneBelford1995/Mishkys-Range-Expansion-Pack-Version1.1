#Put ADCS.Admin's creds in credman on Research-Client
[string]$userName = 'research\ADCS.Admin'
[string]$userPassword = 'SuperSecretCertPassword12!@'
# Convert to SecureString
[securestring]$secStringPassword = ConvertTo-SecureString $userPassword -AsPlainText -Force
[pscredential]$CertCredObject = New-Object System.Management.Automation.PSCredential ($userName, $secStringPassword)

#This is no longer used in favor of scheduled tasks
#Install-Module -Name CredentialManager -Confirm -Force -SkipPublisherCheck
#Start-Sleep -Seconds 60
#New-StoredCredential -Comment "Access share drvie on Research-DC" -Credentials $CertCredObject -Target "Research-DC" -Persist Enterprise | Out-Null
#New-StoredCredential -Target "Research-DC" -UserName "research\ADCS.Admin" -Password 'SuperSecretCertPassword12!@' -Comment "Access share drive on Research-DC" -Persist Enterprise
#$SharedDriveCredObject = Get-StoredCredential -Target "Research-DC" -AsCredentialObject
#New-PSDrive -Name "Z" -PSProvider FileSystem -Root "\\Research-DC\NETLOGON" -Credential $SharedDriveCredObject -Persist

$taskTrigger = New-ScheduledTaskTrigger -AtStartup
$taskAction = New-ScheduledTaskAction -Execute "PowerShell" -Argument "C:\Scripts\Generate-TrafficII.ps1"
Register-ScheduledTask 'Fat Finger the Share name' -Action $taskAction -Trigger $taskTrigger -User "research\ADCS.Admin" -Password 'SuperSecretCertPassword12!@' -RunLevel Highest

#Store a password for local admin, set it the same as ADCS.Admin if the credman config has issues
[string]$DSRMPassword = 'SuperSecretLocalAdminPassword!!!'
# Convert to SecureString
[securestring]$SecureStringPassword = ConvertTo-SecureString $DSRMPassword -AsPlainText -Force

Set-LocalUser -Name Administrator -Password $SecureStringPassword
Add-LocalGroupMember -Group "Administrators" -Member "research\ADCSAdmins"
New-Item "C:\Share" -ItemType Directory
New-SMBShare -Name "Share" -Path "C:\Share"
#Enable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol

Restart-Computer -Force