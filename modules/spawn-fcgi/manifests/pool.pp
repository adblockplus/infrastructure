# Define : spawn-fcgi::pool
#
# Define a spawn-fcgi pool snippet. Places all pool snippets into
# /etc/spawn-fcgi, where they will be automatically loaded
#
# Parameters :
#    * ensure: typically set to "present" or "absent".
#       Defaults to "present"
#    * pool_name: set name of pool, which is used to identify config template
#        Defaults to 'pool'
#    * content: set the content of the pool snippet.
#       Defaults to    'template("spawn-fcgi/pool.d/$pool_name.conf.erb")',
#       Undefined loads generic 'template("spawn-fcgi/pool.d/pool.conf.erb")'
#    * order: specifies the load order for this pool snippet.
#       Defaults to "500"
#    * fcgi_app: set binary to load fcgi-procs from
#       Defaults to '/bin/false'
#    * fcgi_app_args: set the arguments to load binary with
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

define spawn-fcgi::pool (
    $ensure         = 'present',
    $content        = '',
    $order          = '500',
    $pool_name      = undef,
    $fcgi_app       = undef,
    $fcgi_app_args  = undef,
    $ensure         = 'present',
    $ip             = undef,
    $port           = '9000',
    $socket         = undef,
    $mode           = undef,
    $children       = undef,
    $chroot         = undef,
    $user           = 'www-data',
    $group          = 'www-data') {

    $real_fcgi_app = $fcgi_app ? {
        undef   => '/bin/false',
        default => $fcgi_app,
    }

    if ( $socket != undef ) and ( $ip != undef ) {
        $temp_ip = $ip
    } elsif ( $socket == undef ) and ( $ip == undef ) {
        $temp_ip = '127.0.0.1'
    }
    $real_ip = $temp_ip ? {
        undef   => $ip ? {
            undef   => undef,
            default => $ip,
        },
        default => $temp_ip
    }

    $real_pool_name = $pool_name ? {
        default => $pool_name,
        undef   => 'pool'
    }

    $real_content = $content ? {
        ''          => template("spawn-fcgi/${real_pool_name}.erb"),
        default     => $content,
    }

    file { "/etc/spawn-fcgi/${order}-${name}":
        ensure  => $ensure,
        content => $real_content,
        mode    => '0644',
        owner   => root,
        group   => root,
        notify  => Service['spawn-fcgi'],
        require => Package['spawn-fcgi']
    }

}
