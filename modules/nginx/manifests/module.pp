define nginx::module (
  $ensure = 'present',
  $package = {},
  $path = "modules/$name",
) {

  include nginx
  include stdlib

  $id = "nginx-module-$title"

  ensure_resource('package', $id, merge({
    'ensure' => $ensure,
  }, $package))

  if ensure_state(Package[$id]) {

    concat::fragment {$id:
      content => template('nginx/module.erb'),
      order => '01',
      target => '/etc/nginx/nginx.conf',
    }

    Concat::Fragment[$id] <- Package[$id]
    Concat::Fragment[$id] ~> Service['nginx']
  }
}
