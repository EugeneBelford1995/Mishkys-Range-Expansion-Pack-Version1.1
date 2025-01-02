Install-WindowsFeature ADCS-Cert-Authority -IncludeManagementTools

$params = @{
    CAType              = "EnterpriseRootCA"
    CryptoProviderName  = "RSA#Microsoft Software Key Storage Provider"
    KeyLength           = 2048
    HashAlgorithmName   = "SHA256"
    ValidityPeriod      = "Years"
    ValidityPeriodUnits = "5"
}
Install-AdcsCertificationAuthority @params -Force

Start-Sleep -Seconds 60

#Install Nu-Get & ADCSTemplate
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Install-PackageProvider -Name NuGet -Force
Install-Module -Name ADCSTemplate -Force
Install-Module -Name xAdcsDeployment -Force #Optional

New-ADCSTemplate -DisplayName "HTTPsCertificates" -JSON (Get-Content "C:\HTTPsCertificates.json" -Raw) -Publish

#Publish the Template
Import-Module ADCSAdministration
$TemplateName = "HTTPsCertificates"
#$CA = Get-CA
Add-CATemplate -Name $TemplateName #-CA $CA