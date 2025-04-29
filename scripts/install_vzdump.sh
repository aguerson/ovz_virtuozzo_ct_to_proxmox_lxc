#!/usr/bin/sh
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
exit 0
