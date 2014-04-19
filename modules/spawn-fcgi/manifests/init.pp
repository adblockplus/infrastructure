# Class: spawn-fcgi
#
# This class manage spawn-fcgi installation and configuration.
#
# Use spawn-fcgi::pool for configuring spawn-fcgi pools
# Use spawn-fcgi::php-pool to configure a preconfigured php-pool
#
class spawn-fcgi {

    package { 'spawn-fcgi': ensure => installed }

    service { 'spawn-fcgi':
        ensure      => running,
        hasstatus   => true,
        enable      => true,
        require     => File['/etc/init.d/spawn-fcgi'],
    }

    file { '/etc/init.d/spawn-fcgi':
        ensure  => present,
        owner   => root,
        group   => root,
        mode    => '0755',
        content => template('spawn-fcgi/init-spawn-fcgi.erb'),
        require => Package['spawn-fcgi'],
    }

    file { '/etc/spawn-fcgi':
        ensure  => directory,
        require => Package['spawn-fcgi'],
    }
}
