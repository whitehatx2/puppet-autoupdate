#settings - change these
#  please set the ovfImage name (torrent contents) and the torrent file name
#  oldVMName2Disable is in case this script is installed after the -
#   VMs are setup, set this to the image to stop and delete i.e. "kenyaEMR APP"

$oldVMName2Disable = "VM APP1"               # optional way to stop a VM.  skipped if blank
$ovfImageName = "KenyaVM_13.2.2-2.ova"       # ovf file name, it's inside the torrent
$virtualMachineName = ""                     # we will start the VM on success called [this]

File["/opt/KenyaEMR"] ->
Exec["download"] ->
#Exec["disableoldVM"] ->
#Exec["disableCurrentVM"] ->
Exec["vboxImport"] ->
Exec["startVM"]

file { "/opt/KenyaEMR" :
	owner  => "puppet",
	group  => "puppet",
	ensure => "directory",
	}
exec { "download": 
	command => "/usr/bin/wget ftp://54.201.64.239/KenyaVM_13.2.2-2.ova",
	timeout => 10800, #3 hours - torrents
	tries   => 5,
	creates => "/opt/KenyaEMR/downloads/${ovfImageName}",
	}

# a trick is used here: ;echo "" is used to run a successful command, expecting the delete to fail
exec { "disableOldVM":
	command => "vboxmanage unregistervm \"${oldVMName2Disable}\" --delete || echo \"\"",
	}

exec { "disableCurrentVM":
	command => "vboxmanage unregistervm \"${oldVMName2Disable}\" --delete || echo \"\"",
     }

exec { "vboxImport":
	command => "vboxmanage import /opt/KenyaEMR/downloads/${ovfImageName} --vsys 0 --vmname KEMR",
	}
exec { "startVM":
	command => "vboxmanage start KEMR || echo vbmstart KEMR",
     }
}
