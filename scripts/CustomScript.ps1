
New-Item C:\CHECK\WARNING.txt -ItemType file -force -value "WORKING!!!"
if ( -Not (Test-Path "C:\CHECK"))
{
 New-Item -Path "C:\CHECK" -ItemType Directory | out-null
}