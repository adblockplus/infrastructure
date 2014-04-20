class rhodecode(
      $user,
) inherits private::rhodecode{

  group { $user:
        ensure => "present",
        name => $user,
  }

  user { $user :
       groups => ['root'],
       gid => $user,
       ensure => 'present',
       managehome => true,
       comment => 'This user was created by Puppet',
       require => Group[$user]
  }

  file { "/home/$user/rhodecode":
    ensure => "directory",
    mode => '755',
    owner => $user,
    require => User[$user],
  }

  exec { "Download_installer":
       command => "/usr/bin/wget https://rhodecode.com/dl/rhodecode-installer.py",
       cwd => "/home/$user/rhodecode",
       creates => "/home/$user/rhodecode/rhodecode-installer.py",
       require => File["/home/$user/rhodecode"],
  }

  file { "/home/$user/rhodecode/noninteractive.ini" :
       ensure => file,
       mode => 644,
       content => template("rhodecode/noninteractive.conf.erb"),
  }

  exec { "Install_RhodeCode_$user":
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

  service { "rhodecode": 
       ensure => "running",
       require => Exec["Install_RhodeCode_$user"],
  }

  file { "/home/$user/rhodecode/data/production.ini.puppet" :
       ensure => file,
       mode => 644,
       content => template("rhodecode/production.ini"),
       require => Service["rhodecode"],
  }

  exec { "Serve_Production_RhodeCode_$user":
       cwd => "/home/$user/rhodecode",
       command => "system/bin/paster serve data/production.ini.puppet > serve.log 2>&1 &",
       user => "root",
       provider => "shell",
       require => [
                  Service["rhodecode"],
                  File["/home/$user/rhodecode/data/production.ini.puppet"],
                  ],
       timeout => 1200,
  }

}
