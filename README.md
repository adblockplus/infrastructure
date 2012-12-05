Adblock Plus infrastructure
===========================

The new Adblock Plus infrastructure uses
[Puppet](http://puppetlabs.com/) to set up and configure our nodes,
and to have realistic test environments for infrastructure components.

Our Puppet manifests are only tested with Ubuntu 12.04 right now.

Development environment
-----------------------

With the new infrastructure, any work we do on our systems or
infrastructure components should be done in a local test
environment. Thanks to Puppet, we can easily set up local VMs just
like our production environments.

The most convenient way to do this is to use Vagrant, as described
below.

### Requirements

* [VirtualBox](https://www.virtualbox.org/)
* [Vagrant](http://vagrantup.com/)

### Set up the server

All you have to do is start _Vagrant_ (that's going to take a while on
first boot):

    vagrant up

After you've made changes to Puppet manifests, you can update it like this:

	vagrant provision

Website development
-------------------

### Requirements

* Make sure the _adblockplusorg_ module is included in _vagrant.pp_.
* A clone of the _anwiki_ repository, next to this directory.

### Set up anwiki

1. Go to [http://33.33.33.33](http://33.33.33.33).

2. Click on the green _Begin installation_ button.

3. Enter _http://33.33.33.33/_ as _Root URL_ and empty the _Cookies
domain_ field.

4. Click on _Edit MySQL Connection_ and enter _anwiki_ as _user_ and
_database_, _vagrant_ as password. You'll have to repeat this step for
each plugin.

5. Press all the green buttons until you're asked to create an account. Do so.

6. Click on _Don't ping_, ignore the error message on the next page
and proceed to the website.

7. Go to
[http://33.33.33.33/en/_include/menu](http://33.33.33.33/en/_include/menu).

8. Click on _Delete_ and then on _Delete the page in ALL languages_.

9. Click on _Manage_ in the upper right area, then on _Edit
configuration_.

10. Click on _Edit location_ and check _Friendly URLs_, then click on
_Save settings_.

11. Click on _Manage_ again, then _Import contents_.

12. Chose an export file from the production website. Then _Upload
now_.

13. Click on _all_ and _Import now_.

### Update anwiki

SSH to the server:

    vagrant ssh

Then execute the following:

    sudo deploy-anwiki

If you have a clone of anwiki (see _Requirements_), this will deploy
it on the virtual machine. If not, it will clone anwiki from the
official repository.
