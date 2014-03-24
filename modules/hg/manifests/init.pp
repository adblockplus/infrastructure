class hg(
      $user = "ubuntu",
){

  group { $user :
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

  file { "/home/$user/rhodecode/rhodecode-installer.py":
       ensure => file,
       mode => 755,
       content => template("hg/rhodecode-installer.conf.erb"),
  }

  file { "/home/$user/rhodecode/noninteractive.ini" :
       ensure => file,
       mode => 644,
       content => template("private/noninteractive.conf.erb"),
  }

  exec { "Install_RhodeCode_$user":
       command => "/usr/bin/sudo /usr/bin/python rhodecode-installer.py -n > installation.log 2>&1",
       user => "root",
       provider => "shell",
       cwd => "/home/$user/rhodecode",
       require => [
                  File["/home/$user/rhodecode/rhodecode-installer.py"], 
                  File["/home/$user/rhodecode/noninteractive.ini"]
                  ],
       timeout => 1200,
  }

}
