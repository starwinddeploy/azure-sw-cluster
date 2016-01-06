# StarWind 2 VMs Cluster
[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://azuredeploy.net/)
This template deploys a 2-node StarWind cluster. Each node has 2 network cards:

*The first one is on a "public" subnet.
*The second one is on a "private" subnet.
The public subnet is used by RDP and communications between nodes, and for iSCSI as well. Each node in this subnet is assigned public IP address.

The private network is intended for StarWind synchronization only.
Use the DeviceSize parameter to specify the Size of HA Device in the cluster. Thoroughly calculate required amount of data. You’ll be billed for the full allocated disk size of StrWind device even if not all storage space used. So its better idea to extend storage space later if needed. 

The template also configures:
A storage account where all the virtual hard disks are stored.
A virtual network where the private and public subnet reside.
The template invokes a custom powershell scripts on each node that configures all 


