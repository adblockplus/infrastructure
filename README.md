Adblock Plus infrastructure
===========================

Website development
-------------------

### Requirements

* [VirtualBox](https://www.virtualbox.org/)
* [Vagrant](http://vagrantup.com/)

### Set up the server

All you have to do is start _Vagrant_ (that's going to take a while on
first boot):

    vagrant up

### Set up anwiki

1. Then go to [http://33.33.33.33](http://33.33.33.33).

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

9. Click on _Manage_ in the upper right area, then on _Import
contents_.

10. Chose an export file from the production website. Then _Upload
now_.

11. Click on _all_ and _Import now_.
