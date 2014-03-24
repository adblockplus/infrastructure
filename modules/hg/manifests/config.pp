define hg::config (
  $data_path,
  $repo_path,
  $python_env,
  $admin_pass,
  $admin_user,
  $admin_mail,
  $port
) {

  exec { "$data_path:make-config" :
    command => "paster make-config RhodeCode production.ini",
    cwd => $data_path,
    creates => "$data_path/production.ini",
    path => [ "$python_env/bin", "/usr/bin", "/bin" ],
  }

  file { $repo_path :
    ensure => directory,
    before => Exec["$data_path:setup-rhodecode"],
  }

  exec { "$data_path:setup-rhodecode" :
    require => Exec["$data_path:make-config"],
    command => "paster setup-rhodecode production.ini --user='$admin_user' --password='$admin_pass' --email='$admin_mail' --repos='$repo_path' --force-yes",
    creates => "$data_path/rhodecode.db",
    cwd => $data_path,
    path => [ "$python_env/bin", "/usr/bin", "/bin" ],
  }

  exec { "$data_path:make-rcext" :
    require => Exec["$data_path:setup-rhodecode"],
    command => "paster make-rcext production.ini",
    creates => "$data_path/rcextensions/__init__.py",
    cwd => $data_path,
    path => [ "$python_env/bin", "/usr/bin", "/bin" ],
  }
}