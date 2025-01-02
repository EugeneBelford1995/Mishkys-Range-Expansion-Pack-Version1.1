#Borrowed from https://www.anujvarma.com/powershell-to-create-ad-trust/
# Change following parameters 

$strRemoteForest = "lab.local" 
$strRemoteAdmin = "Administrator" 
$strRemoteAdminPassword = "SuperSecureDomainPassword1234!@#$" 
$remoteContext = New-Object -TypeName "System.DirectoryServices.ActiveDirectory.DirectoryContext" -ArgumentList @( "Forest",$strRemoteForest, $strRemoteAdmin, $strRemoteAdminPassword) 

try { 
$remoteForest =[System.DirectoryServices.ActiveDirectory.Forest]::getForest($remoteContext) 
#Write-Host "GetRemoteForest: Succeeded for domain $($remoteForest)" 
} 

catch { 
Write-Warning "GetRemoteForest: Failed:`n`tError: $($($_.Exception).Message)" 
} 

Write-Host "Connected to Remote forest: $($remoteForest.Name)" 
$localforest=[System.DirectoryServices.ActiveDirectory.Forest]::getCurrentForest() 
Write-Host "Connected to Local forest: $($localforest.Name)" 

try {
#Makes Research.local trust Lab.local 
#$localForest.CreateTrustRelationship($remoteForest,"Outbound")
#Makes Research.local and lab.local trust each other
$localForest.CreateTrustRelationship($remoteForest,"Bidirectional")
Write-Host "CreateTrustRelationship: Succeeded for domain $($remoteForest)" 
} 

catch { 
Write-Warning "CreateTrustRelationship: Failed for domain$($remoteForest)`n`tError: $($($_.Exception).Message)" 
}