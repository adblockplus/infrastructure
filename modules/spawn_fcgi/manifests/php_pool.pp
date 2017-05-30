# Define : spawn_fcgi::php_pool
#
# Define a spawn-fcgi pool snippet for php worker. Places all pool snippets into
# /etc/spawn-fcgi, where they will be automatically loaded.
#
# Parameters :
#    * ensure: typically set to "present" or "absent".
#       Defaults to "present"
#    * pool_name: set name of pool, which is used to identify config template
#        Defaults to 'pool'
#    * content: set the content of the pool snippet.
#       Defaults to    'template("spawn_fcgi/pool.d/$pool_name.conf.erb")',
#       Undefined loads generic 'template("spawn_fcgi/pool.d/pool.conf.erb")'
#    * order: specifies the load order for this pool snippet.
#       Defaults to "500"
#    * ip: set the ip the fcgi pool should listen on
#       Defaults to '127.0.0.1'
#    * port: set the port fcgi pool should listen on
#       Defaults to '9000'
#    * socket: set path where to spawn unix-socket
#       Only works if no ip is specified!
#    * mode: set file-mode of unix-socket
#       Only works when socket is specified.
#    * children: set number fcgi children to spawn
#    * chroot: set chroot for fcgi procs
#    * user: set user to run fcgi procs with
#       Defaults to 'www-data'
#    * group: set group to run fcgi procs with
#       Defaults to 'www-data'
#
# Sample Usage:
#    spawn_fcgi::php_pool { "global":
#        ensure   => present,
#        order    => '000',
#        children => '15'
#    }
#
define spawn_fcgi::php_pool (
    $ensure         = 'present',
    $content        = '',
    $order          = '500',
    $ip             = undef,
    $port           = '9000',
    $socket         = undef,
    $mode           = undef,
    $children       = undef,
    $chroot         = undef,
    $user           = 'www-data',
    $group          = 'www-data') {

    spawn_fcgi::pool { $name :
        ensure      => $ensure,
        pool_name   => 'php-pool',
        fcgi_app    => '/usr/bin/php-cgi',
        content     => $content,
        order       => $order,
        ip          => $ip,
        port        => $port,
        socket      => $socket,
        mode        => $mode,
        children    => $children,
        chroot      => $chroot,
        user        => $user,
        group       => $group
    }

}
