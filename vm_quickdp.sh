#!/bin/bash
#Set up signam trap to clear terminal if the script is killed
trap "clear; exit 1" INT

# Set default values in gb
memory=2
drive_space=20
cores=2

function loading() {
  echo -n "Loading"
  while true; do
    # Print a period and wait for 0.2 seconds
    echo -n "."
    sleep 0.2

    # Calculate the length of the loading message (including dots)
    message_length=$(echo -n "Loading$dots" | wc -c)

    # If the message is too long, wrap the dots to the next line
    if [[ $message_length -gt 50 ]]; then
      dots="\n"
    else
      dots="${dots}."
    fi

    # Update the loading message with the current dots and move the cursor back to the start
    echo -ne "\rLoading$dots"
  done
}

# Define the help function
function help() {
  echo
  echo "Usage: script.sh [OPTIONS]"
  echo "Options:"
  echo "  -o [ISO_DIRECTORY]    Directory to local ISO (only use if the ISO is a valid OS, otherwise DO NOT)"
  echo "  -m [MEMORY]           Amount of memory to use (default: 2GB)"
  echo "  -d [DRIVE SPACE]      Amount of drive space to use (default: 10GB)"
  echo "  -c [CORES]            Number of cores to use (default: 2)"
  echo "  -h, --help            Display this help message"
  echo -e "  -C, --connect         Connect to the virtual machine through VNC (\033[1mNEEDS to have VNC installed\033[0m)"
  echo
}

function findvms() {
  # find all qcow2 files and store their paths in an array
  qcow2_files=($(find / -name "*.qcow2" -type f 2>/dev/null))

  # print the array
  echo -e "\033[1mList of qcow2 files:\033[0m"
  for file in "${qcow2_files[@]}"; do
    echo -e "\033[1m$file\033[0m"
  done

}

function connect() {
  echo "Connecting to $vm_name" 
}

# Check if script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root. Aborting." 
   exit 1
fi

clear

# Parse the command line arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
    -o) iso_directory="$2"; shift ;;
    -m) memory="$2"; shift ;;
    -d) drive_space="$2"; shift ;;
    -c) cores="$2"; shift ;;
    -C|--connect) vm_name="$2" connect; exit 0 ;;
    -h|--help) help; exit 0 ;;
    *) echo "Unknown parameter passed: $1" >&2
       exit 1 ;;
  esac
  shift
done

loading & 

output=$(findvms)

clear

kill %1


echo "$output"

# Check if the ISO directory parameter is set
if [[ -z "$iso_directory" ]]; then
  online_inst=true
  echo
  echo "1. Ubuntu"
  echo "2. Linux Mint"
  echo "3. Debian"
  echo "4. Fedora"
  echo "5. CentOS"
  echo "6. Arch"
  echo "7. openSUSE"
  echo "8. Kali"
  echo "9. Manjaro"
  echo
  echo "Which OS would you like to use [1 - 9]: "
  
  read num

case $num in
    1)
        echo "You selected Ubuntu."
        iso_directory="https://releases.ubuntu.com/jammy/ubuntu-22.04.2-desktop-amd64.iso"
        ;;
    2)
        echo "You selected Linux Mint."
        iso_directory="https://mirror.clarkson.edu/linuxmint-images/stable/21.1/linuxmint-21.1-xfce-64bit.iso"
        ;;
    3)
        echo "You selected Debian."
        iso_directory="https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-11.6.0-amd64-netinst.iso"
        osvar="debian11"
        ;;
    4)
        echo "You selected Fedora."
        iso_directory="https://archives.fedoraproject.org/pub/archive/fedora/linux/releases/36/Workstation/x86_64/iso/Fedora-Workstation-Live-x86_64-36-1.5.iso"
        ;;
    5)
        echo "You selected CentOS."
        iso_directory="https://ftp.riken.jp/Linux/centos/7/isos/x86_64/CentOS-7-x86_64-DVD-2009.iso"
        ;;
    6)
        echo "You selected Arch."
        iso_directory="https://archive.archlinux.org/iso/2023.03.01/archlinux-2023.03.01-x86_64.iso"
        ;;
    7)
        echo "You selected openSUSE."
        iso_directory="https://download.opensuse.org/distribution/leap/15.0/iso/openSUSE-Leap-15.0-DVD-x86_64.iso"
        ;;
    8)
        echo "You selected Kali."
        iso_directory="https://old.kali.org/kali-images/kali-2023.1/kali-linux-2023.1-live-amd64.iso"
        ;;
    9)
        echo "You selected Manjaro."
        iso_directory="https://download.manjaro.org/xfce/22.0.5/manjaro-xfce-22.0.5-230316-linux61.iso"
        ;;
    2018)
        echo "You selected TempleOS"
        iso_directory="https://templeos.org/Downloads/TempleOS.ISO"
        ;;
    *)
        echo "Invalid input. Please enter a number between 1 and 9."
        exit 1
        ;;
esac

  #echo "ISO directory parameter (-o) is required" >&2
  #exit 1
fi

# Check if the ISO directory is a valid file path and has .iso extension
if [[ ! -f "$iso_directory" || "${iso_directory##*.}" != "iso" ]] && [[ $online_inst != true ]]; then
  echo "Error: Not a valid ISO file path." >&2
  exit 1
fi

echo
echo "Are the following settings correct?"
echo

# Print the selected options
echo "Memory: $((memory * 1024)) MB"
echo "Drive Space: $((drive_space * 1024)) MB"
echo "Cores: $cores"
echo "ISO Directory: $iso_directory"
echo

# Prompt for yes or no input
read -r -p "Do you want to proceed? [y/N] " response
response=${response,,}    # tolower

# Check if the response is yes or no
if [[ "$response" =~ ^(yes|y)$ ]]; then
  echo "Starting the installation process..."
  # Your installation commands go here
else
  echo "Installation aborted."
  exit 0
fi

read -p "What is the name of your VM? " vm_name

$(virt-install \
  --name $vm_name \
  --ram $((memory * 1024)) \
  --disk path=/var/lib/libvirt/images/$vm_name.qcow2,size=20 \
  --vcpus $cores \
  --os-variant $osvar \
  --cdrom $iso_directory \
  --graphics vnc \
  --boot cdrom \
  --console pty,target_type=serial )

read -p "Do you want to change the boot order? (y/n) " input 

clear
exit 0
