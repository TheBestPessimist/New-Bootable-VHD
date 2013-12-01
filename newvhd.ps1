# Create a dynamic VHD 
# some info  here: http://blogs.technet.com/b/heyscriptingguy/archive/2013/05/29/use-powershell-to-initialize-raw-disks-and-partition-and-format-volumes.aspx

# hardcode path and size
$vhdPath = "a.vhdx"
$vhdSize = 10
$isoPath = "E:\Virtual Machines\Windows 8.1 (multiple editions) (x64) - DVD (English)\en_windows_8_1_x64_dvd_2707217.iso"
$vhdLabel = "derp"
$bcdboot = "no"

# Get path and size (startup parameters)
# param( 
#     [string]$vhdPath = $(throw "Must specify full path for new VHD"), 
#     [string]$vhdSize = $(throw "Must specify size for new VHD (in GB)") 
#     [string]$isoPath = $(throw "Must specify full path for the windows .iso") 
#     [string]$vhdLabel = $(throw "Must specify the new VHD label")
#     [string]$bcdboot = $(throw "Must specify if you add this to bcdboot"),
# ) 
 
# Get rid of the old vhd and mounted iso
Dismount-VHD a.vhdx
rm a.vhdx

# Size in bytes 
$GB = [System.UInt64] $vhdSize*1024*1024*1024 
 
# Create a new VHD and mount it
New-Vhd $vhdPath -Dynamic -Size $GB | Mount-VHD

# Format the volume to get it ready for imageX
Get-Disk |
Where PartitionStyle -eq 'raw' |
Initialize-Disk -PartitionStyle GPT -PassThru |
New-Partition -AssignDriveLetter  -UseMaximumSize |
Format-Volume -FileSystem NTFS -Force -NewFileSystemLabel $vhdLabel -Confirm:$false

# Get the drive letter of the newly created vhd
$vhdLetter = (Get-Volume -FileSystemLabel $vhdLabel).DriveLetter


# Mount the Windows image to get install.wim, and get its path
Mount-DiskImage $isoPath
$devPath = (Get-DiskImage $isoPath).DevicePath

# Call imageX to do it's job
# imagex /apply "$devPath\sources\install.wim" 1 $vhdLetter":"

# cleaup
Dismount-DiskImage $isoPath

# check if this is to be added in the BCD store
if ($bcdboot.toLower() -in ("yes", "y")) {
    echo "you said $bcdboot"
}



# minecraft 1 6 4

# 113, 126
# 11)   A* for the vacuum cleaner problem with 3 cells. ()