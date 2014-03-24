define hg::install($data_path, $python_env) {

  file { $data_path :
    ensure => directory,
    mode => "777",
  }

  class { 'python' :
    require => File[$data_path],
    version => 'system',
    dev => true,
    pip => true,
    virtualenv => true,
  }
  python::virtualenv { $python_env :
    require => Class['python'],
    ensure => present,
    version => 'system',
    systempkgs => false,
  }

  python::pip { "https://rhodecode.com/dl/latest" :
    virtualenv => $python_env,
  }
}