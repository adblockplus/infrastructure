node 'hg1' {

  class { 'hg':
    # data_path => '/opt/rhodecode',
    # repo_path => '/opt/rhodecode/repos',
    # python_env => '/opt/rhodecode',
    # admin_pass => 'password',
    # admin_user => 'admin',
    # admin_mail => 'admin@hgprueba.com',
    # port => 5000
  }

  #class {'nagios::client':
  #  server_address => 'hg.adblockplus.org'
  #}
}