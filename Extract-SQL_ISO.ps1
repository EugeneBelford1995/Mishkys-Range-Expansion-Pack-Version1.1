#Download MSSQL ISO from https://www.microsoft.com/en-us/sql-server/sql-server-downloads
#Save it as C:\VM_Stuff_Share\ISOs\SQLServer2022-x64-ENU.iso
#Run this part on the hypervisor to extract SQL from the ISO and then create the Zip
#Mishky's AD Range uploads the ZIP to a VM, intalls, & configures MSSQL automatically
New-Item -Path "C:\VM_Stuff_Share\SQL2022" -ItemType Directory
$mountResult = Mount-DiskImage -ImagePath 'C:\VM_Stuff_Share\ISOs\SQLServer2022-x64-ENU.iso' -PassThru
$volumeInfo = $mountResult | Get-Volume
$driveInfo = Get-PSDrive -Name $volumeInfo.DriveLetter
Copy-Item -Path ( Join-Path -Path $driveInfo.Root -ChildPath '*' ) -Destination "C:\VM_Stuff_Share\SQL2022" -Recurse
Dismount-DiskImage -ImagePath 'C:\VM_Stuff_Share\ISOs\SQLServer2022-x64-ENU.iso'
Compress-Archive -Path "C:\VM_Stuff_Share\SQL2022\*" -DestinationPath "C:\VM_Stuff_Share\Lab_Version1.1\CousinDomain\SQL2022.zip"
