### Parametr
Param(
  [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)] 
  $devicesize = 1024
  )

### log
$ErrorActionPreference="SilentlyContinue"
Stop-Transcript | out-null
$ErrorActionPreference = "Continue"
Start-Transcript -path C:\log.txt -append

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

###   Prepare Data Disk
Get-Disk |
Where partitionstyle -eq 'raw' |
Initialize-Disk -PartitionStyle GPT -PassThru |
New-Partition -DriveLetter S -UseMaximumSize |
Format-Volume -FileSystem NTFS -NewFileSystemLabel "Starwind" -Confirm:$false 

write-host "Removing attribute Read-Only"
Get-Disk -Number 2 | Set-Disk -IsReadonly $False


 

####   Create Starwind HA Device

Import-Module StarWindX

$imagename = "imageh"
$targetname = "starwind"


    $starwindx = new-object -ComObject StarWindX.StarWindX
    $starwindx.LogEnableEx( "trace.log", "C:\", $false, 3)

    $server = New-SWServer -host 10.0.1.5 -port 3261 -user root -password starwind

    $server.Connect()

    $firstNode = new-Object Node

    $firstNode.ImagePath = "My computer\S"
    $firstNode.ImageName = $imagename
    $firstNode.Size = $devicesize
    $firstNode.CreateImage = $true
    $firstNode.TargetAlias = $targetname
    $firstNode.AutoSynch = $true
    $firstNode.SyncInterface = "#p2=10.0.2.4:3260"
    $firstNode.HBInterface = "#p2=10.0.1.4:3260"
    $firstNode.CacheSize = 1024
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
    $secondNode.ImagePath = "My computer\S"
    $secondNode.ImageName = $imagename
    $secondNode.Size = $devicesize
    $secondNode.CreateImage = $true
    $secondNode.TargetAlias = $targetname
    $secondNode.AutoSynch = $true
    $secondNode.SyncInterface = "#p1=10.0.2.5:3260"
    $secondNode.HBInterface = "#p1=10.0.1.5:3260"
    $secondNode.ALUAOptimized = $true
        
    $device = Add-HADevice -server $server -firstNode $firstNode -secondNode $secondNode -initMethod "NotSynchronize"
    


$server.Disconnect()

Stop-Transcript





