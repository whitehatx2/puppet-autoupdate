#settings - change these
#  please set the ovfImage name (torrent contents) and the torrent file name
#  oldVMName2Disable is in case this script is installed after the -
#   VMs are setup, set this to the image to stop and delete i.e. "kenyaEMR APP"

$torrent = "KenyaVM_13.2.2-2.ova.torrent" 
$oldVMName2Disable = "VM APP1"               # optional way to stop a VM.  skipped if blank
$ovfImageName = "KenyaVM_13.2.2-2.ova"       # ovf file name, it's inside the torrent
$virtualMachineName = ""                     # we will start the VM on success called [this]

Exec { path => "/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin" }

#### application:

node default {

if $ovfImageName =~ /^(.+)\.\w\w\w?$/ {
	$vmName = $1
}

package { "aria2":
	ensure => installed ,
	}
file { "/opt/KenyaEMR" :
	owner  => "puppet",
	group  => "puppet",
	ensure => "directory",
	}
file { "/opt/KenyaEMR/${torrent}" :
	source => "puppet:///files/${torrent}" ,
	ensure => present,
	}
exec { "torrentAction": 
	# run "torrentclient --continue -saveTo /downloads --torrent-file latest.torrent
	command => "/usr/bin/aria2c -c --dir=/opt/KenyaEMR/downloads -T /opt/KenyaEMR/${torrent}",
	timeout => 10800, #3 hours - torrents
	tries   => 5,
	creates => "/opt/KenyaEMR/downloads/${ovfImageName}",
	}
if $oldVMName2Disable != "" {
	# a trick is used here: ;echo "" is used to run a successful command, expecting the delete to fail
	exec { "disableOldVM":
		command => "vboxmanage unregistervm \"${oldVMName2Disable}\" --delete || echo \"\"",
		}
	}
if $vmName != "" {
	exec { "disableCurrentVM":
		command => "vboxmanage unregistervm \"${oldVMName2Disable}\" --delete || echo \"\"",
		}
	}
exec { "vboxImport":
	command => "vboxmanage import /opt/KenyaEMR/downloads/${ovfImageName} --vsys 0 --vmname ${vmName}",
	}
if $vmName != "" {
	exec { "startVM":
		command => "vboxmanage start ${vmName} || echo vbmstart ${vmName} -- JEFF DEBUG HERE",
		}
	}
}
