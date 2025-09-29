# ovz virtuozzo container (ct) to proxmox lxc

Migrate Openvz Virtuozzo 7 CTs to Proxmox VE 8.x ( and later ) LXC

You need Perl :)

Everything is backuped and copied. Nothing is destroy. You have to do it at the end. It take more space disk, but you can test it in safe condition.

## Packages

Need gcc

```
yum -y install gcc
```

```
perl-Sys-Syslog-0.33-3.vl7.x86_64.rpm
from
http://repo.virtuozzo.com/vzlinux/7/x86_64/os/Packages/p/perl-Sys-Syslog-0.33-3.vl7.x86_64.rpm
md5sum packages/perl-Sys-Syslog-0.33-3.vl7.x86_64.rpm
28cb1d30c387d531c0e328cf06f52fa7  packages/perl-Sys-Syslog-0.33-3.vl7.x86_64.rpm
```

```
perl-LockFile-Simple-0.208-17.vl7.noarch.rpm
from
http://repo.virtuozzo.com/vzlinux/7/x86_64/os/Packages/p/perl-LockFile-Simple-0.208-17.vl7.noarch.rpm
md5sum packages/perl-LockFile-Simple-0.208-17.vl7.noarch.rpm 
e8f7c6a73c3c185b1608815cc1d71b48  packages/perl-LockFile-Simple-0.208-17.vl7.noarch.rpm
```

```
vzdump-1.2-4.noarch.rpm
from
https://download.openvz.org/contrib/utils/vzdump/vzdump-1.2-4.noarch.rpm
md5sum packages/vzdump-1.2-4.noarch.rpm
feeaa1c4fcbc0a3d1c02b4aa713aef81  packages/vzdump-1.2-4.noarch.rpm
```


## Sources

```
cstream-3.2.1-8.fc39.src.rpm
from
https://download.fedoraproject.org/pub/fedora/linux/releases/39/Everything/source/tree/Packages/c/cstream-3.2.1-8.fc39.src.rpm
md5sum sources/cstream-3.2.1-8.fc39.src.rpm 
e8e85d8bf46a0d9045bec61cf527e2eb  sources/cstream-3.2.1-8.fc39.src.rpm
```

## On OpenVZ Virtuozzo hypervisor - Compiling and installing sources on an OpenVZ - Virtuozzo 7 server

Manually

```
yum -y install gcc
wget https://github.com/aguerson/ovz_to_proxmox/raw/refs/heads/main/sources/cstream-3.2.1-8.fc39.src.rpm
rpm -ivh ./cstream-3.2.1-8.fc39.src.rpm
cd ~/rpmbuild/SPECS/
rpmbuild -ba ~/rpmbuild/SPECS/cstream.spec
cd ~/rpmbuild/RPMS/x86_64
yum -y install ./cstream-3.2.1-8.vl7.x86_64.rpm
cd
wget https://github.com/aguerson/ovz_to_proxmox/raw/refs/heads/main/packages/perl-Sys-Syslog-0.33-3.vl7.x86_64.rpm
yum -y install ./perl-Sys-Syslog-0.33-3.vl7.x86_64.rpm
wget https://github.com/aguerson/ovz_to_proxmox/raw/refs/heads/main/packages/perl-LockFile-Simple-0.208-17.vl7.noarch.rpm
yum -y install ./perl-LockFile-Simple-0.208-17.vl7.noarch.rpm
wget https://github.com/aguerson/ovz_to_proxmox/raw/refs/heads/main/packages/vzdump-1.2-4.noarch.rpm
yum -y install ./vzdump-1.2-4.noarch.rpm
```

With script

```

chmod +x .\install_vzdump.sh
.\install_vzdump.sh
```

## On Proxmox PVE - Download template

```
cat /etc/pve/storage.cfg
```

Look for content "vztmpl"

In some cases

```
/var/lib/vz/template/cache/
```

Choose a template compat with your Proxmox version

```
wget http://download.proxmox.com/images/system/debian-12-standard_12.12-1_amd64.tar.zst
```

```
/!\

The LXC template need to be supported by the Proxmox PVE version

Example: Debian 13 is not supported by Proxmox 8.x. But Debian 12 is OK.

/!\
```

## On Proxmox PVE - Create a empty LXC from template with specific id

```
cat /etc/pve/storage.cfg
```

Check which storage you can use. In my case, "zfs1"

Choose an ID. I choose "655"

```
pct create 655 /var/lib/vz/template/cache/debian-12-standard_12.12-1_amd64.tar.zst --hostname testlxc --memory 1024 --storage zfs1 --rootfs zfs1:8 --unprivileged 1 --ignore-unpack-errors
```

## On OpenVZ Virtuozzo hypervisor - Create a backup with compiled vzdump

### Verify you have enough space disk on /vz

```
df -h
```

You need the same free space as the size of your container.

### Stop your container

```
prlctl stop ct-name 
```

### Transform the disk image - Ploop to simfs ( the script is on this repo, under "scripts" directory )

Choose an ID. In my case "90002".

```
./ovz_ploop_to_simfs.pl on ct-name 90002
```

Wait.... It could take many time. It depends of the size of your container...

### Create a LXC backup archive of your CT

```
./ovz_ct_to_proxmox_lxc.pl id 90002
```

wait....

### Copy your backup archive to your Proxmox PVE

```
scp /vz/private/dump/vzdump-openvz-90002-2025_09_23-17_53_52.tar root@your_pve_fqdn_name:/var/lib/vz/dump/
```

### Rename your backup archive

You need to specify the ID of the new empty LXC template
and
you need to replace the word "openvz" by "lxc" in the backup archive name.

```
cd /var/lib/vz/dump/
mv vzdump-openvz-90002-2025_09_23-17_53_52.tar vzdump-lxc-655-2025_09_23-17_53_52.tar
```

### Import your backup and destroy the new empty template


You need to speficy the storage destination. In my case, always "zfs1".

```
pct restore 655 /var/lib/vz/dump/vzdump-lxc-655-2025_09_23-17_53_52.tar --storage zfs1 --force 1 --ignore-unpack-errors 1
```

#### Known errors

##### RAM size problem or SWAP size problem

```
vm 655 - unable to parse value of 'memory' - type check ('integer') failed - got '920.07421875'
vm 655 - unable to parse value of 'swap' - type check ('integer') failed - got '920.07421875'
400 Result verification failed
swap: type check ('integer') failed - got '920.07421875'
memory: type check ('integer') failed - got '920.07421875'
pct config <vmid> [OPTIONS]
```

To resolv :

```
To save the RAM problem :
```

```
pct stop 655
pct set 655 --memory 512
```


To save the SWAP problem :

```
pct stop 655
pct set 655 --swap 512
```

### Set the network interface

Identify your bridge interface and your vlan.
Set the IP and the gateway. 
Enable or not the firewall.


```
pct set 655 --net0 name=eth0,bridge=vmbr0,tag=xx,firewall=0,ip=x.x.x.x/24,gw=x.x.x.x
```

### Start the LXC

At this point you should be able to start your LXC.

```
pct start 655
```
