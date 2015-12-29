###   Enable Firewall for ISCSI
Set-NetFirewallRule -DisplayGroup 'iSCSI Service' -Enabled True

###   Enable MPIO
Enable-WindowsOptionalFeature –Online –FeatureName MultiPathIO
Enable-MSDSMAutomaticClaim –BusType iSCSI

###   Enable iSCSI Service
Set-Service -Name msiscsi -StartupType Automatic
Start-Service -Name msiscsi

###   Enable Jumbo Frames
Set-NetAdapterAdvancedProperty -Name * -RegistryKeyword “*JumboPacket” -Registryvalue 9014

#Get IP Addresses
###   Prepare Data Disk
Get-Disk |
Where partitionstyle -eq 'raw' |
Initialize-Disk -PartitionStyle GPT -PassThru |
New-Partition -DriveLetter S -UseMaximumSize |
Format-Volume -FileSystem NTFS -NewFileSystemLabel "Starwind" -Confirm:$false 

### Connect iSCSI 


New-IscsiTargetPortal 
-TargetPortalAddress 10.0.1.4 | `
Get-IscsiTarget|?{$_.NodeAddress} | Connect-IscsiTarget `
-IsMultipathEnabled $true `
-IsPersistent $true 

New-IscsiTargetPortal 
-TargetPortalAddress 127.0.0.1 | `
Get-IscsiTarget|?{$_.NodeAddress} | Connect-IscsiTarget `
-IsMultipathEnabled $true `
-IsPersistent $true 

Connect-IscsiTarget -TargetPortalAddress 10.0.1.4 `
-NodeAddress iqn.2008-08.com.starwindsoftware:10.0.1.4-starwind `
-IsMultipathEnabled $true `
-IsPersistent $true

Connect-IscsiTarget -TargetPortalAddress 127.0.0.1 `
-NodeAddress iqn.2008-08.com.starwindsoftware:vm-starwind `
-IsMultipathEnabled $true `
-IsPersistent $true


