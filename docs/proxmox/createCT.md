wget https://cloud.debian.org/images/cloud/buster/20240703-1797/debian-10-genericcloud-amd64-20240703-1797.qcow2
sudo qm create 9500 --name Debian10CloudInit --net0 virtio,bridge=vmbr0
sudo qm importdisk 9500 debian-10-genericcloud-amd64-20240703-1797.qcow2 local-zfs
sudo qm set 9500 --scsihw virtio-scsi-pci --scsi0 local-zfs:vm-9500-disk-0
sudo qm set 9500 --ide2 local-zfs:cloudinit
sudo qm set 9500 --boot c --bootdisk scsi0
sudo qm set 9500 --serial0 socket --vga serial0
sudo qm set 9500 --agent enabled=1
sudo qm template 9500
