#!/usr/bin/perl -w
#----------------------------------------------------------------------
# @(#) SCRIPT : ovz_ct_to_proxmox_lxc.pl
#----------------------------------------------------------------------
# @(#) Application              : OpenVZ - Vituozzo - Proxmox
# @(#) Fonction                 : ct_to_lxc
# @(#) Author                   : Aurelien GUERSON
# @(#) Released date            : 29th September 2025
# @(#) Version                  : 1.0
#----------------------------------------------------------------------
# @(#) 
# @(#) Usage: ovz_ct_to_proxmox_lxc.pl
# @(#) 
# @(#)
#----------------------------------------------------------------------
# @(#) Version 1.0 : Version initiale
# @(#)
#----------------------------------------------------------------------
# @(#)

#-----------------------------
# Modules
#-----------------------------

use strict;

#-----------------------------
# Variables
#-----------------------------

$|=1; # Pour la non bufferisation

# global
my $action;

# OVZ
my $ctid;

my $dumpprivatepath = '/vz/private/dump';

my $vzdumpbin = '/usr/sbin/vzdump';

my $defaultBackupPath = '/var/lib/vz/dump/';

my $defaultPVEStorageConfigurationFile = '/etc/pve/storage.cfg';

my $ctconfpath = '/etc/vz/conf/';

# Log
my $loggerInformations;

#-----------------------------
# HASHs
#-----------------------------


#-----------------------------
# Fonctions
#-----------------------------

# Commandes pour lancer le script
sub usage {
	die join("", @_, <<'EOM');

ovz_ct_to_proxmox_lxc.pl (Version 1.0)

Usage: ovz_ct_to_proxmox_lxc.pl [id] [ctid]

ctid:  a value with 5 digits

Example:
	ovz_ct_to_proxmox_lxc.pl id 90001

EOM
}

# Log
sub logger {

        if (defined($loggerInformations)){
                print "$loggerInformations";
        }

        undef $loggerInformations;
}

#-----------------------------
# Main
#-----------------------------


usage() unless $ARGV[0] && $ARGV[1];


if (defined($ARGV[0])){
	$action = "$ARGV[0]";
}

if (defined($ARGV[1])){
        $ctid = "$ARGV[1]";
}

if ("$action" !~ m/^(id){1}$/g){
	usage();
}

if ("$ctid" !~ m/^[0-9]+$/g){
        usage();
}

$loggerInformations = "\n"; &logger;
$loggerInformations = "\n"; &logger;
$loggerInformations = "+++ Script $0 start +++\n"; &logger;
$loggerInformations = "\n"; &logger;

$SIG{__DIE__} = sub {
	$loggerInformations = "\n"; &logger;
	$loggerInformations = " Error\: @_"; &logger;
	$loggerInformations = "\n"; &logger;
	$loggerInformations = "\n"; &logger;
	$loggerInformations = "--- Script $0 end ---\n"; &logger;
	$loggerInformations = "\n"; &logger;
	$loggerInformations = "\n"; &logger;
	exit 1;
};
$SIG{__WARN__} = sub {
	$loggerInformations = "\n"; &logger;
	$loggerInformations = " Warning\: @_"; &logger;
	$loggerInformations = "\n"; &logger;
};

### MAIN CORE ###


$loggerInformations = "Verifying actual CT \"$ctid\" is stopped\n"; &logger;
$loggerInformations = "Running CMD: \n" . 'vzlist -H -o status ' . $ctid . "\n"; &logger;
my $ctstop = `vzlist -H -o status $ctid`;
chomp($ctstop);
$ctstop=lc($ctstop);
if ("$ctstop" ne 'stopped'){
	die "CT \"$ctid\" is not stopped. You have to do it manually\n"; &logger;
}
else {
	$loggerInformations = "CT \"$ctid\" is stopped\n"; &logger;
}

my $ctconffile = $ctconfpath . $ctid . '.conf';

$loggerInformations = "Parse and correct CT conf \"$ctid\".conf format\n"; &logger;
$loggerInformations = "Running CMD: \n" . "sed -i \'s\|\=\"\|\=\|g\' " . $ctconffile . "\n"; &logger;
my $sedcmd1 = system("sed -i 's|=\"|=|g' $ctconffile");
chomp($sedcmd1);
if ("$sedcmd1" eq '0'){
        $loggerInformations = "sed command 1 passed successfully\n"; &logger;
}
else {
        die "Error \"$sedcmd1\" sed command 1 failed\n"; &logger;
}
$loggerInformations = "Running CMD: \n" . "sed -i 's/[\^\"]\$/\&\"/' " . $ctconffile . "\n"; &logger;
my $sedcmd2 = system("sed -i 's/[\^\"]\$/\&\"/' $ctconffile");
chomp($sedcmd2);
if ("$sedcmd2" eq '0'){
        $loggerInformations = "sed command 2 passed successfully\n"; &logger;
}
else {
        die "Error \"$sedcmd2\" sed command 2 failed\n"; &logger;
}
$loggerInformations = "Running CMD: \n" . "sed -i 's/\^[A-Z_-]\*\=/\&\"/g' " . $ctconffile . "\n"; &logger;
my $sedcmd3 = system("sed -i 's/\^[A-Z_-]\*\=/\&\"/g' $ctconffile");
chomp($sedcmd3);
if ("$sedcmd3" eq '0'){
        $loggerInformations = "sed command 3 passed successfully\n"; &logger;
}
else {
        die "Error \"$sedcmd3\" sed command 3 failed\n"; &logger;
}


$loggerInformations = "Verifying vzdump is present\n"; &logger;
if ( -f "$vzdumpbin"){
	$loggerInformations = "vzdump is present\n"; &logger;
}
else {
	die "Error vzdump is not present\n"; &logger;
}

#exit 0;

$loggerInformations = "Verifing new dump dir \"$dumpprivatepath\" is not present\n"; &logger;
if ( -d "$dumpprivatepath" ){
        $loggerInformations = "New dump dir \"$dumpprivatepath\" is already present\n"; &logger;
}
else {
        $loggerInformations = "New dump dir \"$dumpprivatepath\" is not present\n"; &logger;
        $loggerInformations = "Creating new dump dir \"$dumpprivatepath\"\n"; &logger;
        $loggerInformations = "Running CMD: \n" . 'mkdir -p ' . $dumpprivatepath . "\n"; &logger;
        my $createnewdumpdir = system("mkdir -p $dumpprivatepath");
        chomp($createnewdumpdir);
        if ("$createnewdumpdir" eq '0'){
                $loggerInformations = "\"$dumpprivatepath\" has been created \n"; &logger;
        }
        else {
                die "Error \"$createnewdumpdir\" in creating \"$dumpprivatepath\"\n"; &logger;
        }

}

my $dumpprivatepathfull = $dumpprivatepath . '/';
$loggerInformations = "Creating a dump \(a \.tar archive\) of the CT to transfer to Proxmox PVE\n"; &logger;
$loggerInformations = "Running CMD: \n" . 'vzdump ' . $ctid . ' --dumpdir ' . $dumpprivatepathfull . "\n"; &logger;
my $vzdumpct = system("vzdump $ctid --dumpdir $dumpprivatepathfull");
chomp($vzdumpct);
if ("$vzdumpct" eq '0'){
	$loggerInformations = "Tar archive of CT \"$ctid\" has been created\n"; &logger;
}
else {
	die "Error \"$vzdumpct\" in creating tar archive of CT \"$ctid\"\n"; &logger;
}

#find /vz/private/dump/ -type f -mmin -5|grep tar
$loggerInformations = "Identifying the last created dump \(a \.tar archive\) of the CT to transfer to Proxmox PVE\n"; &logger;
$loggerInformations = "Running CMD: \n" . 'find ' . $dumpprivatepath  . ' -type f -mmin -5|grep tar' . "\n"; &logger;
my $lastdump = `find $dumpprivatepath -type f -mmin -5|grep tar`;
chomp($lastdump);
if (-f "$lastdump"){
	$loggerInformations = "\"$lastdump\" is the last created dump of CT \"$ctid\"\n"; &logger;
}
else {
	die "Unable to find the last created dump of CT \"$ctid\"\n"; &logger;
}

$loggerInformations = "Now you have to copy \"$lastdump\" to your Proxmox PVE in the default backup path \"$defaultBackupPath\"\n"; &logger;
$loggerInformations = "Check in the PVE storage configuration file \"$defaultPVEStorageConfigurationFile\" to identify the content \"backup\" and find the right root path\n"; &logger;

$loggerInformations = "Example of command \:\n"; &logger;
$loggerInformations = "scp $lastdump your-privileged-user-on-pve\@your-pve-name.domain.xx\:$defaultBackupPath\n"; &logger;




$loggerInformations = "\n"; &logger;
$loggerInformations = "--- Script $0 end ---\n"; &logger;
$loggerInformations = "\n"; &logger;
$loggerInformations = "\n"; &logger;



exit 0;

