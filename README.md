Adblock Plus infrastructure
===========================

The Adblock Plus infrastructure uses [Puppet](http://puppetlabs.com/)
to set up servers, and to have a realistic development environment.

Our Puppet manifests are only tested with Ubuntu 12.04 right now.

Private files
-------------

Some parts of our infrastructure are, obviously, confidential. We have
htpasswd files, SSH keys and SSL certificates that we need to be
careful with.

That's why _modules/private_ is missing, and needs to be placed there
manually. We provide stub versions of all those files in
_modules/private-stub_, so just linking or copying that to
_modules/private_ will make everything work locally.

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
* _modules/private_ exists (see above)

### Start a VM

For each production server, we have a Vagrant VM with the same host
name.

To start the _server0_ VM:

	vagrant up server0

After you've made changes to Puppet manifests, you can update it like this:

	vagrant provision server0

You can omit the VM name if you want to boot or provision all
VMs. This might take a while and eat quite a bit of RAM though.

Adding a server
---------------

1. Add entries in _Vagrantfile_ and _manifests/vagrant.pp_

2. Add the host name to one of the manifests imported by
_manifests/site.pp_

3. Make sure the server uses the _nagios::client_ class and add a
_nagios\_host_ to _manifests/monitoringserver.pp_

Monitoring
----------

Monitoring is fully functional in the development environment:
[http://10.8.0.98/nagios3/](http://10.8.0.98/nagios3/)

The monitoring service of our production environment runs on
_monitoring.adblockplus.org_.

### Add a user for the web interface

1. Add your desired user name to _admins_ in _monitoringserver.pp_

2. Add your user name/password to
_modules/private-stub/files/nagios-htpasswd_, e.g.:
    
	htpasswd modules/private-stub/files/nagios-htpasswd fhd

3. Reprovision

Bear in mind that someone will have to add your user name/password to
the production htpasswd file if you need access to
_monitoring.adblockplus.org_.

### Add a contact (to receive alerts)

Add a _nagios\_contact_ similar to the existing ones in
_monitoringserver.pp_, and add it to the _admins_ host group.

There are two sets of contacts, those for the development environment
and those for the production environment, you probably want the
latter.

Website development
-------------------

### Requirements

* A clone of the _anwiki_ repository, next to this directory.
* The running _server0_ VM.

### Set up anwiki

1. Go to [http://10.8.0.97](http://10.8.0.97).

2. Click on the green _Begin installation_ button.

3. Enter _http://10.8.0.97/_ as _Root URL_ and empty the _Cookies
domain_ field.

4. Click on _Edit MySQL Connection_ and enter _anwiki_ as _user_ and
_database_, _vagrant_ as password. You'll have to repeat this step for
each plugin.

5. Press all the green buttons until you're asked to create an account. Do so.

6. Click on _Don't ping_, ignore the error message on the next page
and proceed to the website.

7. Go to
[http://10.8.0.97/en/_include/menu](http://10.8.0.97/en/_include/menu).

8. Click on _Delete_ and then on _Delete the page in ALL languages_.

9. Click on _Manage_ in the lower right area, then on _Edit
configuration_.

10. Click on _Edit location_, set _Home_ to _en_ and check _Friendly
URLs_, then click on _Save settings_.

11. Click on _Manage_ again, then _Import contents_.

12. Chose an export file from the production website. Then _Upload
now_.

13. Click on _all_ and _Import now_.

### Update anwiki

SSH to the server:

	vagrant ssh server0

Then execute the following:

	sudo deploy-anwiki

If you have a clone of anwiki (see _Requirements_), this will deploy
it on the virtual machine. If not, it will clone anwiki from the
official repository.
