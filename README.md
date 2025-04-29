# ovz_to_proxmox
Migrate Openvz Virtuozzo 7 CTs to Proxmox VE 8.x LXC

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

## Compiling and installing sources on an OpenVZ - Virtuozzo 7 server

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
