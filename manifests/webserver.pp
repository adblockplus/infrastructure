node 'web1' {
  include base

  class {'web::server':
    vhost => 'eyeo.com',
    repository => 'web.eyeo.com',
  }
}
