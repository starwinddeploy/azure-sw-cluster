###   Enable Firewall for ISCSI
Set-NetFirewallRule -DisplayGroup 'iSCSI Service' -Enabled True

###   Enable MPIO
Enable-WindowsOptionalFeature �Online �FeatureName MultiPathIO
Enable-MSDSMAutomaticClaim �BusType iSCSI

###   Enable iSCSI Service
Set-Service -Name msiscsi -StartupType Automatic
Start-Service -Name msiscsi

###   Enable Jumbo Frames
Set-NetAdapterAdvancedProperty -Name * -RegistryKeyword �*JumboPacket� -Registryvalue 9014

#Get IP Addresses
###   Prepare Data Disk
Get-Disk |
Where partitionstyle -eq 'raw' |
Initialize-Disk -PartitionStyle GPT -PassThru |
New-Partition -DriveLetter S -UseMaximumSize |
Format-Volume -FileSystem NTFS -NewFileSystemLabel "Starwind" -Confirm:$false 
 

####   Create Starwind HA Device

Import-Module StarWindX

$imagename = "imageh"
$targetname = "starwind"
$devicesize = "1024"
try
{
    $server = New-SWServer -host 10.0.1.5 -port 3261 -user root -password starwind

    $server.Connect()

    $firstNode = new-Object Node

    $firstNode.ImagePath = "My computer\C"
    $firstNode.ImageName = $imagename
    $firstNode.Size = $devicesize
    $firstNode.CreateImage = $true
    $firstNode.TargetAlias = $targetname
    $firstNode.AutoSynch = $true
    $firstNode.SyncInterface = "#p2=10.0.2.5:3260"
    $firstNode.HBInterface = "#p2=10.0.1.4:3260"
    $firstNode.CacheSize = 64
    $firstNode.CacheMode = "wb"
    $firstNode.PoolName = "pool1"
    $firstNode.SyncSessionCount = 1
    $firstNode.ALUAOptimized = $true
	
	#
	# 'SerialID' should be between 16 and 31 symbols. If it not specified StarWind Service will generate it. 
	# Note: Second node always has the same serial ID. You do not need to specify it for second node
	#
	#$firstNode.SerialID = "050176c0b535403ba3ce02102e33eab" 
    
    $secondNode = new-Object Node

    $secondNode.HostName = "10.0.1.4"
    $secondNode.HostPort = "3261"
    $secondNode.Login = "root"
    $secondNode.Password = "starwind"
    $secondNode.ImagePath = "My computer\C"
    $secondNode.ImageName = $imagename
    $secondNode.Size = $devicesize
    $secondNode.CreateImage = $true
    $secondNode.TargetAlias = $targetname
    $secondNode.AutoSynch = $true
    $secondNode.SyncInterface = "#p1=10.0.2.4:3260"
    $secondNode.HBInterface = "#p1=10.0.1.5:3260"
    $secondNode.ALUAOptimized = $true
        
    $device = Add-HADevice -server $server -firstNode $firstNode -secondNode $secondNode -initMethod "NotSynchronize"
    
}
catch
{
    Write-Host "Exception $($_.Exception.Message)" -foreground red 
}

$server.Disconnect()


### Connect iSCSI 

New-IscsiTargetPortal `
-TargetPortalAddress 127.0.0.1 | `
Get-IscsiTarget|?{$_.NodeAddress} | Connect-IscsiTarget `
-IsMultipathEnabled $true `
-IsPersistent $true 






