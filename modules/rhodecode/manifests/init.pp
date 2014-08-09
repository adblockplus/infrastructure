class rhodecode(
    $user,
    $domain,
    $is_default = false
  ) inherits private::rhodecode{

  include nginx

  nginx::hostconfig {$domain:
    source => 'puppet:///modules/rhodecode/default_rhodecode',
    is_default => $is_default,
    enabled => true,
    log => 'access_log_rhodecode',
  }

  group {$user:
        ensure => "present",
        name => $user,
  }

  user {$user:
       groups => ['root'],
       gid => $user,
       ensure => 'present',
       managehome => true,
       comment => 'This user was created by Puppet',
       require => Group[$user]
  }

  file {"/home/$user/rhodecode":
    ensure => "directory",
    mode => '755',
    owner => $user,
    require => User[$user],
  }

  exec {"Download_installer":
       command => "/usr/bin/wget https://rhodecode.com/dl/rhodecode-installer.py",
       cwd => "/home/$user/rhodecode",
       creates => "/home/$user/rhodecode/rhodecode-installer.py",
       require => File["/home/$user/rhodecode"],
  }

  file {"/home/$user/rhodecode/noninteractive.ini" :
       ensure => file,
       mode => 644,
       content => template("rhodecode/noninteractive.conf.erb"),
  }

  exec {"Install_RhodeCode_$user":
       command => "/usr/bin/sudo /usr/bin/python rhodecode-installer.py -n > installation.log 2>&1",
       user => "root",
       provider => "shell",
       cwd => "/home/$user/rhodecode",
       require => [
                  File["/home/$user/rhodecode/noninteractive.ini"],
                  Exec["Download_installer"]
                  ],
       timeout => 1200,
  }

  service {"rhodecode": 
       ensure => "running",
       enable => true,
       require => Exec["Install_RhodeCode_$user"],
  }

}
