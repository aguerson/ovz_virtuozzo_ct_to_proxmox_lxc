#!/usr/bin/perl -w
#----------------------------------------------------------------------
# @(#) SCRIPT : ovz_ploop_to_simfs.pl
#----------------------------------------------------------------------
# @(#) Application              : OpenVZ - Vituozzo
# @(#) Fonction                 : ploop_to_simfs
# @(#) Author                   : Aurelien GUERSON
# @(#) Released date            : 29th September 2025
# @(#) Version                  : 1.0
#----------------------------------------------------------------------
# @(#) 
# @(#) Usage: ovz_ploop_to_simfs.pl
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
my $ctname;
my $newctid;

my $rootpath = '/vz/root/';
my $privatepath = '/vz/private/';
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

ovz_ploop_to_simfs.pl (Version 1.0)

Usage: ovz_ploop_to_simfs.pl [on] [ctname] [newctid]

newctid:  a value with 5 digits

Example:
	ovz_ploop_to_simfs.pl on cttest 90001

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


usage() unless $ARGV[0] && $ARGV[1] && $ARGV[2];


if (defined($ARGV[0])){
	$action = "$ARGV[0]";
}

if (defined($ARGV[1])){
        $ctname = "$ARGV[1]";
	if ("$ctname" !~ m/^([a-zA-Z0-9_-]+|\.)+$/g){
		usage();		
	}

	# check ctname exists
	my $checkctname = system("vzlist -H -h host $ctname");
	chomp($checkctname);

	if ("$checkctname" ne '0'){
		usage();
	}

}

if (defined($ARGV[2])){
        $newctid = "$ARGV[2]";
}

if ("$action" !~ m/^(on){1}$/g){
	usage();
}

if ("$newctid" !~ m/^[0-9]+$/g){
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

$loggerInformations = "Verifying actual CT \"$ctname\" is stopped\n"; &logger;
$loggerInformations = "Running CMD: \n" . 'vzlist -H -o status ' . $ctname . "\n"; &logger;
my $ctstop = `vzlist -H -o status $ctname`;
chomp($ctstop);
$ctstop=lc($ctstop);
if ("$ctstop" ne 'stopped'){
	die "CT \"$ctname\" is not stopped. You have to do it manually\n"; &logger;
}
else {
	$loggerInformations = "CT \"$ctname\" is stopped\n"; &logger;
}

$loggerInformations = "Getting actual CTID of \"$ctname\"\n"; &logger;
$loggerInformations = "Running CMD: \n" . 'vzlist -H -o ctid ' . $ctname . "\n"; &logger;
my $ctid = `vzlist -H -o ctid $ctname`;
chomp($ctid);
if ("$ctid" !~ m/^([a-z0-9]+|\-)+$/g){
	if ("$ctid" =~ m/^[\s|\t]+([a-z0-9]+|\-)+$/g){
		$ctid = "$1";
		$loggerInformations = "Actual CTID of \"$ctname\" is \"$ctid\"\n"; &logger;
	}
	else {
		die "Actual CTID of \"$ctname\" is not good \(\"$ctid\"\)\n"; &logger; 
	}
}
else {
	$loggerInformations = "Actual CTID of \"$ctname\" is \"$ctid\"\n"; &logger;
}

my $newprivatepath = $privatepath . $newctid;
$loggerInformations = "Verifing new dir \"$newprivatepath\" is not present\n"; &logger;
if ( -d "$newprivatepath" ){
	die "New dir \"$newprivatepath\" is already present\n"; &logger;
}
else {
	$loggerInformations = "New dir \"$newprivatepath\" is not present\n"; &logger;
	$loggerInformations = "Creating new dir \"$newprivatepath\"\n"; &logger;
	$loggerInformations = "Running CMD: \n" . 'mkdir -p ' . $newprivatepath . "\n"; &logger;
	my $createnewdir = system("mkdir -p $newprivatepath");
	chomp($createnewdir);
	if ("$createnewdir" eq '0'){
		$loggerInformations = "\"$newprivatepath\" has been created \n"; &logger;
	}
	else {
		die "Error \"$createnewdir\" in creating \"$newprivatepath\"\n"; &logger;
	}
	
}

my $ctconffile = $ctconfpath . $ctid . '.conf';
my $ctconfbackupfile = $ctconfpath . $ctid . '.conf' . '.bck';
$loggerInformations = "Copying CT conf \"$ctconffile\" in a backup file \"$ctconfbackupfile\"\n"; &logger;
if ( -f "$ctconfbackupfile" ){
# Mode Debug:
#        die "Backup file \"$ctconfbackupfile\" is already present\n"; &logger;
}
else {
	$loggerInformations = "Running CMD: \n" . 'cp -f' . $ctconffile . ' ' . $ctconfbackupfile . "\n"; &logger;
	my $copyconffile = system("cp -f $ctconffile $ctconfbackupfile");
	chomp($copyconffile);
	if ("$copyconffile" eq '0'){
		$loggerInformations = "\"$ctconffile\" has been copied in file \"$ctconfbackupfile\"\n"; &logger;
	}
	else {
		die "Error \"$copyconffile\" in copying \"$ctconffile\" in \"$ctconfbackupfile\"\n"; &logger;
	}

}


my $newctconffile = $ctconfpath . $newctid . '.conf';
$loggerInformations = "Creating new CT conf file \"$newctconffile\"\n"; &logger;
if ( -f "$newctconffile" ){
# Mode Debug:
#        die "New CT conf file \"$newctconffile\" is already present\n"; &logger;
}
else {
        $loggerInformations = "Running CMD: \n" . 'cp -f' . $ctconffile . ' ' . $newctconffile . "\n"; &logger;
        my $createnewctconffile = system("cp -f $ctconffile $newctconffile");
	chomp($createnewctconffile);
	if ("$createnewctconffile" eq '0'){
		$loggerInformations = "\"$newctconffile\" has been created\n"; &logger;
        }
        else {
                die "Error \"$createnewctconffile\" in creating \"$newctconffile\"\n"; &logger;
        }
}

my $newrootpath = $rootpath . $newctid;
$loggerInformations = "Modifying new CT conf file \"$newctconffile\"\n"; &logger;
if ( -f "$newctconffile" ){

	# MOD
	$loggerInformations = "Running CMD: \n" . 'sed -i "s|^VE_LAYOUT=|#VE_LAYOUT=|g" ' . $newctconffile . "\n"; &logger;
	my $mod01onconffile = system("sed -i \"s|^VE_LAYOUT=|#VE_LAYOUT=|g\" $newctconffile");
	chomp($mod01onconffile);
	if ("$mod01onconffile" eq '0'){
                $loggerInformations = "CMD OK\n"; &logger;
        }
        else {
                die "Error \"$mod01onconffile\" in CMD\n"; &logger;
        }

	$loggerInformations = "Running CMD: \n" . 'sed -i "s|^VE_ROOT=|#VE_ROOT=|g" ' . $newctconffile . "\n"; &logger;   
	my $mod02onconffile = system("sed -i \"s|^VE_ROOT=|#VE_ROOT=|g\" $newctconffile");
	chomp($mod02onconffile);
	if ("$mod02onconffile" eq '0'){
                $loggerInformations = "CMD OK\n"; &logger;
        }
        else {
                die "Error \"$mod02onconffile\" in CMD\n"; &logger;
        }

	$loggerInformations = "Running CMD: \n" . 'sed -i "s|^VE_PRIVATE=|#VE_PRIVATE=|g" ' . $newctconffile . "\n"; &logger;
	my $mod03onconffile = system("sed -i \"s|^VE_PRIVATE=|#VE_PRIVATE=|g\" $newctconffile");
	chomp($mod03onconffile);
	if ("$mod03onconffile" eq '0'){
                $loggerInformations = "CMD OK\n"; &logger;
        }
        else {
                die "Error \"$mod03onconffile\" in CMD\n"; &logger;
        }

	$loggerInformations = "Running CMD: \n" . 'sed -i "s|^VEID=|#VEID=|g" ' . $newctconffile . "\n"; &logger;
	my $mod04onconffile = system("sed -i \"s|^VEID=|#VEID=|g\" $newctconffile");
	chomp($mod04onconffile);
	if ("$mod04onconffile" eq '0'){
                $loggerInformations = "CMD OK\n"; &logger;
        }
        else {
                die "Error \"$mod04onconffile\" in CMD\n"; &logger;
        }

	$loggerInformations = "Running CMD: \n" . 'sed -i "s|^UUID=|#UUID=|g" ' . $newctconffile . "\n"; &logger;
	my $mod05onconffile = system("sed -i \"s|^UUID=|#UUID=|g\" $newctconffile");
	chomp($mod05onconffile);
	if ("$mod05onconffile" eq '0'){
                $loggerInformations = "CMD OK\n"; &logger;
        }
        else {
                die "Error \"$mod05onconffile\" in CMD\n"; &logger;
        }

	$loggerInformations = "Running CMD: \n" . 'sed -i "s|^DISK=|#DISK=|g" ' . $newctconffile . "\n"; &logger;
	my $mod06onconffile = system("sed -i \"s|^DISK=|#DISK=|g\" $newctconffile");
	chomp($mod06onconffile);
	if ("$mod06onconffile" eq '0'){
                $loggerInformations = "CMD OK\n"; &logger;
        }
        else {
                die "Error \"$mod06onconffile\" in CMD\n"; &logger;
        }

	$loggerInformations = "Running CMD: \n" . 'sed -i "s|^VE_TYPE=|#VE_TYPE=|g" ' . $newctconffile . "\n"; &logger;
	my $mod07onconffile = system("sed -i \"s|^VE_TYPE=|#VE_TYPE=|g\" $newctconffile");
	chomp($mod07onconffile);
	if ("$mod07onconffile" eq '0'){
                $loggerInformations = "CMD OK\n"; &logger;
        }
        else {
                die "Error \"$mod07onconffile\" in CMD\n"; &logger;
        }

	$loggerInformations = "Running CMD: \n" . 'sed -i "s|^TECHNOLOGIES=|#TECHNOLOGIES=|g" ' . $newctconffile . "\n"; &logger;
	my $mod08onconffile = system("sed -i \"s|^TECHNOLOGIES=|#TECHNOLOGIES=|g\" $newctconffile");
	chomp($mod08onconffile);
	if ("$mod08onconffile" eq '0'){
                $loggerInformations = "CMD OK\n"; &logger;
        }
        else {
                die "Error \"$mod08onconffile\" in CMD\n"; &logger;
        }
	
	# ADD
	$loggerInformations = "Running CMD: \n" . 'echo "VE_LAYOUT=simfs" >> ' . $newctconffile . "\n"; &logger;
	my $addline01conffile = system("echo \"VE_LAYOUT=simfs\" \>\> $newctconffile");
	chomp($addline01conffile);
	if ("$addline01conffile" eq '0'){
        	$loggerInformations = "CMD OK\n"; &logger;
	}
	else {
        	die "Error \"$addline01conffile\" in CMD\n"; &logger;
	}

	$loggerInformations = "Running CMD: \n" . 'echo "VE_ROOT=' . $newrootpath . '" >> ' . $newctconffile . "\n"; &logger;
	my $addline02conffile = system("echo \"VE_ROOT=$newrootpath\" \>\> $newctconffile");
	chomp($addline02conffile);
	if ("$addline02conffile" eq '0'){
                $loggerInformations = "CMD OK\n"; &logger;
        }
        else {
                die "Error \"$addline02conffile\" in CMD\n"; &logger;
        }

	$loggerInformations = "Running CMD: \n" . 'echo "VE_PRIVATE=' . $newprivatepath . '" >> ' . $newctconffile . "\n"; &logger;
	my $addline03conffile = system("echo \"VE_PRIVATE=$newprivatepath\" \>\> $newctconffile");
	chomp($addline03conffile);
	if ("$addline03conffile" eq '0'){
                $loggerInformations = "CMD OK\n"; &logger;
        }
        else {
                die "Error \"$addline03conffile\" in CMD\n"; &logger;
        }

}
else {
	die "New CT conf file \"$newctconffile\" is not present\n"; &logger;
}

my $ctrootpath = $rootpath . $ctid;
my $ctprivatepath = $privatepath . $ctid;
my $ctprivatepathimage = $ctprivatepath . '/root.hdd';
$loggerInformations = "Mounting CT image \"$ctprivatepathimage\"\n"; &logger;
$loggerInformations = "Running CMD: \n" . 'vzctl mount ' . $ctid . "\n"; &logger;
my $mountctprivatedir = system("vzctl mount $ctid");
# Mode Debug:
#my $mountctprivatedir = 0;
chomp($mountctprivatedir);
if ("$mountctprivatedir" eq '0'){
	$loggerInformations = "CT image \"$ctprivatepathimage\" has been mounted\n"; &logger;
}
else {
	die "Error \"$mountctprivatedir\" in mounting CT image \"$ctprivatepathimage\"\n"; &logger;
}

$loggerInformations = "Mounting new CT private path \"$newprivatepath\" and root path \"$newrootpath\"\n"; &logger;
$loggerInformations = "Running CMD: \n" . 'vzctl mount ' . $newctid . "\n"; &logger;
my $mountnewctprivatedir = system("vzctl mount $newctid");
# Mode Debug:
#my $mountnewctprivatedir = 0;
chomp($mountnewctprivatedir);
if ("$mountnewctprivatedir" eq '0'){
	$loggerInformations = "New CT private path \"$newprivatepath\" and root path \"$newrootpath\" have been mounted\n"; &logger;
}
else {
	die "Error \"$mountnewctprivatedir\" in mounting new CT private path \"$newprivatepath\" and root path \"$newrootpath\"\n"; &logger;
}

my $ctrootpathdot = $ctrootpath . '/.';
my $newctprivatepathfull = $newprivatepath . '/';
$loggerInformations = "Synchronising CT data from \"$ctname\" with new CT \"$newctid\" data in private path \"$newprivatepath\" \n"; &logger;
$loggerInformations = "Running CMD: \n" . 'rsync -aHAX --progress --stats --numeric-ids --delete ' . $ctrootpathdot . ' ' . $newctprivatepathfull . ' ' . "\n"; &logger;
my $syncdata = system("rsync -aHAX --progress --stats --numeric-ids --delete $ctrootpathdot $newctprivatepathfull");
# Mode Debug:
#my $syncdata = 0;
chomp($syncdata);
if ("$syncdata" eq '0'){
	$loggerInformations = "Data have been successfully synchronised\n"; &logger;
}
else {
	die "Error \"$syncdata\" in synchronising data\n"; &logger;
}

$loggerInformations = "Umounting CT image \"$ctprivatepathimage\"\n"; &logger;
$loggerInformations = "Running CMD: \n" . 'vzctl umount ' . $ctid . "\n"; &logger;
my $umountctprivatedir = system("vzctl umount $ctid");
# Mode Debug:
#my $umountctprivatedir = 0;
chomp($umountctprivatedir);
if ("$umountctprivatedir" eq '0'){
        $loggerInformations = "CT image \"$ctprivatepathimage\" has been umounted\n"; &logger;
}
else {
        die "Error \"$umountctprivatedir\" in umounting CT image \"$ctprivatepathimage\"\n"; &logger;
}

$loggerInformations = "Umounting new CT private path \"$newprivatepath\" and root path \"$newrootpath\"\n"; &logger;
$loggerInformations = "Running CMD: \n" . 'vzctl umount ' . $newctid . "\n"; &logger;
my $umountnewctprivatedir = system("vzctl umount $newctid");
# Mode Debug:
#my $umountnewctprivatedir = 0;
chomp($umountnewctprivatedir);
if ("$umountnewctprivatedir" eq '0'){
        $loggerInformations = "New CT private path \"$newprivatepath\" and root path \"$newrootpath\" have been umounted\n"; &logger;
}
else {
        die "Error \"$umountnewctprivatedir\" in umounting new CT private path \"$newprivatepath\" and root path \"$newrootpath\"\n"; &logger;
}

my $oldctprivatepath = $ctprivatepath . '.old';
$loggerInformations = "Moving old CT private path \"$ctprivatepath\" to \"$oldctprivatepath\"\n"; &logger;
$loggerInformations = "Running CMD: \n" . 'mv -f ' . $ctprivatepath . ' ' . $oldctprivatepath . "\n"; &logger;
my $mvoldctprivatedir = system("mv -f $ctprivatepath $oldctprivatepath");
# Mode Debug:
#my $mvoldctprivatedir = 0;
chomp($mvoldctprivatedir);
if ("$mvoldctprivatedir" eq '0'){
        $loggerInformations = "Old CT private path \"$ctprivatepath\" has been moved to \"$oldctprivatepath\"\n"; &logger;
}
else {
        die "Error \"$mvoldctprivatedir\" in moving old CT private path \"$ctprivatepath\" to \"$oldctprivatepath\"\n"; &logger;
}

$loggerInformations = "Starting new CT to check if conversion to simfs is ok\n"; &logger;
$loggerInformations = "Running CMD: \n" . 'vzctl start ' . $newctid . "\n"; &logger;
my $startnewct = system("vzctl start $newctid");
# Mode Debug:
#my $startnewct = 0;
chomp($startnewct);
if ("$startnewct" eq '0'){
        $loggerInformations = "New CT \"$newctid\" has been started\n"; &logger;
}
else {
        die "Error \"$startnewct\" in starting \"$newctid\"\n"; &logger;
}

$loggerInformations = "Checking new CT status\n"; &logger;
$loggerInformations = "Running CMD: \n" . 'vzlist -H -o status ' . $newctid . "\n"; &logger;
my $newctstatus = `vzlist -H -o status $newctid`;
# Mode Debug:
#my $newctstatus = 'running';
chomp($newctstatus);
$newctstatus=lc($newctstatus);
if ("$newctstatus" eq 'running'){
        $loggerInformations = "New CT \"$newctid\" is running\n"; &logger;
}
else {
        die "Error in \"$newctid\" status \(\"$newctstatus\"\)\n"; &logger;
}

$loggerInformations = "Stopping new CT to dump new simfs data\n"; &logger;
$loggerInformations = "Running CMD: \n" . 'vzctl stop ' . $newctid . "\n"; &logger;
my $stopnewct = system("vzctl stop $newctid");
# Mode Debug:
#my $stopnewct = 0;
chomp($stopnewct);
if ("$stopnewct" eq '0'){
        $loggerInformations = "New CT \"$newctid\" has been stopped\n"; &logger;
}
else {
        die "Error \"$stopnewct\" in stopping \"$newctid\"\n"; &logger;
}

$loggerInformations = "Deleting old CT conf \"$ctconffile\"\n"; &logger;
$loggerInformations = "Running CMD: \n" . 'rm -f ' . $ctconffile  . "\n"; &logger;
#my $rmctconf = system("rm -f $ctconffile");
# Mode Debug:
my $rmctconf = 0;
chomp($rmctconf);
if ("$rmctconf" eq '0'){
        $loggerInformations = "CT conf \"$ctconffile\" has been deleted\n"; &logger;
}
else {
        die "Error \"$rmctconf\" in deleting CT conf \"$ctconffile\"\n"; &logger;
}

#
# /!\ DELETE OLD CT DATA /!\
# Be careful before uncomment !
#

#$loggerInformations = "Deleting old CT DATA \"$oldctprivatepath\"\n"; &logger;
#$loggerInformations = "Running CMD: \n" . 'rm -f ' . $oldctprivatepath  . "\n"; &logger;
#my $rmoldctdata = system("rm -f $oldctprivatepath");
#chomp($rmoldctdata);
#if ("$rmoldctdata" eq '0'){
#        $loggerInformations = "Old CT DATA \"$oldctprivatepath\" have been deleted\n"; &logger;
#}
#else {
#        die "Error \"$rmoldctdata\" in deleting old CT DATA \"$oldctprivatepath\"\n"; &logger;
#}

#
# /!\ DELETE OLD CT DATA /!\
# Be careful before uncomment !
#


$loggerInformations = "\n"; &logger;
$loggerInformations = "--- Script $0 end ---\n"; &logger;
$loggerInformations = "\n"; &logger;
$loggerInformations = "\n"; &logger;



exit 0;
