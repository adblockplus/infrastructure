Adblock Plus infrastructure
===========================

The Adblock Plus infrastructure uses [Puppet](http://puppetlabs.com/)
to set up servers, and to have a realistic development environment.

Our Puppet manifests are only tested with Ubuntu 12.04 right now.

Environment specific setup
--------------------------

Some infrastructure parts are specific to the environment (such as e.g.
*development*, *test* and *production*) whilst passwords, for example,
are confidential. In order to allow for such specific configuration, the
repository requires a set of manual operations during the initial setup:

### `modules/private`

The `private` module is destined to store confidential information such as
[RSA](http://en.wikipedia.org/wiki/RSA_%28cryptosystem%29) keys, `htpasswd`
files and so on. The repository provides a `private-stub` module containing
defaults suitable for development and testing purposes. One can create a
symbolic link to start using the resource:

#### UNIX-like

    ln -s private-stub modules/private

#### Windows

    MKLINK /D modules\private private-stub

When creating a custom version, one may inspect the `modules/private-stub`
directory to determine which resources have to be provided.

### `hiera/private`

Analogous to `modules/private`, [Hiera](https://docs.puppetlabs.com/hiera/1/)
configuration files specific to the current environment are expected to be
found in `hiera/private`. Default resources for development (and testing)
purposes are provided within `modules/private-stub/hiera`:

#### UNIX-like

    ln -s ../modules/private-stub/hiera hiera/private

#### Windows

    MKLINK /D ..\modules\private-stub\hiera hiera\private

Note that custom versions are recommended to be tracked together with the
custom `private` module, if any.

Development environment
-----------------------

As with our other projects, all changes to our infrastructure should
be made in a local development environment, and reviewed before
deployment. Thanks to Puppet, we can easily set up local VMs that
mirror our production environment.

The most convenient way to do this is to use Vagrant, as described
below.

### Requirements

* [VirtualBox](https://www.virtualbox.org/)
* [Vagrant](http://vagrantup.com/)
* Both `modules/private` and `hiera/private` exist (see above)

### Start a VM

For each production server, we have a Vagrant VM with the same host
name.

To start the _filter1_ VM:

	vagrant up filter1

After you've made changes to Puppet manifests, you can update it like this:

	vagrant provision filter1

You can omit the VM name if you want to boot or provision all
VMs. This might take a while and eat quite a bit of RAM though.

### SSH to the server

You can use vagrant to connect as the vagrant user:

	vagrant ssh server5

If you want to test "real" SSH access you can use the test user account defined
in _private-stub_:

	ssh -i modules/private/files/id_rsa test@10.8.0.100

The default password for this user (required for the _sudo_ command) is "test".

Adding a host
-------------

To set up a new host, extend the custom `hiera/private/host.yaml` by another
`servers:` item, e.g.:

    # ...
    custom1:
        ip: [10.8.0.254]
        dns: foobar.example.com
        ssh_public_key: AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAA...
        role: codereviewserver

See `modules/base/manifests/init.pp`, especially the definition of the named
type `explicit_host_record()` within class `base`, for more information on the
possible option keys and values.

In development, this is all that needs to be done before the new box can be
started using `vagrant up ...`. Production servers, however, need a working
Puppet configuration first (see below).

Configuring Puppet
------------------

### Prerequisites

1. Install Ubuntu Server 12.04 LTS
2. Run `hiera/install_precise.py` as user `root` to install Puppet and Hiera
3. Enable pluginsync (Add the following to the _main_ section in
   _/etc/puppet/puppet.conf_)

	pluginsync=true

4. Configure the master address (Add the following to the bottom of
	_/etc/puppet/puppet.conf_)

	[agent]
	server = puppetmaster.adblockplus.org

Now you can either set it up as a pure agent or as a master. The
master provides the configuration, agents fetch it from the master and
apply it locally. The master is also an agent, fetching configuration
from itself.

### Puppet agent

1. Attempt an initial provisioning, this will fail

	puppet agent --test

2. On the master: List the certificates to get the name of the new
   agent's certificate

	puppet cert list

3. Still on the master: Sign the certificate, e.g. for serverx:

	puppet cert sign serverx

4. Back on the agent: Attempt another provisioning, it should work now

	puppet agent --test

### Puppet master

1. Configure the certificate name (Add the following to the _master_
   section in _/etc/puppet/puppet.conf_)

	certname = puppetmaster.adblockplus.org

2. Install the required packages

	apt-get install puppetmaster mercurial

3. Clone the infrastructure repository

	hg clone ssh://hg@adblockplus.org/infrastructure /etc/puppet/infrastructure
	rmdir /etc/puppet/{modules,manifests,templates}
	ln -s /etc/puppet/infrastructure/manifests /etc/puppet/manifests
	ln -s /etc/puppet/infrastructure/modules /etc/puppet/modules

4. Make sure to put the private files in place (see above)

5. Provision the master itself

	puppet agent --test

Updating a production server
----------------------------

Puppet agent has to be rerun on the servers whenever their configuration is
changed. The _kick.py_ script automates and simplifies that task, e.g. the
following will provision all servers (requires Puppet and PyYAML):

	kick.py -u serveradmin all

Here _serveradmin_ is your user account on the servers, it will be used to
run Puppet on the servers via SSH (sudo privilege required). You can list any
host groups defined in _manifests/monitoringserver.pp_ or individual servers.
You can also use _-v_ flag to see verbose Puppet output or _-t_ flag to do a
dry run without changing anything.

Monitoring
----------

Monitoring is fully functional in any environment, including development.
Here, after bootstrapping the `server4` box, one can access the Nagios GUI
from the host machine via <https://nagiosadmin:nagiosadmin@10.8.0.99/>.

The monitoring service of our production environment, however, is accessible
via <https://monitoring.adblockplus.org/>.
Add yourself to _files/nagios-htpasswd_ in the _private_ module used on the
server, or have someone add you if you don't have access.


