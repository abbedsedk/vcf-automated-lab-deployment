$sddcManagerFQDN = "vcf-m01-sddcm01.abs.system"
$sddcManagerUsername = "administrator@vsphere.local"
$sddcManagerPassword = "VMware1!"

# License Later feature only applicable for VCF 5.1.1 and later
$LicenseLater = $true
$ESXILicense = ""
$VSANLicense = ""
$NSXLicense = ""

# Workload Domain Configurations
$VCFWorkloadDomainPoolName = "vcf-w01-rp01"
$VCFWorkloadDomainPoolFile = "networkPoolSpec.json"
$VCFWorkloadDomainAPIJSONFile = "vcf-commission-host-api.json"
$VCFWorkloadDomainName = "wld-w01"
$VCFWorkloadDomainOrgName = "vcf-w01"
$EnableVCLM = $true
$VLCMImageName = "Management-Domain-Personality" # Ensure this label matches in SDDC Manager->Lifecycle Management->Image Management
$EnableVSANESA = $false

# vCenter Configuration
$VCSAHostname = "vcf-w01-vc01"
$VCSAIP = "10.10.10.76"
$VCSARootPassword = "VMware1!VMware1!"
$VCSAvmSize = "tiny"

# Management Domain VM Network Configuration
$NestedVmManagementNetworkCidr = "10.10.10.0/24" # Variable not used here, will be displayed on configuration confirmation screen just for documentation

# Wld Domain ESXi Network Configuration
$WldNestedESXiManagementNetworkCidr = "10.13.11.0/24" # Variable not used here, will be displayed on configuration confirmation screen just for documentation
$WldNestedESXivMotionNetworkCidr = "10.13.12.0/24"
$WldNestedESXivSANNetworkCidr = "10.13.13.0/24"
$WldNestedESXiNSXTepNetworkCidr = "10.13.14.0/24"

# Wld Domain VLAN configuration
$NestedVMNetworkVLanId = 1010
$WldVmk0VLanId = 1311
$WldVmotionVLanId = 1312
$WldVsanVLanId = 1313
$WldHostTepVLanId = 1314

# NSX Configuration
$NSXManagerSize = "small"
$NSXManagerVIPHostname = "vcf-w01-nsx01"
$NSXManagerVIPIP = "10.10.10.77"
$NSXManagerNode1Hostname = "vcf-w01-nsx01a"
$NSXManagerNode1IP = "10.10.10.78"
$NSXManagerNode2Hostname = "vcf-w01-nsx01b" # All DNS records A/PTR must exist
$NSXManagerNode2IP = "10.10.10.79"
$NSXManagerNode3Hostname = "vcf-w01-nsx01c"
$NSXManagerNode3IP = "10.10.10.80"
$NSXAdminPassword = "VMware1!VMware1!"
$SeparateNSXSwitch = $true

$VMNetmask = "255.255.255.0"
$VMGateway = "10.10.10.1"
$WldVmk0Gateway = "10.13.11.1"
$VMDomain = "abs.system"
$hostFailuresToTolerate = 0
