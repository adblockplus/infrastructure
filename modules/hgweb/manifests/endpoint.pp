class hgweb::endpoint () {
  include adblockplus

  ensure_packages(['python3'])

  file { '/home/hg/import':
    ensure => 'directory',
    owner => 'hg',
    group => 'hg',
    mode => '0755',
  }

  file {[
      '/home/hg/import/gitlab',
      '/home/hg/import/github'
    ]:
      ensure => 'directory',
      owner => 'hg',
      group => 'hg',
      mode => '0755',
      require => File['/home/hg/import'],
  }

  file {'/usr/local/bin/gitlab-webhook':
    ensure => 'present',
    owner => 'root',
    group => 'root',
    mode => '0755',
    source => 'puppet:///modules/hgweb/gitlab-webhook.py',
    require => [
      Package['python3'],
    ],
  }

  file {'/etc/systemd/system/gitlab-webhook.service':
    ensure => 'present',
    owner => 'root',
    group => 'root',
    mode => '0644',
    source => 'puppet:///modules/hgweb/gitlab-webhook.service',
    require => File['/usr/local/bin/gitlab-webhook'],
  }

  Exec {
    path => ['/usr/bin', '/bin'],
  }

  exec {'enable-service-gitlab-webhook':
    command => 'systemctl enable gitlab-webhook.service',
    user => 'root',
    unless => 'systemctl is-enabled gitlab-webhook.service',
    require => File['/etc/systemd/system/gitlab-webhook.service'],
  }

  service {'gitlab-webhook':
    ensure => 'running',
    enable => true,
    hasrestart => false,
    provider => 'systemd',
    require => Exec['enable-service-gitlab-webhook'],
    subscribe => File['/usr/local/bin/gitlab-webhook'],
  }

  exec {'reload-gitlab-webhook-daemon':
    notify => Service['gitlab-webhook'],
    command => 'systemctl daemon-reload',
    subscribe => File['/etc/systemd/system/gitlab-webhook.service'],
    refreshonly => true,
  }

  $sudoers_content = join([
    "www-data ALL=(hg) NOPASSWD: /usr/bin/git",
    "www-data ALL=(hg) NOPASSWD: /usr/bin/hg",
  ], "\n")

  adblockplus::sudoers {'gitlab_sync_repository':
    config => {
      ensure => 'present',
      content => "$sudoers_content\n",
    },
  }
}
