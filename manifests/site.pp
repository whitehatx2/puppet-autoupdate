#settings - change these
#  please set the ovfImage name (torrent contents) and the torrent file name
#  oldVMName2Disable is in case this script is installed after the -
#   VMs are setup, set this to the image to stop and delete i.e. "kenyaEMR APP"

$oldVMName2Disable = "KenyaVM_13.2.2-2"               # optional way to stop a VM.  skipped if blank
$ovfImageName = "KenyaVM_13.2.2-2.ova"       # ovf file name, it's inside the torrent
$virtualMachineName = "KenyaVM_13.2.2-2"                     # we will start the VM on success called [this]

File["/opt/KenyaEMR"] ->
Exec["download"] ->
Exec["disableoldVM"] ->
#Exec["disableCurrentVM"] ->
Exec["vboxImport"] ->
Exec["startVM"]

file { "/opt/KenyaEMR" :
	owner  => "puppet",
	group  => "puppet",
	ensure => "directory",
     }

exec { "download":
	cwd => "/opt/KenyaEMR/", 
	command => "/usr/bin/wget -c ftp://54.201.64.239/KenyaVM_13.2.2-2.ova",
	timeout => 10800, #3 hours - torrents
	tries   => 5,
	creates => "/opt/KenyaEMR/${ovfImageName}",
     }

# a trick is used here: ;echo "" is used to run a successful command, expecting the delete to fail

exec { "disableoldVM":
	command => "/usr/bin/vboxmanage unregistervm \"${oldVMName2Disable}\" --delete || echo \"\"",
     }

#exec { "disableCurrentVM":
#	command => "/usr/bin/vboxmanage unregistervm \"${oldVMName2Disable}\" --delete || echo \"\"",
#     }

exec { "vboxImport":
	command => "/usr/bin/vboxmanage import /opt/KenyaEMR/${ovfImageName} --vsys 0 --vmname ${virtualMachineName}",
     }

exec { "startVM":
	command => "/usr/bin/vboxmanage startvm ${virtualMachineName}",
     }
