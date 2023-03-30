#!/bin/bash

# Set default values in gb
memory=2
drive_space=20
cores=2

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
  echo
}

# Parse the command line arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
    -o) iso_directory="$2"; shift ;;
    -m) memory="$2"; shift ;;
    -d) drive_space="$2"; shift ;;
    -c) cores="$2"; shift ;;
    -h|--help) help; exit 0 ;;
    *) echo "Unknown parameter passed: $1" >&2
       exit 1 ;;
  esac
  shift
done

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
        iso_directory="http://mirror.rackspace.com/archlinux/iso/latest/archlinux-2022.02.01-x86_64.iso"
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
  --os-variant generic \
  --cdrom $iso_directory \
  --graphics vnc \
  --boot cdrom \
  --console pty,target_type=serial )
