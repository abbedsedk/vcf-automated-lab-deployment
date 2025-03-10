# Your Management vCenter Server that will be used to deploy the VMware Cloud Foundation Lab
$VIServer = "FILL_ME_IN"
$VIUsername = "FILL_ME_IN"
$VIPassword = "FILL_ME_IN"

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
$VMNTP = "192.168.1.253"
$VMPassword = "VMware1!"
$VMDomain = "abidi.systems"
$VMSyslog = "10.10.10.182"
$VMFolder = "abs-vcf511"
$hostFailuresToTolerate = 0

# Full Path to both the Nested ESXi & Cloud Builder OVA
$NestedESXiApplianceOVA = "O:\VCF-LAB\Nested_ESXi8.0u2b_Appliance_Template_v1.ova"
$CloudBuilderOVA = "O:\VCF-LAB\VMware-Cloud-Builder-5.1.1.0-23480823_OVF10.ova"

# VCF Licenses or leave blank for evaluation mode (requires VCF 5.1.1 or later)
$VCSALicense = ""
$ESXILicense = ""
$VSANLicense = ""
$NSXLicense = ""

# VCF Configurations
$VCFManagementDomainPoolName = "vcf-m01-rp01"
$VCFManagementDomainJSONFile = "vcf-mgmt.json"
$VCFWorkloadDomainUIJSONFile = "vcf-commission-host-ui.json"
$VCFWorkloadDomainAPIJSONFile = "vcf-commission-host-api.json"

# Cloud Builder Configurations
$CloudbuilderVMHostname = "vcf-m01-cb01"
$CloudbuilderFQDN = "vcf-m01-cb01.abidi.systems"
$CloudbuilderIP = "10.10.10.180"         #must be on same subnet as $NestedVmManagementNetworkCidr (10.10.10.0/24)
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

# Nested ESXi VMs for Management Domain see https://williamlam.com/2023/02/vmware-cloud-foundation-with-a-single-esxi-host-for-management-domain.html for the required tweaks
$NestedESXiHostnameToIPsForManagementDomain = @{
    "vcf-m01-esx01"   = "10.10.11.185"
    "vcf-m01-esx02"   = "10.10.11.186"
    #"vcf-m01-esx03"   = "10.10.11.187"  #uncomment for default VCF required 4 VSAN Ready Nodes
    #"vcf-m01-esx04"   = "10.10.11.188"  #uncomment for default VCF required 4 VSAN Ready Nodes
}

# Nested ESXi VMs for Workload Domain
$NestedESXiHostnameToIPsForWorkloadDomain = @{
    "vcf-w01-esx01"   = "172.16.30.72"
    "vcf-w01-esx02"   = "172.16.30.73"
    "vcf-w01-esx03"   = "172.16.30.74"
    "vcf-w01-esx04"   = "172.16.30.75"
}

# Nested ESXi VM Resources for Management Domain
$NestedESXiMGMTvCPU = "8"                #12 default value
$NestedESXiMGMTvMEM = "52" #GB           #96 default value
$NestedESXiMGMTCachingvDisk = "4" #GB
$NestedESXiMGMTCapacityvDisk = "500" #GB
$NestedESXiMGMTBootDisk = "32" #GB

# Nested ESXi VM Resources for Workload Domain
$NestedESXiWLDVSANESA = $false
$NestedESXiWLDvCPU = "8"
$NestedESXiWLDvMEM = "36" #GB
$NestedESXiWLDCachingvDisk = "4" #GB
$NestedESXiWLDCapacityvDisk = "250" #GB
$NestedESXiWLDBootDisk = "32" #GB

# VM Network Configuration
$NestedVmManagementNetworkCidr = "10.10.10.0/24"   #gateway editable here $VMGateway (10.10.10.1)

# ESXi Network Configuration
$NestedESXiManagementNetworkCidr = "10.10.11.0/24" #gateway editable here $vmk0Gateway (10.10.11.1)
$NestedESXivMotionNetworkCidr = "10.10.12.0/24"    #gateway not editable here also is .1 $esxivMotionGateway (10.10.12.1) on upstream tor (vyos)
$NestedESXivSANNetworkCidr = "10.10.13.0/24"       #gateway not editable here also is .1 $esxivSANGateway (10.10.13.1) on upstream tor (vyos)
$NestedESXiNSXTepNetworkCidr = "10.10.14.0/24"     #gateway not editable here also is .1 $esxiNSXTepGateway (10.10.14.1) on upstream tor (vyos)

# VLAN configuration
$NestedVMNetworkVLanId = "10"
$vmk0VLanId = "11"
$vmotionVLanId = "12"
$vsanVLanId = "13"
$HostTepVLanId = "14"

# vCenter Configuration
$VCSAName = "vcf-m01-vc01"
$VCSAIP = "10.10.10.182"
$VCSARootPassword = "VMware1!"
$VCSASSOPassword = "VMware1!"
$EnableVCLM = $true

# NSX Configuration
$NSXManagerSize = "medium"
$NSXManagerVIPHostname = "vcf-m01-nsx01"
$NSXManagerVIPIP = "10.10.10.183"
$NSXManagerNode1Hostname = "vcf-m01-nsx01a"
$NSXManagerNode1IP = "10.10.10.184"
$NSXRootPassword = "VMware1!VMware1!"
$NSXAdminPassword = "VMware1!VMware1!"
$NSXAuditPassword = "VMware1!VMware1!"
