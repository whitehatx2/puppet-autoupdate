cron { signCertificates: 
	command => "sudo puppetca --sign --all",
	user => root,
	minute => 1,
}
