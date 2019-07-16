class filtermaster(
  $malwaredomains_mirrors = hiera('filtermaster::malwaredomains_mirrors', []),
) {

  Cron {
    environment => concat(hiera('cron::environment', []), [
      'PYTHONPATH=/opt/sitescripts',
    ]),
  }

  include ssh

  # http://hub.eyeo.com/issues/16572
  concat::fragment {'sshd_max_limits':
    target => 'sshd_config',
    order => '50',
    content => '
      MaxSessions 100
      MaxStartups 100
    '
  }

  $repo_downloads = hiera_hash('filtermaster::repo_downloads', {})

  concat::fragment {'sshd_user_rsync':
    target => 'sshd_config',
    order => '99',
    content => template('filtermaster/sshd_rsync.erb'),
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
    mode => '0700',
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

  file {'/home/rsync/generated/gzip':
    ensure => directory,
    owner => rsync,
    require => File['/home/rsync/generated'],
  }

  file {'/home/rsync/.ssh':
    ensure => directory,
    owner => rsync,
    mode => '0600',
  }

  file {'/home/rsync/.ssh/authorized_keys':
    ensure => file,
    owner => rsync,
    mode => '0600',
    source => 'puppet:///modules/private/rsync@easylist-downloads.adblockplus.org.pub'
  }

  file {'/etc/ssh/ssh_host_ecdsa_key':
    require => Package['openssh-server'],
    notify => Service['ssh'],
    ensure => file,
    owner => root,
    group => root,
    mode => '0600',
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

  create_resources('filtermaster::repo_download', $repo_downloads)

  $repos = hiera_array('filtermaster::repos', [])
  filtermaster::repo_download {$repos:
  }

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
