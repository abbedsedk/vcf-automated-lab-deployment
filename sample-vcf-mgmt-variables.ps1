# Your Management vCenter Server that will be used to deploy the VMware Cloud Foundation Lab
$VIServer = "vcsa-host-lab.abs.system"
$VIUsername = "administrator@vsphere.local"
$VIPassword = "VMware1!"

# General Deployment Configuration for your Nested ESXi & Cloud Builder VM
$VMDatacenter = "TLS-Datacenter"
$VMCluster = "Cluster-01-A"
$VMNetwork = "VMTRUNK"
$CBVMNetwork = "101010-Network"
$VMDatastore = "datastore1-a"
$VMNetmask = "255.255.255.0"
$VMGateway = "10.10.10.1"
$vmk0Gateway = "10.10.11.1"
$VMDNS = "192.168.1.100"
$VMNTP = "vyos-a.abs.system"
$VMPassword = "VMware1!"
$VMDomain = "abs.system"
$VMSyslog = "10.10.10.182"
$VMFolder = "abs-vcf511"
$hostFailuresToTolerate = 0

# Full Path to both the Nested ESXi & Cloud Builder OVA
$NestedESXiApplianceOVA = "O:\VCF-LAB\Nested_ESXi8.0u2b_Appliance_Template_v2.ova"
$CloudBuilderOVA = "O:\VCF-LAB\VMware-Cloud-Builder-5.1.1.0-23480823_OVF10.ova"

# VCF Licenses or leave blank for evaluation mode (requires VCF 5.1.1 or later)
$VCSALicense = ""
$ESXILicense = ""
$VSANLicense = ""
$NSXLicense = ""

# VCF Configurations
$VCFManagementDomainPoolName = "vcf-m01-rp01"
$VCFManagementDomainJSONFile = "vcf-mgmt.json"
$VCFWorkloadDomainPoolName = "vcf-w01-rp01"
$VCFWorkloadDomainUIJSONFile = "vcf-commission-host-ui.json"
$VCFWorkloadDomainAPIJSONFile = "vcf-commission-host-api.json"

# Cloud Builder Configurations
$CloudbuilderVMHostname = "vcf-m01-cb01"
$CloudbuilderFQDN = "vcf-m01-cb01.abs.system"
$CloudbuilderIP = "10.10.10.180"
$CloudbuilderAdminUsername = "admin"
$CloudbuilderAdminPassword = "VMw@re123!VMw@re123!"
$CloudbuilderRootPassword = "VMw@re123!VMw@re123!"

# SDDC Manager Configuration
$SddcManagerHostname = "vcf-m01-sddcm01"
$SddcManagerIP = "10.10.10.181"
$SddcManagerVcfPassword = "VMware1!VMware1!"
$SddcManagerRootPassword = "VMware1!VMware1!"
$SddcManagerRestPassword = "VMware1!VMware1!"
$SddcManagerLocalPassword = "VMware1!VMware1!"

# Nested ESXi VMs for Management Domain
$NestedESXiHostnameToIPsForManagementDomain = @{
    "vcf-m01-esx01"   = "10.10.11.185"
    #"vcf-m01-esx02"   = "10.10.11.186"
    #"vcf-m01-esx03"   = "10.10.11.187"
    #"vcf-m01-esx04"   = "10.10.11.188"
}

# Nested ESXi VMs for Workload Domain
$NestedESXiHostnameToIPsForWorkloadDomain = @{
    "vcf-w01-esx01"   = "10.13.11.191"
    "vcf-w01-esx02"   = "10.13.11.192"
    #"vcf-w01-esx03"   = "10.13.11.193"
    #"vcf-w01-esx04"   = "10.13.11.194"
}

# Nested ESXi VM Resources for Management Domain
$NestedESXiMGMTvCPU = "16"
$NestedESXiMGMTvMEM = "96" #GB
$NestedESXiMGMTCachingvDisk = "4" #GB
$NestedESXiMGMTCapacityvDisk = "1000" #GB
$NestedESXiMGMTBootDisk = "32" #GB

# Nested ESXi VM Resources for Workload Domain
$NestedESXiWLDVSANESA = $false
$NestedESXiWLDvCPU = "8"
$NestedESXiWLDvMEM = "32" #GB
$NestedESXiWLDCachingvDisk = "4" #GB
$NestedESXiWLDCapacityvDisk = "500" #GB
$NestedESXiWLDBootDisk = "32" #GB

# Mgmt Domain VM Network Configuration
$NestedVmManagementNetworkCidr = "10.10.10.0/24"

# Mgmt Domain ESXi Network Configuration
$NestedESXiManagementNetworkCidr = "10.10.11.0/24"
$NestedESXivMotionNetworkCidr = "10.10.12.0/24"
$NestedESXivSANNetworkCidr = "10.10.13.0/24"
$NestedESXiNSXTepNetworkCidr = "10.10.14.0/24"

# Mgmt Domain VLAN configuration
$NestedVMNetworkVLanId = "1010"
$vmk0VLanId = "1011"
$vmotionVLanId = "1012"
$vsanVLanId = "1013"
$HostTepVLanId = "1014"

# Wld Domain configuration
$WldVmk0VLanId = "1311"
$WldVmk0Gateway = "10.13.11.1"

# vCenter Configuration
$VCSAName = "vcf-m01-vc01"
$VCSAIP = "10.10.10.182"
$VCSARootPassword = "VMware1!"
$VCSASSOPassword = "VMware1!"
$EnableVCLM = $true

# NSX Configuration
$NSXManagerSize = "small"
$NSXManagerVIPHostname = "vcf-m01-nsx01"
$NSXManagerVIPIP = "10.10.10.183"
$NSXManagerNode1Hostname = "vcf-m01-nsx01a"
$NSXManagerNode1IP = "10.10.10.184"
$NSXRootPassword = "VMware1!VMware1!"
$NSXAdminPassword = "VMware1!VMware1!"
$NSXAuditPassword = "VMware1!VMware1!"
