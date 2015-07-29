class filtermaster {

  Cron {
    environment => ['MAILTO=admins@adblockplus.org', 'PYTHONPATH=/opt/sitescripts'],
  }

  include ssh

  concat::fragment {'sshd_max_limits':
    target => 'sshd_config',
    order => '50',
    content => '
      MaxSessions 50
      MaxStartups 50
    '
  }

  concat::fragment {'sshd_user_rsync':
    target => 'sshd_config',
    order => '99',
    content => '
      Match User rsync
        AllowTcpForwarding no
        X11Forwarding no
        AllowAgentForwarding no
        GatewayPorts no
        ForceCommand rsync --server --sender -vltprz --delete-excluded . /home/rsync/generated/data/
    '
  }

  user {'rsync':
    ensure => present,
    comment => 'Filter list mirror user',
    home => '/home/rsync',
    managehome => true
  }

  file {'/home/rsync/update_repos.sh':
    ensure => file,
    owner => rsync,
    mode => 0700,
    source => 'puppet:///modules/filtermaster/update_repos.sh'
  }

  file {'/home/rsync/subscription':
    ensure => directory,
    owner => rsync
  }

  file {'/home/rsync/generated':
    ensure => directory,
    owner => rsync
  }

  file {'/home/rsync/.ssh':
    ensure => directory,
    owner => rsync,
    mode => 0600
  }

  file {'/home/rsync/.ssh/authorized_keys':
    ensure => file,
    owner => rsync,
    mode => 0600,
    source => 'puppet:///modules/private/rsync@easylist-downloads.adblockplus.org.pub'
  }

  file {'/etc/ssh/ssh_host_ecdsa_key':
    require => Package['openssh-server'],
    notify => Service['ssh'],
    ensure => file,
    owner => root,
    group => root,
    mode => 600,
    source => 'puppet:///modules/private/filtermaster.adblockplus.org_ssh.key'
  }

  file {'/etc/ssh/ssh_host_ecdsa_key.pub':
    require => Package['openssh-server'],
    notify => Service['ssh'],
    ensure => file,
    owner => root,
    group => root,
    source => 'puppet:///modules/private/filtermaster.adblockplus.org_ssh.pub'
  }

  package {['p7zip-full']:}

  define repo_download($alias = $title) {

    exec {"fetch_${title}":
      command => "hg clone https://hg.adblockplus.org/${title} /home/rsync/subscription/${title}",
      path => ["/usr/bin/", "/bin/"],
      require => Package['mercurial'],
      user => rsync,
      timeout => 0,
      onlyif => "test ! -d /home/rsync/subscription/${title}"
    }
  }

  create_resources('filtermaster::repo_download', $repo_download)

  cron {'update_subscription':
    ensure => present,
    command => "python -m sitescripts.subscriptions.bin.updateSubscriptionDownloads 3>&1 1>/dev/null 2>&3 | perl -pe 's/^/\"[\" . scalar localtime() . \"] \"/e' >> /tmp/subscription_errors && chmod 666 /tmp/subscription_errors 2>/dev/null",
    user => rsync,
    require => User['rsync'],
    minute => '*/10'
  }

  cron {'update_malware':
    ensure => present,
    command => "python -m sitescripts.subscriptions.bin.updateMalwareDomainsList",
    user => rsync,
    require => User['rsync'],
    hour => '*/6',
    minute => 15
  }

  cron {'update_repos':
    ensure => present,
    command => "/home/rsync/update_repos.sh",
    user => rsync,
    require => [
      User['rsync'],
      File['/home/rsync/update_repos.sh']
    ],
    minute  => '8-58/10'
  }

  class {'sitescripts':
    sitescriptsini_content => template('filtermaster/sitescripts.ini.erb'),
  }
}
