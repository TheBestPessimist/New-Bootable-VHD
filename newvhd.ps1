# Create a dynamic VHD 
# Some info  here: http://blogs.technet.com/b/heyscriptingguy/archive/2013/05/29/use-powershell-to-initialize-raw-disks-and-partition-and-format-volumes.aspx

# This script can only be run from admin powershell must.
# Also, the execution policy must not be "restricted" 
# (the default on windows), therefore the following command should be used
# in a admin powershell window: "Set-ExecutionPolicy Unrestricted"

# bcdboot: type bcdboot $new_vhd_letter/windows [/addlast]

# hardcode path and size
$vhdPath = "a.vhdx"
$vhdSize = 30
$isoPath = "E:\iso\Windows 8.1 (multiple editions) (x86) - DVD (English)\en_windows_8_1_x86_dvd_2707392.iso"
$vhdLabel = "Windows 8.1"
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
imagex /apply "$devPath\sources\install.wim" 1 $vhdLetter":"

# cleaup
Dismount-DiskImage $isoPath

# Check if this is to be added in the BCD store
# (it appears in the boot menu)
if ($bcdboot.toLower() -in ("yes", "y")) {
    echo "you said $bcdboot"
}