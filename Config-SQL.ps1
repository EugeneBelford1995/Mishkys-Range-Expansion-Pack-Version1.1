#https://devblogs.microsoft.com/scripting/use-powershell-to-change-sql-server-service-accounts/

#Get SQL info
#Get-WmiObject win32_service -computer Dave-PC | Where-Object {$_.name -match “^*SQL*”} | select SystemName, Name, StartName, PathName

#Get more detailed info
#[System.Reflection.Assembly]::LoadWithPartialName(“Microsoft.SqlServer.SqlWmiManagement”) | out-null
#$SMOWmiserver = New-Object (‘Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer’) “Dave-PC” #pull in the server you want   
#$SMOWmiserver.Services | Select-Object name, type, ServiceAccount, DisplayName, StartMode, StartupParameters | Format-Table

[System.Reflection.Assembly]::LoadWithPartialName(“Microsoft.SqlServer.SqlWmiManagement”) | out-null
$SMOWmiserver = New-Object (‘Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer’) “Research-SQL” #pull in the server you want           

#Check which service you have loaded first
$ChangeService | select name, type, ServiceAccount, DisplayName, Properties, StartMode, StartupParameters | Format-Table

#Specify the “Name” (from the query above) of the one service whose Service Account you want to change.
$ChangeService=$SMOWmiserver.Services | where {$_.name -eq “MSSQLSERVER”} #Make sure this is what you want changed!

$UName=”research\MSSQL”
$PWord='SuperSafeLogin1234!@#$'           

$ChangeService.SetServiceAccount($UName, $PWord)
#Now take a look at it afterwards

$ChangeService | select name, type, ServiceAccount, DisplayName, Properties, StartMode, StartupParameters | Format-Table

#default is NT Service\MSSQLSERVER

Add-LocalGroupMember -Group "Administrators" -Member "research\MSSQL"
Set-Service -Name "SQLServerAgent" -StartupType Automatic 
Set-Service -Name "SQLBrowser" -StartupType Automatic

New-NetFirewallRule -DisplayName "SQLServer default instance" -Direction Inbound -LocalPort 1433 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "SQLServer Browser service" -Direction Inbound -LocalPort 1434 -Protocol UDP -Action Allow

Restart-Computer -Force