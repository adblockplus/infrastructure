define hg::service (
  $data_path,
  $python_env,
) {

  service { "rhodecode:$data_path" :
    provider => "base",
    ensure => running,
    start => "$python_env/bin/paster serve --log-file=$data_path/rhodecode.log $data_path/production.ini start",
    restart => "$python_env/bin/paster serve --log-file=$data_path/rhodecode.log $data_path/production.ini restart",
    stop => "$python_env/bin/paster serve $data_path/production.ini stop",
    status => "$python_env/bin/paster serve $data_path/production.ini status",
  }

}