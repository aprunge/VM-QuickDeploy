
# VM-QuickDeploy
VM-QuickDeploy is a lightweight and fast virtual machine deployment script for QEMU/KVM Virtualization. In fact, you <b>don't even *NEED* to have the ISOs locally!</b>

The <b>main</b> use cases of this script are:

 1. Mass VM deployment
 2. Ease of VM creation in a non-enterprise environment
 3. Scalability and customization
 
 VM-QuickDeploy is made with the <b>user</b> as the focus. Whether you operate at an enterprise level, or if you're setting up one or two virtual machines to learn more about virtualization, this is how it should be done.
 # Usage
 VM-QuickDeploy is the easiest and fastest way to deploy a VM from your command line. All you need to do is run the following: ``sudo ./vm_quickdp.sh [OPTIONS]``. After that you'll be off to the races under your new hypervisor!
# Requirements
The use of VM-QuickDeploy <b>REQUIRES</b> the installation of QEMU/KVM and the Virtual Machine Manager (VMM). The installation steps for those are below:

 1. Installing QEMU/KVM
	 - To install QEMU/KVM, refactor the following command for your distro: ``virt-manager qemu vde2 ebtables dnsmasq bridge-utils openbsd-netcat``
2.  Activating and Launching QEMU/KVM:
	- Running the following command <b>enables</b> the libvirt daemon: ``sudo systemctl enable libvirtd.service``
	- This command <b>starts</b> the libvirt daemon: ``sudo systemctl start libvirtd.service``
3. Editing libvirtd.conf <b>\*READ CAREFULLY\*</b>
	- Using your favorite text editor, open /etc/libvirt/libvirtd.conf
	- Jump to lines 80-90: ``unix_sock_group = "libvirt"``
	- Jump to lines 100-110: ``unix_sock_rw_perms = "0770"``
	- Then run the following: ``sudo usermod -a -G libvirt $(whoami) && newgrp libvirt``
4. Run the following command to <b>restart</b> the libvirt daemon: ``sudo systemctl restart libvirtd.service``
# Dependencies
VM-QuickDeploy has minimal dependencies (aside from virt-manager). The required packages are:

 1. virt-install
 2. virt-viewer
 3. vnc
