Import-Module StarWindX

$imagename = "imageh3"
$targetname = "starwind3"
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
        
    $device = Add-HADevice -server $server -firstNode $firstNode -secondNode $secondNode -initMethod "Clear"
    
    $syncState = $device.GetPropertyValue("ha_synch_status")

    while ($syncState -ne "1")
    {
        #
        # Refresh device info
        #
        $device.Refresh()

        $syncState = $device.GetPropertyValue("ha_synch_status")
        $syncPercent = $device.GetPropertyValue("ha_synch_percent")

        Start-Sleep -m 2000

        Write-Host "Synchronizing: $($syncPercent)%" -foreground yellow
    }
}
catch
{
    Write-Host "Exception $($_.Exception.Message)" -foreground red 
}

$server.Disconnect()