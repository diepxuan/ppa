Create Debian10CloudInit VM and convert into a template
---

- Create a new VM with ID 900 using VirtIO networking drivers.
- Import the qcow Debian image as a disk to the new VM. The disk will be called local-lvm:vm-9500-disk-0.
- Attach the imported disk as a VirtIO SCSI device to the VM.
- Attach a drive for the Cloud-Init config to the VM.
- Set the VM to boot from the imported disk image.
- Add a serial console to the VM, which is needed by OpenStack/ProxMox.
- Enable the qemu-guest-agent for the VM – this is an optional setting, but I do recommend it because it will be useful if you are going to be using this for something like Terraform - later on to automate the creation of VMs.
- Convert the VM into a template.

```
wget https://cloud.debian.org/images/cloud/buster/20240703-1797/debian-10-genericcloud-amd64-20240703-1797.qcow2
sudo qm create 9500 --name Debian10CloudInit --net0 virtio,bridge=vmbr0
sudo qm importdisk 9500 debian-10-genericcloud-amd64-20240703-1797.qcow2 local-zfs
sudo qm set 9500 --scsihw virtio-scsi-pci --scsi0 local-zfs:vm-9500-disk-0
sudo qm set 9500 --ide2 local-zfs:cloudinit
sudo qm set 9500 --boot c --bootdisk scsi0
sudo qm set 9500 --serial0 socket --vga serial0
sudo qm set 9500 --agent enabled=1
sudo qm template 9500
```
