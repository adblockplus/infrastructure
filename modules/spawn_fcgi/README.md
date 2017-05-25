# spawn_fcgi module #
Author	: Lars Fronius <lars@jimdo.com>

Version	: 0.1

Licence	: GPLv3

Fully puppet-lint compliant module for configuring spawn-fcgi pools via puppet.

## Intro ##
```
This module installs spawn-fcgi.
It is fully tested on Debian Squeeze.

It installs an init-script, which uses worker pool configs from /etc/spawn-fcgi/

Pool-Configuration is made by 'spawn_fcgi::pool' definition.
There is a wrapper for php-pool definitions in 'spawn_fcgi::php_pool'

See below for details.
```
## Class: spawn_fcgi ##
```
This class manage spawn_fcgi installation and init.d placement.
Use spawn_fcgi::pool or spawn_fcgi::php_pool for configuring spawn-fcgi worker pools.
```

## Define: spawn_fcgi::pool ##
```
Defines spawn-fcgi pools. Places all pool snippets into
/etc/spawn-fcgi, where they will be automatically loaded

Parameters :
   * ensure: typically set to "present" or "absent".
      Defaults to "present"
   * pool_name: set name of pool, which is used to identify config template
       Defaults to 'pool'
   * content: set the content of the pool snippet.
      Defaults to    'template("spawn_fcgi/pool.d/$pool_name.conf.erb")',
      Undefined loads generic 'template("spawn_fcgi/pool.d/pool.conf.erb")'
   * order: specifies the load order for this pool snippet.
      Defaults to "500"
   * fcgi_app: set binary to load fcgi-procs from
      Defaults to '/bin/false'
   * fcgi_app_args: set the arguments to load binary with
   * ip: set the ip the fcgi pool should listen on
      Defaults to '127.0.0.1'
   * port: set the port fcgi pool should listen on
      Defaults to '9000'
   * socket: set path where to spawn unix-socket
      Only works if no ip is specified!
   * mode: set file-mode of unix-socket
      Only works when socket is specified.
   * children: set number fcgi children to spawn
   * chroot: set chroot for fcgi procs
   * user: set user to run fcgi procs with
      Defaults to 'www-data'
   * group: set group to run fcgi procs with
      Defaults to 'www-data'
```

## Define: spawn_fcgi::php_pool ##
```
Define : spawn_fcgi::php_pool

Define a spawn-fcgi pool snippet for php worker. Places all pool snippets into
/etc/spawn-fcgi, where they will be automatically loaded.

Parameters :
   * ensure: typically set to "present" or "absent".
      Defaults to "present"
   * pool_name: set name of pool, which is used to identify config template
       Defaults to 'pool'
   * content: set the content of the pool snippet.
      Defaults to    'template("spawn_fcgi/pool.d/$pool_name.conf.erb")',
      Undefined loads generic 'template("spawn_fcgi/pool.d/pool.conf.erb")'
   * order: specifies the load order for this pool snippet.
      Defaults to "500"
   * ip: set the ip the fcgi pool should listen on
      Defaults to '127.0.0.1'
   * port: set the port fcgi pool should listen on
      Defaults to '9000'
   * socket: set path where to spawn unix-socket
      Only works if no ip is specified!
   * mode: set file-mode of unix-socket
      Only works when socket is specified.
   * children: set number fcgi children to spawn
   * chroot: set chroot for fcgi procs
   * user: set user to run fcgi procs with
      Defaults to 'www-data'
   * group: set group to run fcgi procs with
      Defaults to 'www-data'
```
## Sample Usage ##
```
   include spawn_fcgi
   spawn_fcgi::php_pool { "global":
       ensure   => present,
       order    => '000',
       children => '15'
   }
```
