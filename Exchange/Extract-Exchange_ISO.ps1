#Download Exchange ISO from https://download.microsoft.com/download/b/c/7/bc766694-8398-4258-8e1e-ce4ddb9b3f7d/ExchangeServer2019-x64-CU12.ISO
#Save it as C:\VM_Stuff_Share\ISOs\ExchangeServer2019-x64-CU12.ISO
#Run this part on the hypervisor to extract Exchange from the ISO and then create the Zip
#Mishky's AD Range uploads the ZIP to a VM, intalls, & configures Exchange automatically

Invoke-WebRequest "https://download.microsoft.com/download/b/c/7/bc766694-8398-4258-8e1e-ce4ddb9b3f7d/ExchangeServer2019-x64-CU12.ISO" -OutFile "C:\VM_Stuff_Share\ISOs\ExchangeServer2019-x64-CU12.ISO"
New-Item -Path "C:\VM_Stuff_Share\Exchange" -ItemType Directory
$mountResult = Mount-DiskImage -ImagePath 'C:\VM_Stuff_Share\ISOs\ExchangeServer2019-x64-CU12.ISO' -PassThru
$volumeInfo = $mountResult | Get-Volume
$driveInfo = Get-PSDrive -Name $volumeInfo.DriveLetter
Copy-Item -Path ( Join-Path -Path $driveInfo.Root -ChildPath '*' ) -Destination "C:\VM_Stuff_Share\Exchange" -Recurse
Dismount-DiskImage -ImagePath 'C:\VM_Stuff_Share\ISOs\ExchangeServer2019-x64-CU12.ISO'
Compress-Archive -Path "C:\VM_Stuff_Share\Exchange\*" -DestinationPath "C:\VM_Stuff_Share\Lab_Version1.1\CousinDomain\Exchange.zip"