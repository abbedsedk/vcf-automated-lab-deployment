# Author: William Lam
# Website: https://williamlam.com

# Contributor: Abbed Sedkaoui
# Website: https://strivevirtually.net

# Usage: .\vcf-automated-workload-domain-deployment.ps1 -EnvConfigFile .\sample-vcf-wld-variables.ps1

param (
    [string]$EnvConfigFile
)

# Validate that the file exists
if ($EnvConfigFile -and (Test-Path $EnvConfigFile)) {
    . $EnvConfigFile  # Dot-sourcing the config file
} else {
    Write-Host -ForegroundColor Red "`nNo valid deployment configuration file was provided or file was not found.`n"
    exit
}

#### DO NOT EDIT BEYOND HERE ####

$confirmDeployment = 1
$commissionHost = 1
$generateWLDDeploymentFile = 1
$startWLDDeployment = 1

$verboseLogFile = "vcf-workload-domain-deployment.log"
$VCFWorkloadDomainDeploymentJSONFile = "${VCFWorkloadDomainName}.json"

Function My-Logger {
    param(
    [Parameter(Mandatory=$true)][String]$message,
    [Parameter(Mandatory=$false)][String]$color="green"
    )

    $timeStamp = Get-Date -Format "MM-dd-yyyy_hh:mm:ss"

    Write-Host -NoNewline -ForegroundColor White "[$timestamp]"
    Write-Host -ForegroundColor $color " $message"
    $logMessage = "[$timeStamp] $message"
    $logMessage | Out-File -Append -LiteralPath $verboseLogFile
}

if(-Not (Get-InstalledModule -Name PowerVCF)) {
    My-Logger "PowerVCF module was not detected, please install by running: Install-Module PowerVCF"
    exit
}

if(!(Test-Path $VCFWorkloadDomainAPIJSONFile)) {
    Write-Host -ForegroundColor Red "`nUnable to find $VCFWorkloadDomainAPIJSONFile ...`n"
    exit
}

if($confirmDeployment -eq 1) {
    Write-Host -ForegroundColor Magenta "`nPlease confirm the following configuration will be deployed:`n"

    Write-Host -ForegroundColor Yellow "---- VCF Automated Workload Domain Deployment Configuration ---- "
    Write-Host -NoNewline -ForegroundColor Green "Workload Domain Name: "
    Write-Host -ForegroundColor White $VCFWorkloadDomainName
    Write-Host -NoNewline -ForegroundColor Green "Workload Domain Org Name: "
    Write-Host -ForegroundColor White $VCFWorkloadDomainOrgName
    Write-Host -NoNewline -ForegroundColor Green "Workload Domain Host Comission File: "
    Write-Host -ForegroundColor White $VCFWorkloadDomainAPIJSONFile

    Write-Host -ForegroundColor Yellow "`n---- Target SDDC Manager Configuration ---- "
    Write-Host -NoNewline -ForegroundColor Green "SDDC Manager Hostname: "
    Write-Host -ForegroundColor White $sddcManagerFQDN

    Write-Host -ForegroundColor Yellow "`n---- Workload Domain vCenter Server Configuration ----"
    Write-Host -NoNewline -ForegroundColor Green "vCenter Server Hostname: "
    Write-Host -ForegroundColor White "${VCSAHostname}.${VMDomain} (${VCSAIP})"

    Write-Host -ForegroundColor Yellow "`n---- Workload Domain NSX Server Configuration ----"
    Write-Host -NoNewline -ForegroundColor Green "NSX Manager VIP Hostname: "
    Write-Host -ForegroundColor White $NSXManagerVIPHostname"."$VMDomain
    Write-Host -NoNewline -ForegroundColor Green "NSX Manager VIP IP Address: "
    Write-Host -ForegroundColor White $NSXManagerVIPIP
    Write-Host -NoNewline -ForegroundColor Green "Node 1: "
    Write-Host -ForegroundColor White "${NSXManagerNode1Hostname}.${VMDomain} ($NSXManagerNode1IP)"
    Write-Host -NoNewline -ForegroundColor Green "Node 2: "
    Write-Host -ForegroundColor White "${NSXManagerNode2Hostname}.${VMDomain} ($NSXManagerNode2IP)"
    Write-Host -NoNewline -ForegroundColor Green "Node 3: "
    Write-Host -ForegroundColor White "${NSXManagerNode3Hostname}.${VMDomain} ($NSXManagerNode3IP)"

    Write-Host -NoNewline -ForegroundColor Green "`nVM Network Configuration from Management Domain: "
    Write-Host -ForegroundColor White $NestedVmManagementNetworkCidr
    
    Write-Host -ForegroundColor Green "`nESXi Network Configuration for Workload Domain"
    Write-Host -NoNewline -ForegroundColor Green "Workload Nested ESXi Management Network Cidr: "
    Write-Host -ForegroundColor White $WldNestedESXiManagementNetworkCidr
    Write-Host -NoNewline -ForegroundColor Green "Workload Nested ESXi vMotion Network Cidr: "
    Write-Host -ForegroundColor White $WldNestedESXivMotionNetworkCidr
    Write-Host -NoNewline -ForegroundColor Green "Workload Nested ESXi vSAN Network Cidr: "
    Write-Host -ForegroundColor White $WldNestedESXivSANNetworkCidr
    Write-Host -NoNewline -ForegroundColor Green "Workload Nested ESXi NSX Tep Network Cidr: "
    Write-Host -ForegroundColor White $WldNestedESXiNSXTepNetworkCidr
    
    Write-Host -ForegroundColor Green "`nVLAN configuration for Workload Domain"
    Write-Host -NoNewline -ForegroundColor Green "Workload Nested VM Network VLanId: "
    Write-Host -ForegroundColor White $NestedVMNetworkVLanId
    Write-Host -NoNewline -ForegroundColor Green "Workload Nested ESXi Management Network VLanId: "
    Write-Host -ForegroundColor White $Wldvmk0VLanId
    Write-Host -NoNewline -ForegroundColor Green "Workload Nested ESXi vMotion Network VLanId: "
    Write-Host -ForegroundColor White $WldvmotionVLanId
    Write-Host -NoNewline -ForegroundColor Green "Workload Nested ESXi vSAN Network VLanId: "
    Write-Host -ForegroundColor White $WldvsanVLanId
    Write-Host -NoNewline -ForegroundColor Green "Workload Nested ESXi NSX Tep Network VLanId: "
    Write-Host -ForegroundColor White $WldHostTepVLanId

    Write-Host -ForegroundColor Magenta "`nWould you like to proceed with this deployment?`n"
    $answer = Read-Host -Prompt "Do you accept (Y or N)"
    if($answer -ne "Y" -or $answer -ne "y") {
        exit
    }
    Clear-Host
}

$StartTime = Get-Date

My-Logger "Logging into SDDC Manager ..."
Request-VCFToken -fqdn $sddcManagerFQDN -username $sddcManagerUsername -password $sddcManagerPassword | Out-Null

if($commissionHost -eq 1) {
    My-Logger "Create NetworkPool for VMOTION and VSAN in $VCFWorkloadDomainPoolFile file"
    $WldESXivMotionNetwork = $WldNestedESXivMotionNetworkCidr.split("/")[0]
    $WldESXivMotionNetworkOctects = $WldESXivMotionNetwork.split(".")
    $WldESXivMotionGateway = ($WldESXivMotionNetworkOctects[0..2] -join '.') + ".1"
    $WldESXivMotionStart = ($WldESXivMotionNetworkOctects[0..2] -join '.') + ".101"
    $WldESXivMotionEnd = ($WldESXivMotionNetworkOctects[0..2] -join '.') + ".118"

    $WldESXivSANNetwork = $WldNestedESXivSANNetworkCidr.split("/")[0]
    $WldESXivSANNetworkOctects = $WldESXivSANNetwork.split(".")
    $WldESXivSANGateway = ($WldESXivSANNetworkOctects[0..2] -join '.') + ".1"
    $WldESXivSANStart = ($WldESXivSANNetworkOctects[0..2] -join '.') + ".101"
    $WldESXivSANEnd = ($WldESXivSANNetworkOctects[0..2] -join '.') + ".118"
    
    $wldPoolSpec = [ordered] @{
        "name" = $VCFWorkloadDomainPoolName
        "networks" = @(
            [ordered] @{
                "type" = "VMOTION"
                "vlanId" = $WldVmotionVLanId
                "mtu" = 9000
                "subnet" = $WldESXivMotionNetwork
                "mask" = "255.255.255.0"
                "gateway" = $WldESXivMotionGateway
                "ipPools" = @(@{"start" = $WldESXivMotionStart;"end" = $WldESXivMotionEnd})
            }
            [ordered] @{
                "type" = "VSAN"
                "vlanId" = $WldVsanVLanId
                "mtu" = 9000
                "subnet" = $WldESXivSANNetwork
                "mask" = "255.255.255.0"
                "gateway" = $WldESXivSANGateway
                "ipPools" = @(@{"start" = $WldESXivSANStart;"end" = $WldESXivSANEnd})
            }
        )
    }
    
    $wldPoolSpec | ConvertTo-Json -Depth 12 | Out-File -Force $VCFWorkloadDomainPoolFile
    $VCFWorkloadDomainPool = New-VCFNetworkPool -json (Get-Content -Raw $VCFWorkloadDomainPoolFile)
        
    My-Logger "Retreiving VCF Vi Workload Domain $VCFWorkloadDomainPoolName PoolId ..."
    $wldPoolId = (Get-VCFNetworkPool $VCFWorkloadDomainPoolName).id

    My-Logger "Updating $VCFWorkloadDomainAPIJSONFile with PoolId value ..."
    $hostCommissionFile = (Get-Content -Raw $VCFWorkloadDomainAPIJSONFile | ConvertFrom-Json)

    foreach ($line in $hostCommissionFile) {
        $line.networkPoolId = $wldPoolId

        if($EnableVSANESA) {
            $line.storageType = "VSAN_ESA"
        }
    }
    $hostCommissionFile | ConvertTo-Json | Out-File -Force $VCFWorkloadDomainAPIJSONFile

    My-Logger "Validating ESXi host commission file $VCFWorkloadDomainAPIJSONFile ..."
    $commissionHostValidationResult = New-VCFCommissionedHost -json (Get-Content -Raw $VCFWorkloadDomainAPIJSONFile) -Validate

    if($commissionHostValidationResult.resultStatus) {
        $commissionHostResult = New-VCFCommissionedHost -json (Get-Content -Raw $VCFWorkloadDomainAPIJSONFile)
    } else {
        Write-Error "Validation of host commission file $VCFWorkloadDomainAPIJSONFile failed"
        break
    }

    My-Logger "Comissioning new ESXi hosts for Workload Domain deployment using $VCFWorkloadDomainAPIJSONFile ..."
    while( (Get-VCFTask ${commissionHostResult}.id).status -ne "Successful" ) {
        My-Logger "Host commission has not completed, sleeping for 30 seconds"
        Start-Sleep -Second 30
    }
}

if($generateWLDDeploymentFile -eq 1) {
    My-Logger "Retreiving unassigned ESXi hosts from SDDC Manager and creating Workload Domain JSON deployment file $VCFWorkloadDomainDeploymentJSONFile"
    $WldESXiNSXTepNetwork = $WldNestedESXiNSXTepNetworkCidr.split("/")[0]
    $WldESXiNSXTepNetworkOctects = $WldESXiNSXTepNetwork.split(".")
    $WldESXiNSXTepGateway = ($WldESXiNSXTepNetworkOctects[0..2] -join '.') + ".1"
    $WldESXiNSXTepStart = ($WldESXiNSXTepNetworkOctects[0..2] -join '.') + ".11"
    $WldESXiNSXTepEnd = ($WldESXiNSXTepNetworkOctects[0..2] -join '.') + ".128"
    $hostSpecs = @()
    foreach ($id in (Get-VCFhost -Status UNASSIGNED_USEABLE).id) {
        if($SeparateNSXSwitch) {
            $vmNics = @(
                @{
                    "id" = "vmnic0"
                    "vdsName" = "wld-w01-cl01-vds01"
                }
                @{
                    "id" = "vmnic1"
                    "vdsName" = "wld-w01-cl01-vds01"
                }
                @{
                    "id" = "vmnic2"
                    "vdsName" = "wld-w01-cl01-vds02"
                }
                @{
                    "id" = "vmnic3"
                    "vdsName" = "wld-w01-cl01-vds02"
                }
            )
        } else {
                $vmNics = @(
                @{
                    "id" = "vmnic0"
                    "vdsName" = "wld-w01-cl01-vds01"
                }
                @{
                    "id" = "vmnic1"
                    "vdsName" = "wld-w01-cl01-vds01"
                }
            )
        }

        $tmp = [ordered] @{
            "id" = $id
            "licenseKey" = $ESXILicense
            "hostNetworkSpec" = @{
                "vmNics" = $vmNics
            }
        }
        $hostSpecs += $tmp
    }

    $payload = [ordered] @{
        "domainName" = $VCFWorkloadDomainName
        "orgName" = $VCFWorkloadDomainOrgName
        "vcenterSpec" = @{
            "name" = $VCSAHostname
            "networkDetailsSpec" = @{
                "ipAddress" = $VCSAIP
                "dnsName" = $VCSAHostname + "." + $VMDomain
                "gateway" = $VMGateway
                "subnetMask" = $VMNetmask
            }
            "rootPassword" = $VCSARootPassword
            "datacenterName" = "wld-w01-dc01"
            "vmSize" = $VCSAvmSize
        }
        "computeSpec" = [ordered] @{
            "clusterSpecs" = @(
                [ordered] @{
                    "name" = "wld-w01-cl01"
                    "hostSpecs" = $hostSpecs
                    "datastoreSpec" = @{
                        "vsanDatastoreSpec" = @{
                            "failuresToTolerate" = $hostFailuresToTolerate
                            "licenseKey" = $VSANLicense
                            "datastoreName" = "wld-w01-cl01-vsan01"
                        }
                    }
                    "networkSpec" = @{
                        "vdsSpecs" = @(
                            [ordered] @{
                                "name" = "wld-w01-cl01-vds01"
                                "portGroupSpecs" = @(
                                [ordered] @{
                                        "name" = "wld-w01-cl01-vds01-ESXi-management"
                                        "transportType" = "MANAGEMENT"
                                    }
                                    @{
                                        "name" = "wld-w01-cl01-vds01-vmotion"
                                        "transportType" = "VMOTION"
                                    }
                                    @{
                                        "name" = "wld-w01-cl01-vds01-vsan"
                                        "transportType" = "VSAN"
                                    }
                                )
                            }
                        )
                        "nsxClusterSpec" = [ordered] @{
                            "nsxTClusterSpec" = @{
                                "geneveVlanId" = $WldHostTepVLanId
                                "ipAddressPoolSpec" = @{
                                    "name" = "wld-pool"
                                    "subnets" = @(
                                        [ordered] @{
                                            "cidr" = $WldNestedESXiNSXTepNetworkCidr
                                            "gateway" = $WldESXiNSXTepGateway
                                            "ipAddressPoolRanges" = @(@{"start" = $WldESXiNSXTepStart;"end" = $WldESXiNSXTepEnd})
                                        }
                                    )
                                }
                            }
                        }
                    }
                }
            )
        }
        "nsxTSpec" = [ordered] @{
            "nsxtManagerSize" = $NSXManagerSize
            "nsxManagerSpecs" = @(
                [ordered] @{
                    "name" = $NSXManagerNode1Hostname
                    "networkDetailsSpec" = @{
                        "ipAddress" = $NSXManagerNode1IP
                        "dnsName" = $NSXManagerNode1Hostname + "." + $VMDomain
                        "gateway" = $VMGateway
                        "subnetMask" = $VMNetmask
                    }
                }
                [ordered] @{
                    "name" = $NSXManagerNode2Hostname
                    "networkDetailsSpec" = @{
                        "ipAddress" = $NSXManagerNode2IP
                        "dnsName" = $NSXManagerNode2Hostname + "." + $VMDomain
                        "gateway" = $VMGateway
                        "subnetMask" = $VMNetmask
                    }
                }
                [ordered] @{
                    "name" = $NSXManagerNode3Hostname
                    "networkDetailsSpec" = @{
                        "ipAddress" = $NSXManagerNode3IP
                        "dnsName" = $NSXManagerNode3Hostname + "." + $VMDomain
                        "gateway" = $VMGateway
                        "subnetMask" = $VMNetmask
                    }
                }
            )
            "vip" = $NSXManagerVIPIP
            "vipFqdn" = $NSXManagerVIPHostname + "." + $VMDomain
            "licenseKey" = $NSXLicense
            "nsxManagerAdminPassword" = $NSXAdminPassword
        }
    }

	if($SeparateNSXSwitch) {
			$sepNsxSwitchSpec = [ordered]@{
				"name" = "wld-w01-cl01-vds02"
                "vmnics" = @("vmnic2","vmnic3")
                "mtu" = 9000
				"nsxtSwitchConfig" = [ordered]@{
					"transportZones" = @(
						[ordered]@{
						"name" = "vcf-m01-tz-overlay01"
						"transportType" = "OVERLAY"
						}
						[ordered]@{
						"name" = "vcf-m01-tz-vlan01"
						"transportType" = "VLAN"
						}
					)
					"hostSwitchOperationalMode" = "ENS_INTERRUPT"
				}
			}
            $payload.computeSpec.clusterSpecs.networkSpec.vdsSpecs+=$sepNsxSwitchSpec
    }

    if($LicenseLater) {
        if($ESXILicense -eq "" -and $VSANLicense -eq "" -and $NSXLicense -eq "") {
            $EvaluationMode = $true
        } else {
            $EvaluationMode = $false
        }
        $payload.add("deployWithoutLicenseKeys",$EvaluationMode)
    }

    if($EnableVSANESA) {
        $esaEnable = [ordered]@{
            "enabled" = $true
        }
        $payload.computeSpec.clusterSpecs.datastoreSpec.vsanDatastoreSpec.Add("esaConfig",$esaEnable)

        $payload.computeSpec.clusterSpecs.datastoreSpec.vsanDatastoreSpec.Remove("failuresToTolerate")
    }

    if($EnableVCLM) {
        $clusterImageId = (Get-VCFPersonality | where {$_.personalityName -eq $VLCMImageName}).personalityId

        if($clusterImageId -eq $null) {
            Write-Host -ForegroundColor Red "`nUnable to find vLCM Image named $VLCMImageName ...`n"
            exit
        }

        $payload.computeSpec.clusterSpecs[0].Add("clusterImageId",$clusterImageId)
    }

    $payload | ConvertTo-Json -Depth 12 | Out-File $VCFWorkloadDomainDeploymentJSONFile
}

if($startWLDDeployment -eq 1) {
    My-Logger "Starting Workload Domain deployment using file $VCFWorkloadDomainDeploymentJSONFile"
    $wldDeployment = New-VCFWorkloadDomain -json $VCFWorkloadDomainDeploymentJSONFile

    My-Logger "Open a browser to your SDDC Manager to monitor the deployment progress"
}

$EndTime = Get-Date
$duration = [math]::Round((New-TimeSpan -Start $StartTime -End $EndTime).TotalMinutes,2)

My-Logger "VCF Workload Domain Deployment Complete!"
My-Logger "StartTime: $StartTime"
My-Logger "EndTime: $EndTime"
My-Logger "Duration: $duration minutes to initiate Workload Domain deployment"
