class sitescripts (
    $sitescriptsini_source = undef
  ){

  file {'/etc/sitescripts.ini':
    mode => 644,
    owner => root,
    group => root,
    source => $sitescriptsini_source
  }

  exec { "fetch_sitescripts":
    command => "hg clone https://hg.adblockplus.org/sitescripts /opt/sitescripts",
    path    => [ "/usr/bin/", "/bin/" ],
    require => Package['mercurial'],
	onlyif => "test ! -d /opt/sitescripts"
  }
}