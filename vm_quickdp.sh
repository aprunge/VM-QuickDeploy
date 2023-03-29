#!/bin/bash

# Set default values in gb
memory=2
drive_space=10
cores=2

# Define the help function
function help() {
  echo "Usage: script.sh -o [iso_directory] [OPTIONS]"
  echo "Options:"
  echo "  -m [MEMORY]           Amount of memory to use (default: 2GB)"
  echo "  -d [DRIVE SPACE]      Amount of drive space to use (default: 10GB)"
  echo "  -c [CORES]            Number of cores to use (default: 2)"
  echo "  -h, --help            Display this help message"
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
  echo "ISO directory parameter (-o) is required" >&2
  exit 1
fi

# Check if the ISO directory is a valid file path and has .iso extension
if [[ ! -f "$iso_directory" || "${iso_directory##*.}" != "iso" ]]; then
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
  --ram $memory \
  --disk path=/var/lib/libvirt/images/$vm_name.qcow2,size=20 \
  --vcpus $cores \
  --os-variant generic \
  --cdrom $iso_directory \
  --graphics vnc \
  --boot cdrom \
  --console pty,target_type=serial )
