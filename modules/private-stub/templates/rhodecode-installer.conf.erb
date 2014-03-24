#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
RhodeCode Installer
------------------------------

CLI assistant for installing, upgrading & removing
of RhodeCode Enterprise

To check the log do: tail -f /tmp/rhodecode-installer.log


Published under Business Source License.
Read the full license text at https://rhodecode.com/licenses
© 2013, RhodeCode GmbH. All rights reserved.
"""

import sys
import traceback
import time
import os
import os.path
import zipfile
import optparse
import shutil
import platform
import urllib
import urllib2
import json
import getpass
import ConfigParser
from subprocess import Popen, PIPE


##### SETUP LOGGING ######
# http://docs.python.org/dev/howto/logging.html
import logging
import tempfile
log = logging.getLogger('installer')
log.setLevel(logging.DEBUG)
formatter = logging.Formatter('%(levelname)s: %(message)s')
formatter_time = logging.Formatter('%(asctime)s - %(levelname)s: %(message)s')
# create file handler
tmp_file = os.path.join(tempfile.gettempdir(), "rhodecode-installer.log")
file_handler = logging.FileHandler(tmp_file)
log.setLevel(logging.DEBUG)
file_handler.setFormatter(formatter_time)
log.addHandler(file_handler)
#log.propagate = True
######################


##### CONSTANTS ######
MY_VERSION = "0.7.0"  # <- adjust this on each new version!

PLATFORM = platform.platform().lower()
if not "windows" in PLATFORM and os.path.isfile("/etc/arch-release"):
    PLATFORM = "Arch-%s" % PLATFORM
CONFIG_FILE = os.path.join(os.getcwd(), "data" , "installer.ini")
OPTIONS = None

SECTION = "installer"
IS_ROOT = True
BUILD = True

__version__ = MY_VERSION
# text colors
if "windows" in PLATFORM:
    GREEN = ""
    YELLOW = ""
    RED = ""
    BOLD = ""
    RESET = ""
else:  # use color under Linux
    GREEN = '\033[0;32m'
    YELLOW = '\033[0;33m'
    RED = '\033[0;31m'
    BOLD = '\033[1m'
    RESET = '\033[00m'
######################



def quit():
    """
    Ends the CLI session
    """
    _print("\nThanks, it was a pleasure to be your assistant!\n")
    sys.exit()

def clear():
    """
    Clears the screen
    """
    if "windows" in PLATFORM:
        os.system('cls')
    else:
        os.system('clear')

def run(command, show=True):
    """
    runs a script or command in shell
    returns the output as string

    :param command:
    :type command:
    :return a list of output and errors
    """
    #show = False
    if show:
        _print("... running command: %s" % command)
    log.debug("CMD: %s" % command)
    p = Popen(command, stdout=PIPE, stderr=PIPE, shell=True)
    output, errors = p.communicate()
    log.debug(output)
    if errors != "" and p.returncode != 0:
        log.error(errors)
    else:  # ignore apps which write to stderr for fun
        errors = ""
    return output, errors

def _print(txt):
    """
    prints output and automatically writes to log
    """
    print(txt)
    log.debug(txt)

def su(cmd, manual_set_user=""):
    """
    returns a command under Linux wrapped
    in an own shell of the user. or just
    the pure command
    """
    if "windows" in PLATFORM:
        return cmd
    else:
        if manual_set_user == "":
            c, config = config_variables()
            user = c["user"]
        else:
            user = manual_set_user
        return "su %s -s /bin/sh -c '%s' " % (user, cmd)

def success(txt):
    """
    prints a success text in green letters
    """
    _print(GREEN+txt+RESET)

def warning(txt):
    """
    prints a warning text in yellow letters
    """
    _print(YELLOW+txt+RESET)
    log.warning(txt)

def error(title,msg="", show_menu=True):
    """
    prints an error text in red
    """
    global tmp_file
    _print(RED+title+RESET+"\n\n"+msg)
    log.error(title+": "+msg)
    print("\nIf you can not fix the error by yourself then please contact us:")
    print("1. Go to https://rhodecode.com/help")
    print("2. Start a new discussion")
    print("3. Tell us about your system and the versions of the installed RhodeCode applications")
    print("4. Attach to the discussion the Installer log file located at %s\n" % tmp_file)
    if show_menu:
        # back to menu
        loop = True
        while loop:
            txt = "\nPlease select an option:\n"
            txt = "%s[b] Back to menu\n" % txt
            txt = "%s[q] Quit Installer\n" % txt
            txt = "%s> " % txt
            inp = raw_input(txt).strip()
            if inp == "q":
                quit()
            else:
                loop = False
    else:
        sys.exit()

def basic_menu(prefix_text=""):
    """
    prints a standard back and quit menue
    """
    global OPTIONS
    if OPTIONS.noninteractive is not None:
        quit()
    loop = True
    while loop:
        txt = "%s\nPlease select an option:\n" % prefix_text
        txt = "%s[b] Back to menu\n" % txt
        txt = "%s[q] Quit Installer\n" % txt
        txt = "%s> " % txt
        inp = raw_input(txt).strip()
        if inp == "q":
            quit()
        else:
            loop = False

def convert_version_to_int(version):
    """
    converts a version string in the format 1.2.3 to an int
    accepts up to 3 positions and removes words
    :returns: int (0 on error)
    """
    v = ""
    # remove all non-digit and non-dot characters
    for c in version.strip():
        if c.isdigit() or c == ".":
            v = v + c
    parts = v.split(".")
    ret = 0
    if len(parts) > 0 and parts[0] != "":
        ret = ret + int(parts[0].strip()) * 10000
    if len(parts) > 1:
        ret = ret + int(parts[1].strip()) * 100
    if len(parts) > 2:
        ret = ret + int(parts[2].strip())
    #print ("converted %s to %s" % (v, ret))
    return ret

def test_convert_version_to_int():
    assert convert_version_to_int("foo") == 0
    assert convert_version_to_int("0.0.1") == 1
    assert convert_version_to_int("0.0.23") == 23
    assert convert_version_to_int("0.1.1") == 101
    assert convert_version_to_int("0.12.34") == 1234
    assert convert_version_to_int("0.12.4") == 1204
    assert convert_version_to_int("0.12.34") == 1234
    assert convert_version_to_int("0.12") == 1200
    assert convert_version_to_int("34") == 340000
    assert convert_version_to_int("1.2.3") == 10203
    assert convert_version_to_int("12.34.56") == 123456
    assert convert_version_to_int("12.34.56stable") == 123456
    assert convert_version_to_int("12.34.56 stable") == 123456

def escape_for_shell(txt):
    """
    Escapes double quotes, backticks and
    dollar signs in given string.

    :returns: string which can be used at CLI/shell
    """
    for char in ('"', '$', '`'):
        txt = txt.replace(char, '\%s' % char)
    return txt


def coming_soon():
    clear()
    _print(HEADER)
    print ("Sorry, I am not able to do that, yet!\n\nPlease follow my developers at https://twitter.com/rhodecode to be informed when I finally mastered this skill!\n")
    basic_menu()


def python_install_cmds():
    """
    Returns a list of shell commands which are necessary
    for the installation of Python, etc. under certain
    Linux distributions

    :returns: a list of shell commands
    """
    global PLATFORM, BUILD
    c, config = config_variables()

    cmds = []
    # Ubuntu  or Debian
    if "ubuntu" in PLATFORM or "debian" in PLATFORM or "mint" in PLATFORM:
        cmds = ["apt-get update -y",
                "apt-get install python-dev build-essential git -y",
                "apt-get install libpq-dev libmysqlclient-dev -y",
                "apt-get install libldap2-dev libsasl2-dev libssl-dev -y"]
    # Fedora 19, Redhat, CentOS
    elif "fedora" in PLATFORM or "redhat" in PLATFORM or "centos" in PLATFORM:
        cmds = [
                "yum install make automake gcc gcc-c++ kernel-devel git-core -y",
                "yum install python-devel -y",
                "yum install mysql-devel postgresql-devel -y",
                "yum install openldap-devel -y"]
    #Amazon Linux:
    #Has Python 2.6.8 pre-installed
    elif "amzn1" in PLATFORM:
        cmds = [
                "yum install make automake gcc gcc-c++ kernel-devel git-core -y",
                "yum install python26-devel -y",
                "yum install mysql-devel postgresql-devel MySQL-python -y",
                "yum install openldap-devel -y"]
    #OpenSUSE and SUSE Linux Enterprise Server (SLES)
    #Has Python 2.6.8 pre-installed
    elif "suse" in PLATFORM:
        cmds = [
                "zypper -n install gcc make git-core",
                "zypper -n install python-devel",
                "zypper -n install python-xml",
                # for openSUSE (xml is a dep for virtualenv & pip):
                # SLES does not know ython-virtualenv
                "zypper -n install python-virtualenv",
                "zypper -n install libpq5",
                "zypper -n install mysql-devel postgresql91-devel",
                "zypper -n install openldap2-devel"]
    # At Windows the prebuilt dependencies can be downloaded from
    # http://www.lfd.uci.edu/~gohlke/pythonlibs/
    # git, mysql, postgres and ldap are bundled as EXE files
    elif "windows" in PLATFORM:
        cmds = []

    #Arch Linux:
    #has python2 and python3, but not python or pip so symlinks are needed
    # does not have a platform value, so a distro-specific folder is searched
    if len(cmds) == 0:
        if os.path.isfile("/etc/arch-release"):
            cmds = [
                    "pacman -Syy",
                    "pacman -S --noconfirm git python2", # python2-pip",
                    "pacman -S --noconfirm mysql-python postgresql-libs",
                    "pacman -S --noconfirm python2-ldap"]
    return cmds

def python_path():
    """
    :returns: the python command in virtualenv
    """
    # default
    cmd = "python"
    # on Arch Linux the python command defaults to python 3.x
    # so we need to call the one for python 2.x
    if os.path.isfile("/etc/arch-release"):
        cmd = "python2"
    return cmd

def install_path(user=""):
    """
    Return the path where RCE should be installed.
    Under Windows it is the current path and under Linux
    it is the homefolder plus rhodecode

    :returns: the absolute path as string or "" on error!
    """
    global PLATFORM
    ret = ""
    if "windows" in PLATFORM:
        return os.getcwd()
    if not "windows" in PLATFORM:
        cmd = su("echo ~%s" % user, user)
        out, err = run(cmd, False)
        if err != "":
            return ""
        else:
            home = str(out.split()[0])
            return os.path.join(home, "rhodecode")

def pip_cmd(system_path="", proxy="", proxy_cert=""):
    """
    Returns the full path to Pip (OS-agnostic) plus
    "install -I ". It respects a possible proxy setting.

    :returns: string
    """
    # default
    cmd = "pip"
    # on Arch Linux the python command defaults to python 3.x
    # so we need to call the one for python 2.x
    #if os.path.isfile("/etc/arch-release"):
    #    cmd = "pip"  # pip2
    proxy_str = ""
    proxy_cert_str = ""
    if len(proxy) > 3:
        proxy_str = " --proxy=%s" % proxy
    proxy_str = " --timeout=60%s" % proxy_str
    if len(proxy_cert) > 1:
        proxy_cert_str = " --cert=%s" % proxy_cert
    if system_path == "":  # global install
        ret = "%s install -I%s%s" % (cmd, proxy_str, proxy_cert_str)
    else:
        if "windows" in PLATFORM:
            ret = "%s\\Scripts\\%s install -I%s%s" % (system_path, cmd, proxy_str, proxy_cert_str)
        else:
            ret = "%s/bin/%s install -I%s%s" % (system_path, cmd, proxy_str, proxy_cert_str)
    return ret

def sudo_cmd(proxy=""):
    """
    If proxy is given then it attaches a -E to keep the current
    users environment (which can have the http_proxy ENV var)

    :returns: the correct sudo command (if installed) as string
    """
    cmd = ""
    if os.path.isfile("/usr/bin/sudo"):
        cmd = "sudo "
        if len(proxy) > 3:
            cmd = "sudo -E "
    return cmd

def config_variables(config_file=""):
    """
    :returns: a dict of config or OS-related variables
    :returns: the config parser object
    """
    # get config variables
    config = ConfigParser.ConfigParser()
    if config_file == "":
        config_file = CONFIG_FILE
    config.read(config_file)
    SECTION = "installer"
    ret = {}
    ret["user"] = config.get(SECTION, "user")
    ret["data_path"] = config.get(SECTION, "data_path")
    ret["system_path"] = config.get(SECTION, "system_path")
    ret["repo_path"] = config.get(SECTION, "repo_path")
    ret["ini_filename"] = config.get(SECTION, "ini_filename")
    #ret["database"] = config.get(SECTION, "database")
    ret["version"] = config.get(SECTION, "version")
    ret["installer_version"] = config.get(SECTION, "installer_version")
    ret["python"] = python_path()
    ret["proxy"] = config.get(SECTION, "proxy")
    ret["proxy_cert"] = config.get(SECTION, "proxy_cert")
    ret["sudo"] = sudo_cmd(ret["proxy"])
    ret["pip"] = pip_cmd(ret["system_path"], ret["proxy"], ret["proxy_cert"])
    return ret, config

def config_variables_old_installer(config_file=""):
    """
    used to parse config variables file from
    installer < 0.5.0
    :returns: the config parser object
    """
    # get config variables
    config = ConfigParser.ConfigParser()
    if config_file == "":
        config_file = CONFIG_FILE
    config.read(config_file)
    SECTION = "installer"
    ret = {}
    ret["user"] = config.get(SECTION, "user")
    ret["app_path"] = config.get(SECTION, "app_path")
    ret["venv_path"] = config.get(SECTION, "venv_path")
    ret["repo_path"] = config.get(SECTION, "repo_path")
    ret["ini_filename"] = config.get(SECTION, "ini_filename")
    #ret["database"] = config.get(SECTION, "database")
    ret["version"] = config.get(SECTION, "version")
    ret["installer_version"] = config.get(SECTION, "installer_version")
    ret["python"] = python_path()
    ret["proxy"] = config.get(SECTION, "proxy")
    ret["proxy_cert"] = config.get(SECTION, "proxy_cert")
    ret["sudo"] = sudo_cmd(ret["proxy"])
    ret["pip"] = pip_cmd(ret["venv_path"], ret["proxy"], ret["proxy_cert"])
    return ret, config

def save_config_variable(config, variable, value):
    """
    stores a variable with its value
    in a config parser object
    :returns: boolean about success
    """
    config.set("installer", variable, value)
    with open(CONFIG_FILE, 'wb') as configfile:
        config.write(configfile)
    return True

def noninteractive(key="", section="installer_input"):
    """
    :returns: a string of a key from an optional bootstrap.ini or ""
    """
    global OPTIONS
    ret = ""
    key = key.strip().lower()
    if OPTIONS.noninteractive is None:
        return ret
    ni_file = os.path.join(os.getcwd(), "data" , "noninteractive.ini")
    if not os.path.exists(ni_file):
        ni_file = os.path.join(os.getcwd(), "noninteractive.ini")
        if not os.path.exists(ni_file):
            log.info("file %s is not existing" % ni_file)
            return ret
    config = ConfigParser.ConfigParser()
    try:
        config.read(ni_file)
        ret = config.get(section, key)
        ret = ret.strip()
        log.debug("Sending non-interactive input key %s = %s" % (key, ret))
    except:
        pass
    return ret

def replace_line_in_file(abspath_file, old_line, new_line):
    """
    Parses a file and replaces every occurence of a line
    which starts with old_line with new_line

    :returns: boolean. False if file error or old_line not found
    """
    found = False
    if not os.path.exists(abspath_file):
        log.error("Could not replace line in file. File does not exist %s" % abspath_file)
        return False
    input_file = open(abspath_file)
    new_lines = []
    # open file and search & replace line
    for line in input_file:
        line = str(line).rstrip()
        if line.startswith(old_line):
            line = new_line
            log.debug("Found line to replace in file %s & replaced '%s' with '%s'" % (abspath_file, old_line, line))
            found = True
        new_lines.append(line)
    input_file.close()
    # update file just if line was found
    if len(new_lines) > 0 and found:
        output_file = open(abspath_file, "w")
        for line in new_lines:
            output_file.write(line+"\n")
        output_file.close()
    return found


def can_reach_internet(proxy=""):
    """
    Tries to call rhodecode.com/ping, optionally
    including proxy. Can be used to test proxy settings.
    Takes the config proxy settings if no direct
    proxy string is sent as argument

    and general internet connectivity
    """
    if not proxy:
        c, config = config_variables()
        proxy = c["proxy"]

    url = "https://rhodecode.com/ping"
    log.debug("Checking proxy & internet connection")
    resp = open_url(url, proxy)
    html = resp.read()
    json_resp = json.loads(html)
    if json_resp["txt"] == "pong":
        log.debug("Internet connection ok.")
        return True
    else:
        log.debug("Internet connection broken.")
        return False


def open_url(url, proxy=""):
    """
    Opens a URL,
    Handles proxy settings.
    Crashes on error for to log error output

    :returns: response object
    """
    if not proxy:
        c, config = config_variables()
        proxy = c["proxy"]

    log.debug("Trying to open %s ..." % url)
    # proxy or not?
    if len(proxy) > 3:
        proxy_handler = urllib2.ProxyHandler({'http': proxy, 'https': proxy})
        if "@" in proxy:
            log.debug("Using proxy with basic_auth credentials")
            password_mgr = urllib2.HTTPPasswordMgrWithDefaultRealm()
            # password_mgr.add_password(None, proxyurl, proxyuser, proxypass)
            password_mgr.find_user_password(None, proxy)
            proxy_auth_handler = urllib2.ProxyBasicAuthHandler(password_mgr)
            opener = urllib2.build_opener(proxy_handler, proxy_auth_handler)
        else:
            log.debug("Using proxy without credentials")
            opener = urllib2.build_opener(proxy_handler)
    else:
        opener = urllib2.build_opener()
    timeout = 5
    response = opener.open(url, None, timeout)
    return response


def ask_proxy(headline=""):
    """
    Asks the user for the proxy settings for installer.
    Free test http proxy server are here: http://spys.ru/free-proxy-list/
    select one and do at your CLI to set the ENV var:

    export http_proxy=http://foo:bar@212.184.30.221:3128

    Test it with a simple wget google.com and then use
    these credentials as proxy test here.

    :returns: the full proxy URL (user:pass@url:port) as string or "" on error
                  and the proxy_cert absolute path as string or "" if no certificate
    """
    clear()
    _print(HEADER)
    if headline == "":
        headline = "Currently I am supporting proxy servers with username:password authentication (called basic auth) and proxy servers without authentication.\n"
    _print(headline)


    # loop input until verification was successful
    test_loop = True
    while test_loop:

        proxy = ""
        proxy_cert = ""

        loop = True
        while loop:
            txt = "Do you need to connect through a proxy server with the Internet?\n[y]es\n[n]o\n> "
            ninp = noninteractive("use_proxy")
            inp = raw_input(txt).lower() if not ninp else ninp
            if inp == "q":
                quit()
            if inp == "n":
                return proxy, proxy_cert
            if inp == "y":
                loop = False

        # ask for host
        loop = True
        while loop:
            txt = "\nWhat is the IP or hostname of the proxy server?\n> "
            ninp = noninteractive("proxy_host")
            inp = raw_input(txt).lower() if not ninp else ninp
            if inp == "q":
                quit()
            if len(inp) > 1:
                loop = False
        proxy_host = inp
        # ask for port
        loop = True
        while loop:
            txt = "\nWhat is the port of the proxy server?\n> "
            ninp = noninteractive("proxy_port")
            inp = raw_input(txt).lower() if not ninp else ninp
            if inp == "q":
                quit()
            if len(inp) > 1 and int(inp) > 0:
                loop = False
        proxy_port = int(inp)

        user_auth = True
        loop = True
        while loop:
            txt = "\nDo you need to authenticate with a username and password?\n[y]es\n[n]o\n> "
            ninp = noninteractive("proxy_user_required")
            inp = raw_input(txt).lower() if not ninp else ninp
            if inp == "q":
                quit()
            if inp == "n":
                user_auth = False
                loop = False
            if inp == "y":
                user_auth = True
                loop = False

        if user_auth:
            # ask for user
            loop = True
            while loop:
                txt = "\nWhat is your username at the proxy server?\n> "
                ninp = noninteractive("proxy_user")
                inp = raw_input(txt) if not ninp else ninp
                if inp == "q":
                    quit()
                if len(inp) > 1:
                    loop = False
            proxy_user = inp
            # password
            loop = True
            while loop:
                txt = "\nWhat is the password of the user at the proxy server?\n> "
                ninp = noninteractive("proxy_password")
                inp = getpass.getpass(txt).strip() if not ninp else ninp
                if inp == "q":
                    quit()
                if len(inp) > 1:
                    loop = False
            proxy_pw1 = inp
            # password again
            loop = True
            while loop:
                txt = "\nPlease enter the same password again:\n> "
                ninp = noninteractive("proxy_password")
                inp = getpass.getpass(txt).strip() if not ninp else ninp
                if inp == "q":
                    quit()
                if inp == proxy_pw1:
                    loop = False
                else:
                    warning("The password does not match. Please try again.")
            proxy_pw = inp

        # ask for optional certificate
        use_ca = True
        loop = True
        while loop:
            txt = "\nDo you need to use a custom CA bundle?\n[y]es\n[n]o\n> "
            ninp = noninteractive("proxy_ca_bundle_required")
            inp = raw_input(txt).lower() if not ninp else ninp
            if inp == "q":
                quit()
            if inp == "n":
                use_ca = False
                loop = False
            if inp == "y":
                use_ca = True
                loop = False

        if use_ca:
            loop = True
            while loop:
                txt = "\nPlease enter the absolute path to your CA bundle.\n> "
                ninp = noninteractive("proxy_ca_bundle_path")
                inp = raw_input(txt).lower() if not ninp else ninp
                if inp == "q":
                    quit()
                if len(inp) > 0:
                    if not os.path.isfile(inp):
                        warning("The file %s does not exist. Please try again." % inp)
                    else:
                        loop = False
                else:
                    loop = False
            proxy_cert = inp.strip()

        if user_auth:
            proxy = "%s:%s@%s:%s" % (proxy_user, proxy_pw, proxy_host, proxy_port)
        else:
            proxy = "%s:%s" % (proxy_host, proxy_port)

        # verify proxy settings
        _print("\nTesting internet connection ...")
        try:
            online = can_reach_internet(proxy)
        except:
            log.exception('')
            online = False
        if not online:
            warning("\nI could not connect to rhodecode.com using these proxy settings.\nPlease enter them again or contact us if the error still occurs.\n")
        else:
            test_loop = False

    return proxy, proxy_cert


def ask_database(data_path, headline=""):
    """
    asks the user for the database settings

    :returns: the full database URL as string
    """
    clear()
    _print(HEADER)
    if headline:
        _print(headline)

    database = ""
    database_url = ""
    # ask for existing database
    loop = True
    while loop:
        txt = "What database do you use?\n[s]qlite (built-in, no server needed)\n[m]ysql\n[p]ostgresql\n> "
        ninp = noninteractive("database_type")
        inp = raw_input(txt).lower() if not ninp else ninp
        if inp == "q":
            quit()
        if inp == "":
            _print("I am using the default: sqlite")
            loop = False
        if inp == "s":
            database = "sqlite"
            database_url = "sqlite:///%s/rhodecode.db?timeout=60" % data_path
            loop = False
        if inp == "m":
            database = "mysql"
            loop = False
        if inp == "p":
            database = "postgresql"
            loop = False

    # ask for the db credentials if not sqlite
    if database_url == "":
        # host
        loop = True
        while loop:
            txt = "\nWhat is the IP or hostname of the database server?\n> "
            ninp = noninteractive("database_host")
            inp = raw_input(txt).lower() if not ninp else ninp
            if inp == "q":
                quit()
            if len(inp) > 3:
                loop = False
        db_host = inp
        # port
        loop = True
        while loop:
            txt = "\nWhat is the port of the database server?\n> "
            ninp = noninteractive("database_port")
            inp = raw_input(txt).lower() if not ninp else ninp
            if inp == "q":
                quit()
            if len(inp) > 1 and int(inp) > 0:
                loop = False
        db_port = int(inp)
        # user
        loop = True
        while loop:
            txt = "\nWhat is the user at the database server?\n> "
            ninp = noninteractive("database_user")
            inp = raw_input(txt) if not ninp else ninp
            if inp == "q":
                quit()
            if len(inp) > 1:
                loop = False
        db_user = inp
        # password
        loop = True
        while loop:
            txt = "\nWhat is the password of the user at the database server?\n> "
            ninp = noninteractive("database_password")
            inp = getpass.getpass(txt).strip() if not ninp else ninp
            if inp == "q":
                quit()
            if len(inp) > 1:
                loop = False
        db_pw1 = inp
        # password again
        loop = True
        while loop:
            txt = "\nPlease enter the same password again:\n> "
            ninp = noninteractive("database_password")
            inp = getpass.getpass(txt).strip() if not ninp else ninp
            if inp == "q":
                quit()
            if inp == db_pw1:
                loop = False
            else:
                warning("The password does not match. Please try again.")
        db_pw = inp
        # database
        loop = True
        while loop:
            txt = "\nWhat is the database name at the database server (default is rhodecode)?\n> "
            ninp = noninteractive("database_name")
            inp = raw_input(txt) if not ninp else ninp
            if inp == "q":
                quit()
            if inp == "":
                db_name = "rhodecode"
                loop = False
            if len(inp) > 1:
                loop = False
                db_name = inp
        # assemble database_url in the format postgresql://user:pass@localhost/rhodecode
        database_url = "%s://%s:%s@%s:%s/%s" % (database, db_user, db_pw, db_host, db_port, db_name)
    return database_url

def create_bat_files():
    """
    after installation/upgrade under windows a new set
    of .bat files is created in current folder

    :returns: boolean about success
    """
    global PLATFORM
    if not "windows" in PLATFORM:
        return False
    c, config = config_variables()
    # start-server.bat shows Paster serve command
    start_bat = os.path.join(os.getcwd(), "start-server.bat")
    f = open(start_bat, "w")
    cmd = '"%s" serve "%s"' % (os.path.join(c["system_path"], "Scripts", "paster"),
                                            os.path.join(c["data_path"], c["ini_filename"]))
    f.write(cmd)
    f.close()
    """
    # install_service.bat installs the .bat file as a service!
    # can be debugged with 'eventvwr' command on Windows prompts
    #
    # the hack with the VBS script works from: http://bit.ly/1bIucni
    #
    f = open(os.path.join(os.getcwd(), "install-service.bat"), "w")
    paster_cmd = '"%s" serve --daemon "%s"' % (os.path.join(c["system_path"], "Scripts", "paster"),
                                            os.path.join(c["data_path"], c["ini_filename"]))
    cmd='sc.exe create rhodecode3 start= auto DisplayName= "RhodeCode Enterprise3" binPath= "%s"' % paster_cmd
    f.write(cmd)
    f.close()
    """
    return True


def git_is_too_old():
    """
    Checks if Git is too old or maybe even not existing.
    :returns: boolean, True if upgrade/install is necessary
    """
    # get current Git path
    git_path = "git"
    if os.path.exists("/usr/bin/git"):  # often older
        git_path = "/usr/bin/git"
    if os.path.exists("/usr/local/bin/git"):  # often newer
        git_path = "/usr/local/bin/git"

    cmd = su("%s --version" % git_path)
    out, err = run(cmd, False)
    # a typical output is: "git version 1.7.1"
    if "git version" in out and "." in out:
        version = out.replace("git version", "")
        version = str(version.split()[0]) # removes newlines, tabs and spaces
        parts = version.split(".")
        # extract the numbers of the version string
        try:
            num1 = int(parts[0])
            num2 = int(parts[1])
            num3 = int(parts[2])
            if num1 < 2 and num2 < 8 and num3 < 4:
                log.debug("Git version %s is too old" % version)
                return True
            else:
                log.debug("Git version %s is ok" % version)
                return False
        except:
            log.exception('')
            log.error("could not parse Git version '%s' " % version)
    return True


def install_new_git_on_linux():
    """
    Tries to install/upgrade to Git  1.7.4 or newer.
    Just works under for Linux

    :returns: boolean about success
    """
    global PLATFORM
    c, config = config_variables()
    # ignore windows
    if "windows" in PLATFORM:
        return True

    # install required packages to manually build Git
    cmds = []
    if "ubuntu" in PLATFORM or "debian" in PLATFORM or "mint" in PLATFORM:
        cmds = ["apt-get install build-essential libcurl4-gnutls-dev libexpat1-dev gettext libz-dev libssl-dev perl-modules -y"]
    elif "fedora" in PLATFORM or "redhat" in PLATFORM or "centos" in PLATFORM or "amzn1" in PLATFORM:
        cmds = ["yum install make automake gcc gcc-c++ curl-devel expat-devel gettext-devel openssl-devel zlib-devel perl-ExtUtils-MakeMaker -y"]
    else:
        log.warning("Could not upgrade old Git version due to unsupported platform")
        return False

    if len(cmds) > 0:
        _print("Please wait, I am upgrading Git. This may take up to 15 minutes ...")
        for cmd in cmds:
            out, err = run("%s%s" % (sudo_cmd(), cmd), False)
        # download and build Git
        dl_url = "https://rhodecode.com/dl/git-1.8.4.4.tar.gz"
        downloaded = download_file(dl_url, "/tmp/git-1.8.4.4.tar.gz", binary=True)
        if not downloaded:
            warning("I could not download the Git upgrade.")
            return False
        out, err = run(su("cd /tmp && tar -zxf /tmp/git-1.8.4.4.tar.gz"))
        out, err = run(su("cd /tmp/git-1.8.4.4 && make prefix=/usr/local all"))
        out, err = run("cd /tmp/git-1.8.4.4 && %smake prefix=/usr/local install" % sudo_cmd())
        # check if git is new now
        if git_is_too_old():
            warning("I could not upgrade Git. Please do it manually.")
            return False
        else:
            log.info("Upgraded Git to version 1.8.4.4")
            # try to store optionally new absolute path in production.ini
            git_path = "/usr/local/bin/git"
            replace_line_in_file(os.path.join(c["data_path"], c["ini_filename"]), "git_path", "git_path = %s" % git_path)
            return True
    return False


def install_prebuilt_windows(action="install", app=0):
    """
    Connects to RhodeCode server and downloads a prebuilt
    package and optionally unzips it. Can be a system folder
    or an installer.exe

    Parameters:
    - action (str): "install", or "upgrade"
    - app (int): 0 for enterprise, 1 for installer

    :returns: boolean about success
    """
    global PLATFORM
    c, config = config_variables()
    dl_url = ""
    url_dict = {}
    # get current version
    if app == 0:
        url_dict["current_version"] = c["version"]
    elif app == 1:
        url_dict["current_version"] = c["installer_version"]
    release = 0
    to_dir = os.getcwd()

    dl_url = get_download_link(action, app)
    # download file to temp folder
    _print("Please wait, I am downloading ...")
    if os.path.basename(dl_url) == "win_ri_latest.exe":
        fname ="rhodecode-installer.exe"
    else:
        fname = os.path.basename(dl_url)
    tmp_file = os.path.join(tempfile.gettempdir(), fname)
    download_file(dl_url, tmp_file, binary=True)
    # unzip file
    if tmp_file.endswith(".zip"):
        _print("Please wait, I am unzipping the download ...")
        log.debug("Trying to unzip %s ..." % tmp_file)
        zf = zipfile.ZipFile(tmp_file)
        zf.extractall(os.getcwd())
        try:
            os.remove(tmp_file)
        except:
            pass
        log.debug("Unzip to %s was succesful" % to_dir)
    else:
        _print("Please wait, I am copying the download to the correct folder ...")
        if os.path.isdir(tmp_file):
            target_dir = os.path.join(to_dir, os.path.basename(tmp_file))
            log.debug("Copying folder %s to %s ..." % (tmp_file, target_dir))
            copy_folder(tmp_file, target_dir)
            try:
                shutil.rmtree(tmp_file)
            except:
                pass
        else:
            log.debug("Copying file %s to %s ..." % (tmp_file, to_dir))
            if "windows" in PLATFORM:
                cmd = 'copy /Y "%s" "%s"' % (tmp_file, to_dir)
            else:
                cmd = su("cp -f %s %s" % (tmp_file, to_dir))
            out, err = run(cmd, False)
            try:
                os.remove(tmp_file)
            except:
                pass
        log.debug("Copy of download was successful")
    return True

def install_wheels(action="install", app=0):
    """
    Connects to RhodeCode server and downloads a zipped
    wheels folder, unzips it to temp and installs it using pip

    Parameters:
    - action (str): "install", or "upgrade"
    - app (int): 0 for enterprise, 1 for installer

    :returns: boolean about success
    """
    global PLATFORM
    c, config = config_variables()

    # install / upgrade wheels via pip
    cmd = su("%s wheel" % c["pip"])
    out, err = run(cmd, False)

    # get current version
    dl_url = ""
    url_dict = {}
    if app == 0:
        url_dict["current_version"] = c["version"]
    elif app == 1:
        url_dict["current_version"] = c["installer_version"]
    release = 0  # hard-wired to stable for now!
    dl_url = get_download_link(action, app)
    # download file to temp folder
    _print("Please wait, I am downloading ...")
    fname = os.path.basename(dl_url)
    tmp_file = os.path.join(tempfile.gettempdir(), fname)
    download_file(dl_url, tmp_file, binary=True)

    # unzip file
    if tmp_file.endswith(".zip"):
        to_dir = tmp_file.replace(".zip", "")
        _print("Please wait, I am unzipping the download ...")
        log.debug("Trying to unzip %s ..." % tmp_file)
        zf = zipfile.ZipFile(tmp_file)
        zf.extractall(tempfile.gettempdir())
        """
        try:
            os.remove(tmp_file)
        except:
            pass
        """
        log.debug("Unzip to %s was succesful" % to_dir)
    else:
        to_dir = tempfile.gettempdir()

    _print("Please wait, I am installing ...")
    #pip = c["pip"].replace(" install -I"
    cmd = su("%s --use-wheel --no-index --find-links=%s rhodecode psycopg2 MySQL-python python-ldap rhodecode-tools" % (c["pip"], to_dir))
    out, err = run(cmd, False)
    return True


def create_virtualenv():
    """
    Connects to RhodeCode server and downloads a
    zipped virtualenv file and unzips it in the main folder.
    Then virtualenv.py is used to create the virtualenv

    :returns: boolean about success
    """
    global PLATFORM
    c, config = config_variables()
    dl_url = get_download_link("install", 5)
    # download file to temp folder
    _print("Please wait, I am downloading ...")
    to_dir = os.getcwd()
    fname = os.path.basename(dl_url)
    tmp_file = os.path.join(os.getcwd(), fname)
    download_file(dl_url, tmp_file, binary=True)
    # unzip file
    if tmp_file.endswith(".zip"):
        _print("Please wait, I am unzipping the download ...")
        log.debug("Trying to unzip %s ..." % tmp_file)
        zf = zipfile.ZipFile(tmp_file)
        zf.extractall(to_dir)
        log.debug("Unzip to %s was succesful" % to_dir)
    # create virtualenv <- TODO: this may fail on an upgrade?!
    venvpy_path = os.path.join(os.getcwd(), fname.replace(".zip", ""), "virtualenv.py")
    cmd = su("%s %s --no-site-packages %s" % (c["python"], venvpy_path, c["system_path"]))
    out, err = run(cmd, False)
    # delete unzipped files and folders
    try:
        os.remove(tmp_file)
    except:
        pass
    try:
        if os.path.isdir(tmp_file.replace(".zip", "")):
            shutil.rmtree(tmp_file.replace(".zip", ""))
    except:
        pass
    try:
        if os.path.isdir(os.path.join(os.getcwd(), "__MACOSX")):
            shutil.rmtree(os.path.join(os.getcwd(), "__MACOSX"))
    except:
        pass
    return True

def install_or_upgrade_tools(dev=False):
    """
    Downloads and installs / upgrades RhodeCode Tools
    Necessary before every install/download of RhodeCode
    Gets the config array as argument
    """
    global PLATFORM
    c, config = config_variables()
    _print("\nPlease wait, I am downloading & installing more dependencies. This may take up to 5 minutes ...")
    dl_url = get_download_link("upgrade", 2)
    cmd = su("%s %s" % (c["pip"], dl_url))
    out, err = run(cmd, False)
    if err != "":
        error("Installation error!","Sorry, I could not install the tools.")
        return False
    if "windows" in PLATFORM:
        # manually copy dependencies from global site-packages to rhodecode-venv folder
        # you can test success by running a Python shell with "import MySQLdb, psycopg2, ldap"
        _print("\nPlease wait, I am copying dependencies to the correct folder ...")
        import site
        package_paths = site.getsitepackages()
        for src_path in package_paths:
            if "\\python27\\lib\\site-packages" in src_path.lower():
                folders = ["MySQLdb", "MySQL_python-1.2.4-py2.7.egg-info",
                                "psycopg2", "ldap","python_ldap-2.4.13-py2.7.egg-info"]
                files = ["_ldap*", "ldap*", "_mysql*", "psycopg2*"]
                for f in folders:
                    cmd = "xcopy /Y /H /E /C /I %s\\%s %s\\Lib\\site-packages\\%s" % (src_path, f, c["system_path"], f)
                    out, err = run(cmd, False)
                for f in files:
                    cmd = "copy /Y %s\\%s %s\\Lib\\site-packages" % (src_path, f, c["system_path"])
                    out, err = run(cmd, False)
    else:
        create_tools_symlinks()
        # (re)install Pip modules for mysql and postgres
        cmd = su("%s psycopg2 MySQL-python" % c["pip"])
        out, err = run(cmd, False)
        # (re)install Pip module for LDAP
        cmd = su("%s python-ldap" % c["pip"])
        out, err = run(cmd, False)

def create_tools_symlinks():
    """
    creates symlinks pointing to tools scripts
    """
    c, config = config_variables()
    # set symlinks to /usr/local/bin or /usr/bin
    if os.path.exists("/usr/local/bin"):
        bin_folder = "/usr/local/bin"
    elif os.path.exists("/usr/bin"):
        bin_folder = "/usr/bin"
    else:
        bin_folder = ""
    if bin_folder != "":
        tool_files = ["%s/bin/rhodecode-api" % c["system_path"],
                            "%s/bin/rhodecode-config" % c["system_path"],
                            "%s/bin/rhodecode-gist" % c["system_path"],
                            "%s/bin/rhodecode-extensions" % c["system_path"]]
        for tool_file in tool_files:
            if os.path.isfile(tool_file):
                cmd = "cd %s && %sln -s %s"% (bin_folder, c["sudo"], tool_file)
                out, err = run(cmd, False)

def install(no_setup=False, headline=""):
    """
    Installs RhodeCode Enterprise
    The folders are always already existing because the installer
    checks that before doing install
    """
    global PLATFORM, BUILD
    clear()
    _print(HEADER)
    c, config = config_variables()

    clear()
    _print(HEADER)
    if headline:
        warning(headline)

    # download pre-built system folder, no deps required
    if "windows" in PLATFORM and BUILD == False:
        _print("I am starting the installation of RhodeCode Enterprise ...")
        install_prebuilt_windows("install", 0)
    # install deps, do pip and virtualenv stuff
    else:
        if not "windows" in PLATFORM:
            cmds = python_install_cmds()
            if len(cmds) == 0:
                error("Installation error!","Sorry, I could not find the necessary packages for your operating system.")
                return False
            _print("Please wait, I am downloading & installing the dependencies. This may take up to 5 minutes ...")
            for cmd in cmds:
                out, err = run("%s%s" % (c["sudo"], cmd))
            success("I installed the dependencies.")
            if git_is_too_old():
                install_new_git_on_linux()

        if not create_virtualenv():
            return False

        # manually download and build/compile with pip
        if BUILD:
            # download & install RhodeCode Enterprise
            # it tries it several times because an error with some dependencies does often occur
            # which requires a retry
            attempts = 0
            max_attempts = 4
            while attempts < max_attempts:
                attempts = attempts + 1
                _print("Please wait, I am downloading & installing RhodeCode Enterprise. This may take up to 15 minutes ...")
                dl_url = get_download_link("install", 0)
                cmd = su("%s %s" % (c["pip"], dl_url))
                out, err = run(cmd, False)
                if err == "" and get_installed_version() != "":
                    attempts = max_attempts + 1
            if err != "":
                error("Installation error!","Sorry, I could not install RhodeCode Enterprise. "
                        "\nThe following error occured:\n%s" % (err))
                return False
            # install setup tools
            install_or_upgrade_tools()

        # download wheels and install it with pip
        else:
            install_wheels("install", 0)
            # an issue occured with wheels, run installation in build mode
            if not get_installed_version():
                BUILD = True
                log.debug("Restarting installation in build mode due to installation issue")
                install(headline="An issue occured during installation. I am restarting the installation "
                    "and manually compile all dependencies for a better compatibility. "
                    "Thank you for your patience!\n")
                return False
            create_tools_symlinks()

    if no_setup:
        return True

    ####
    # create ini file (for pre-built and built ones)
    _print("Please wait, I am creating the configuration files ...")
    cmd = su('cd %s && "%s/bin/rhodecode-config" --raw --filename=template.ini.mako && "%s/bin/rhodecode-config" --template=template.ini.mako --filename=%s host=\'0.0.0.0\',port=5000' %
                (c["data_path"], c["system_path"], c["system_path"], c["ini_filename"]))
    if "windows" in PLATFORM:
        cmd = cmd.replace("/bin/", "/Scripts/")
        cmd = cmd.replace("/", "\\")
    out, err = run(cmd, False)

    # store the new version
    v = get_installed_version()
    save_config_variable(config, "version", str(v))
    success("I successfully installed RhodeCode Enterprise for you. Starting setup now ...")
    time.sleep(4)
    setup()


def setup(auto_started=False):
    """
    is called after the installation was successful.
    Is doing all setup work.
    """
    global PLATFORM, BUILD
    c, config = config_variables()

    clear()
    _print(HEADER)
    _print("Now I want to run the initial setup and create the first RhodeCode Enterprise user. "
             "The user will get administrator rights. For that I need to ask you the email, username "
             "and password for that user account. "
             "Please do not enter spaces to avoid issues.")

    # ask for email
    loop = True
    while loop:
        txt = "\nPlease enter the email address:\n> "
        ninp = noninteractive("admin_email")
        inp = raw_input(txt).lower() if not ninp else ninp
        if inp == "q":
            quit()
        elif len(inp) > 6 and "@" in inp and "." in inp:
            loop = False
        else:
            warning("The email address seems invalid. Please try another one.")
    RCE_EMAIL = inp

    # ask for username
    loop = True
    while loop:
        txt = "\nPlease enter the username:\n> "
        ninp = noninteractive("admin_user")
        inp = raw_input(txt).lower() if not ninp else ninp
        if inp == "q":
            quit()
        if len(inp) > 1:
            loop = False
    RCE_USER = inp

    # ask for password
    loop = True
    while loop:
        txt = "\nPlease enter a password for the user:\n> "
        ninp = noninteractive("admin_user_password")
        inp = getpass.getpass(txt).strip() if not ninp else ninp
        if inp == "q":
            quit()
        elif len(inp) > 5:
            loop = False
        else:
            warning("The password must consist of at least 6 characters.")
    RCE_PW = inp

    # ask for password again
    loop = True
    while loop:
        txt = "\nPlease enter the same password again:\n> "
        ninp = noninteractive("admin_user_password")
        inp = getpass.getpass(txt).strip() if not ninp else ninp
        if inp == "q":
            quit()
        if inp == RCE_PW:
            loop = False
        else:
            warning("The password does not match. Please try again.")

    # ask for existing database
    headline = "I need to store that admin user in a database. Important: For MySQL and PostgreSQL the database must already exist! For SQLite everything is automatically created.\n"
    database = ask_database(c["data_path"], headline)
    #save_config_variable(config, "database", database)
    #c["database"] = database

    # save the new database value in production.ini
    cmd1 = 'cd %s && "%s/bin/rhodecode-config" --update --filename=%s' % (c["data_path"], c["system_path"], c["ini_filename"])
    if "windows" in PLATFORM:
        cmd1 = cmd1.replace("/bin/", "/Scripts/")
        cmd1 = cmd1.replace("/", "\\")
    # keep / even on windows!
    cmd2 = '%s "[app:main]sqlalchemy.db1.url=%s" ' % (cmd1, database)
    cmd = su(cmd2)
    out, err = run(cmd, False)

    # if an error occured with the database then the installation
    # is restarted in build mode
    if err != "" and not BUILD and not "windows" in PLATFORM:
        BUILD = True
        log.debug("Restarting installation in build mode due to installation issue")
        install(headline="An issue occured during database setup. I am restarting the installation "
            "and manually compile all dependencies for a better compatibility. "
            "Thank you for your patience!\n")
        return False

    if err != "":
        error("Setup error!","Sorry, I could not setup the database. Please check your credentials and try again.")
        return False

    clear()
    _print(HEADER)
    _print("Now I need to store all data in the database to finish the setup.")
    # create user through paster
    _print("\nPlease wait, I am creating the admin user and run the initial database setup ...")
    cmd2 = 'paster" setup-rhodecode %s --user="%s" --password="%s" --email="%s" --repos="%s" --force-yes' % (c["ini_filename"], escape_for_shell(RCE_USER), escape_for_shell(RCE_PW), escape_for_shell(RCE_EMAIL), c["repo_path"])
    cmd = su('cd %s && "%s/bin/%s' % (c["data_path"], c["system_path"], cmd2))
    if "windows" in PLATFORM:
        cmd = cmd.replace("/bin/", "/Scripts/")
        cmd = cmd.replace("/", "\\")
    out, err = run(cmd, False)

    # if an error occured with the database then the installation
    # is restarted in build mode
    if err != "" and not BUILD and not "windows" in PLATFORM:
        BUILD = True
        log.debug("Restarting installation in build mode due to installation issue")
        install(headline="An issue occured during database setup. I am restarting the installation "
            "and this time I will manually compile all dependencies for a better compatibility. "
            "Thank you for your patience!\n")
        return False

    if err != "":
        error("Setup error!","Sorry, I could not setup the database. Please check your credentials and try again.")
        return False

    if auto_started:
        save_config_variable(config, "autostart_setup", "")
    dl_url = get_download_link("install", 0, True)

    # install init.d script under Linux
    if "windows" in PLATFORM:
        installed = False
    else:
        service_file = "/etc/init.d/rhodecode"
        if os.path.isfile("/etc/arch-release"):
            service_file = "/etc/conf.d/rhodecode"
        headline = "I try to install the service to %s ..." % service_file
        installed = install_initd(headline)  # if True then it shows a basic_menu for itself
    if not installed:
        clear()
        _print(HEADER)
        if "windows" in PLATFORM:
            success("Congratulations, your RhodeCode Enterprise server setup is complete!\nTo start the server please double-click the file start-server.bat from your RhodeCode folder. \nWhen the server is running please open your browser, go to http://127.0.0.1:5000 and log-in with the username and password you entered some seconds ago.")
        else:
            success("Congratulations, your RhodeCode Enterprise setup is complete!\nYou can now run it by following the details described at point 2 of the main menu.")
        create_bat_files()
        basic_menu()

def start():
    """
    prints the start command for an existing
    RhodeCode Enterprise installation as a single-thread.
    """
    clear()
    _print(HEADER)

    c, config = config_variables()

    if len(c["version"]) < 3:
        error("RhodeCode is missing!","Sorry, it seems RhodeCode Enterprise is not properly installed."
        "\nPlease install it again.")
        return False
    # check if user has app installed, the folders exist, etc.
    if not os.path.exists(c["repo_path"]):
        error("Missing folder!","Sorry, I could not run the app because the folder %s does not exist."
        "\nPlease install RhodeCode Enterprise again." % c["repo_path"])
        return False
    if not os.path.exists(c["data_path"]):
        error("Missing folder!","Sorry, I could not run the app because the folder %s does not exist."
        "\nPlease install RhodeCode Enterprise again." % c["data_path"])
        return False
    if not os.path.exists(c["system_path"]):
        error("Missing folder!","Sorry, I could not run the app because the folder %s does not exist."
        "\nPlease install RhodeCode Enterprise again." % c["system_path"])
        return False

    service_file = "/etc/init.d/rhodecode"
    if os.path.isfile("/etc/arch-release"):
        service_file = "/etc/conf.d/rhodecode"

    if os.path.isfile(service_file):
        _print("You have the service for RhodeCode Enterprise installed.")
        _print("\nYou can start, stop, restart and get the status with: ")
        _print("%s%s%s {start|stop|restart|status}%s" % (GREEN, c["sudo"], service_file, RESET))
        txt = "\nAfter starting the service, please open your browser and point it to port 5000 of your server IP to log in. If the connection fails: please open port 5000 in your firewall or temporarily deactivate the firewall with 'sudo service iptables stop' as a quick test. Also maybe have a look at your service log with the command 'tail -f /var/log/rhodecode/rhodecode.log'"
        _print(txt)
    else:  # service not installed
        cmd2 = su('"%s/bin/paster" serve "%s/%s"' % (c["system_path"], c["data_path"], c["ini_filename"]))
        if "windows" in PLATFORM:
            txt="To start the server please double-click on the file start-server.bat from your RhodeCode folder.\nWhen the server is running please open your browser, go to http://127.0.0.1:5000 and log-in with the username and password you entered some seconds ago.\n"
            _print(txt)
        else:
            _print("Please open a new terminal window and copy & paste the following command to start the RhodeCode Enterprise server:\n")
            _print(GREEN+cmd2+RESET)
            txt = "\nNow open your browser and point it to port 5000 of your server IP to log in. If the connection fails: please open port 5000 in your firewall or temporarily deactivate the firewall with 'sudo service iptables stop' as a quick test.\nPress CTRL+C in the other terminal window to stop the server."
            _print(txt)
    basic_menu()


def get_installed_version(system_path="", user=""):
    """
    Checks the installed version.
    Can be used to verify if RCE is actually downloaded & installed!

    :returns: the currently installed version as string like "2.1.0"
                  or an empty string on error
    """
    c = {}
    # do not use config_variables if system_path is set
    if system_path != "":
        c["system_path"] = system_path
        c["python"] = python_path()
    else:
        c, config = config_variables()
    cmd = su('"%s/bin/%s" -c \"import rhodecode;print rhodecode.__version__\"' % (c["system_path"], c["python"]), user)
    if "windows" in PLATFORM:
        cmd = cmd.replace("/bin/", "/Scripts/")
        cmd = cmd.replace("/", "\\")
    out, err = run(cmd, False)
    if err != "":
        return ""
    else:
        if len(out) > 1:
            return str(out.split()[0])  # removes newlines, tabs and spaces
    return ""

def download_file(url="", target_file="", binary=False):
    """
    Downloads a file from a remote server.
    Works under Windows and Linux

    :returns boolean about success
    """
    mode = "w"
    if binary:
        mode = "wb"
    log.debug("Trying to download %s to %s" % (url, target_file))
    resp = open_url(url)
    try:
        with open(target_file, mode) as f: f.write(resp.read())
    except:
        log.exception('')
        error("File error!","Sorry, I could not write to the file %s" % target_file, False)
    log.debug("Download was successful.")
    return True

def get_download_link(action="install", app=0, finished=False):
    """
    Connects to RhodeCode server and fetches the correct download URL

    Parameters:
    - action (str): "install", or "upgrade"
    - app (int): 0 for enterprise, 1 for installer, 2 for tools
    - finished (boolean): True if process was successful, False if retry necessary

    :returns: url as string or "" on error
    """
    global PLATFORM, BUILD
    c, config = config_variables()
    dl_url = ""
    url_dict = {}
    # get current version
    if app == 0:
        url_dict["current_version"] = c["version"]
    elif app == 1:
        url_dict["current_version"] = c["installer_version"]
    else:
        url_dict["current_version"] = "latest"
    url_dict["installer_version"] = c["installer_version"]
    url_dict["platform"] = PLATFORM
    release = 0
    if BUILD == False:
        url_dict["built"] = 1
    url_dict["finished"] = "n"
    if finished:
        url_dict["finished"] = "y"

    get_params = urllib.urlencode(url_dict, True)
    url = "https://rhodecode.com/dl/link/%s/%s/%s?%s" % (action, app, release, get_params)

    resp = open_url(url)
    html = resp.read()

    if html > "":
        # convert response from json
        try:
            json_resp = json.loads(html)
            dl_url = json_resp["url"]
        except:
            log.exception('')
            dl_url = ""
            error("Connection error!","Sorry, I could not read the download URL from the response of the "
                    "RhodeCode server. \nPlease try again in 15 minutes or contact us.", False)
    return dl_url

def get_versions(current_version=""):
    """
    Connects to the versions server endpoint and
    fetches a list of versions datasets. Format is JSON
    and the first element is the latest version.

    return example:
    versions[0] # the latest version dataset
    convert_version_to_int(versions[0]["version"]) # the int version
    versions[0]["version"] # the latest version number (like 2.1.0)

    :returns: a json list or an empty list on error
    """
    c, config = config_variables()
    url = "https://rhodecode.com/api/v1/info/versions"

    resp = open_url(url)
    html = resp.read()

    if not '"versions":' in html or not "release_date" in html:
        error("Connection error!","Sorry, I could not get the list of versions from rhodecode.com."
                "\nPlease check your internet connection and try again or contact us.")
        return False
    # convert from json
    try:
        json_resp = json.loads(html)
        versions = json_resp["versions"]
    except:
        log.exception('')
        versions = []
    return versions


def can_upgrade(local_version_int=0, dev=False):
    """
    checks if a new RhodeCode Enterprise version
    is existing and if an upgrade is possible.

    local_version_int can be used to override the local
    version to test the upgrade mechanism. Leave at 0
    to use the real local version
    if dev == True then the latest dev version is installed
    """
    clear()
    _print(HEADER)

    c, config = config_variables()

    if len(c["version"]) < 3:
        error("RhodeCode is missing!","Sorry, it seems RhodeCode Enterprise is not properly installed."
            "\nPlease install it before checking for updates.")
        return False

    # get the version list
    versions = []
    latest_version = []

    versions = get_versions(c["version"])
    latest_version = versions[0]

    if len(versions) < 1 or not "general" in latest_version or not "version" in latest_version:
        error("Data error!","Sorry, I could not find the latest version data."
                "\nPlease check your internet connection and try again or contact us.")
        return False

    if local_version_int == 0:
        local_version_int = convert_version_to_int(c["version"])
    latest_version_int = convert_version_to_int(latest_version["version"])

    # it can be that local version is newer than latest online version (during dev!)
    if local_version_int >= latest_version_int and not dev:
        success("Great, RhodeCode Enterprise is already the latest version!")
        basic_menu()
        return True

    if not dev:
        # upgrade instructions
        _print("%sThere is a new RhodeCode Enterprise version %s!\n%s" % (BOLD, latest_version["version"], RESET))
        if len(latest_version["general"]) > 0:
            _print("What is new in the version?")
            for txt in latest_version["general"]:
                print ("- %s " % txt)

    do_upgrade = False
    loop = True

    while loop:
        txt = "\nCan I start the upgrade for you? I will backup all settings.\n[y]es\n[n]o\n> "
        ninp = noninteractive("start_upgrade")
        inp = raw_input(txt).lower() if not ninp else ninp
        if inp == "q":
            quit()
        if inp == "n":
            loop = False
        if inp == "y":
            do_upgrade = True
            loop = False
    if do_upgrade:
        upgrade(latest_version, dev)

def upgrade(latest_version, dev=False, headline=""):
    """
    Upgrade RhodeCode Enterprise, gets the
    dict of the new version as argument.
    if dev == True then the latest dev version is installed
    """
    global PLATFORM, BUILD
    clear()
    _print(HEADER)
    if headline:
        warning(headline)

    c, config = config_variables()
    VERSION_INT = convert_version_to_int(c["version"])
    NEW_VERSION = convert_version_to_int(latest_version["version"])
    _print("I am starting the upgrade to the latest stable version of RhodeCode Enterprise.")

    # stop service if running
    service_file = "/etc/init.d/rhodecode"
    if os.path.isfile("/etc/arch-release"):
        service_file = "/etc/conf.d/rhodecode"
    service_was_running = False
    if service_is_running():
        service_was_running = True
        _print("I am trying to stop the running service ...")
        cmd = "%s%s stop" % (c["sudo"], service_file)
        out, err = run(cmd, False)

    # backup production.ini
    _print("\nI am creating a backup of your configuration ...")
    cmd = su('cp "%s/%s" "%s/%s.%s"' % (c["data_path"], c["ini_filename"], c["data_path"], c["ini_filename"], c["version"]))
    if "windows" in PLATFORM:
        cmd = cmd.replace("/", "\\")
        cmd = cmd.replace("cp ", "copy ")
    out, err = run(cmd, False)
    if err != "":
        error("Backup error!","Sorry, I could not backup your configuration file. "
                "\nThe following error occured:\n%s" % (err))
        return False

    if git_is_too_old():
        install_new_git_on_linux()

    # download pre-built system folder, no deps required
    if "windows" in PLATFORM and BUILD == False:
        _print("\nI am starting the upgrade of RhodeCode Enterprise ...")
        install_prebuilt_windows("upgrade", 0)
    # install deps, do pip and virtualenv stuff
    else:
        create_virtualenv()

        # manually download and build/compile with pip
        if BUILD:
            # download & upgrade RhodeCode Enterprise
            # it tries it several times because an error with some dependencies does often occur
            # which requires a retry
            attempts = 0
            max_attempts = 4
            while attempts < max_attempts:
                attempts = attempts + 1
                if dev:
                    _print("\nPlease wait, I am downloading & installing the latest development version of RhodeCode Enterprise. "
                            "This may take up to 15 minutes ...")
                else:
                    _print("\nPlease wait, I am downloading & installing the new RhodeCode Enterprise version. "
                            "This may take up to 15 minutes ...")
                dl_url = get_download_link("upgrade", 0)
                cmd = su("%s %s" % (c["pip"], dl_url))
                out, err = run(cmd, False)
                if err == "" and get_installed_version() != "":
                    attempts = max_attempts + 1
            if err != "":
                error("Installation error!","Sorry, I could not install the new RhodeCode Enterprise version. "
                        "\nThe following error occured:\n%s" % (err))
                return False
            # install setup tools
            install_or_upgrade_tools(dev)
        else:
            install_wheels("upgrade", 0)
            # an issue occured with wheels, run installation in build mode
            if not get_installed_version():
                BUILD = True
                log.debug("Restarting upgrade in build mode due to upgrade issue")
                upgrade(latest_version=latest_version,
                    headline="An issue occured during the upgrade. I am restarting the upgrade "
                    "and manually compile all dependencies for a better compatibility. "
                    "Thank you for your patience!\n")
                return False
            create_tools_symlinks()

    ####
    # upgrade database
    _print("\nPlease wait, I am upgrading the database ...")
    cmd2 = 'paster" upgrade-db %s --force-yes' % c["ini_filename"]
    cmd = su('cd "%s" && "%s/bin/%s' % (c["data_path"], c["system_path"], cmd2))
    if "windows" in PLATFORM:
        cmd = cmd.replace("/bin/", "/Scripts/")
        cmd = cmd.replace("/", "\\")
    out, err = run(cmd, False)

    if err != "" and not BUILD and not "windows" in PLATFORM:
        BUILD = True
        log.debug("Restarting upgrade in build mode due to upgrade issue")
        upgrade(latest_version=latest_version,
            headline="An issue occured during database setup. I am restarting the upgrade "
            "and manually compile all dependencies for a better compatibility. "
            "Thank you for your patience!\n")
        return False

    if err != "":
        error("Upgrade error!","Sorry, I could not upgrade your database. "
                "\nThe following error occured:\n%s" % (err))
        return False

    # store the new version
    # this may fail if there was a server still running:
    #v = get_installed_version()
    v = latest_version["version"]
    save_config_variable(config, "version", str(v))
    dl_url = get_download_link("upgrade", 0, True)

    # start service again
    if service_was_running:
        _print("I am starting the service again ...")
        cmd = "%s%s start" % (c["sudo"], service_file)
        out, err = run(cmd)
    success("\nI successfully upgraded RhodeCode Enterprise to version %s" % v)
    create_bat_files()
    basic_menu()


def settings():
    """
    Shows a menu of changeable settings
    """
    loop = True
    while loop:
        c, config = config_variables()

        clear()
        _print(HEADER)

        if len(c["version"]) < 3:
            error("RhodeCode is missing!","Sorry, it seems RhodeCode Enterprise is not properly installed."
            "\nPlease install it before performing advanced actions.")
            return False

        # try to get the current log level value
        current_level = ""
        cmd = su("cd %s && %s/bin/rhodecode-config --show --filename=%s \"[handler_console]level=\" " % (c["data_path"], c["system_path"], c["ini_filename"]))
        if "windows" in PLATFORM:
            cmd = cmd.replace("/bin/", "/Scripts/")
            cmd = cmd.replace("/", "\\")
        out, err = run(cmd, False)
        kv_dict = json.loads(out)  # a JSON dict is returned
        if "handler_console" in kv_dict and "level" in kv_dict["handler_console"]:
            current_level = str(kv_dict["handler_console"]["level"]).strip().split()[0].upper()
        try:
            kv_dict = json.loads(out)  # a JSON dict is returned
            if "handler_console" in kv_dict and "level" in kv_dict["handler_console"]:
                current_level = str(kv_dict["handler_console"]["level"]).upper()
        except:
            log.exception('')
            err = "Invalid JSON response %s from call" % out
        if err != "":
            error("Value error.","Sorry, I can not get the current loglevel value from your installation."
                    "\nThe following error occured:\n%s" % (err))
            return False

        warning("WARNING: changing settings may harm the availability of your installation.\n"
                 "I recommend running them at first at in test environment and always with a prior full backup of your system.")

        txt = "\nPlease select an option:\n"
        if len(c["proxy"]) > 3:
            txt = "%s[1] Remove current proxy server setting (for Installer)\n" % txt
        else:
            txt = "%s[1] Add proxy server (for the Installer)\n" % txt
        if current_level == "DEBUG":
            txt = "%s[2] Set log level back to 'info'\n" % txt
        else:
            txt = "%s[2] Set log level to 'debug'\n" % txt
        txt = "%s[3] Set new database credentials\n" % txt
        txt = "%s[b] Back to main menu\n" % txt
        txt = "%s[q] Quit installer\n" % txt
        txt = "%s> " % txt

        ninp = noninteractive("settings_menu")
        inp = raw_input(txt).lower() if not ninp else ninp
        if inp == "q":
            quit()
        if inp == "" or inp == "b":
            return True
        if inp == "1":
            if len(c["proxy"]) > 3:
                save_config_variable(config, "proxy", "")
                save_config_variable(config, "proxy_cert", "")
            else:
                proxy, proxy_cert = ask_proxy()
                save_config_variable(config, "proxy", proxy)
                save_config_variable(config, "proxy_cert", proxy_cert)
        if inp == "2":
            if current_level == "DEBUG":
                set_ini_value("[handler_console]level", "INFO")
            else:
                set_ini_value("[handler_console]level", "DEBUG")
        if inp == "3":
            database_url = ask_database(c["data_path"])
            set_ini_value("[app:main]sqlalchemy.db1.url", database_url)

def set_ini_value(key="", value=""):
    """
    replaces a value of production.ini
    key needs to be in the format [SEGMENT]KEY, like "[handler_console]level"

    :returns: boolean about success
    """
    c, config = config_variables()
    # stop service if running
    service_file = "/etc/init.d/rhodecode"
    if os.path.isfile("/etc/arch-release"):
        service_file = "/etc/conf.d/rhodecode"
    service_was_running = False
    if service_is_running():
        service_was_running = True
        cmd = "%s%s stop" % (c["sudo"], service_file)
        out, err = run(cmd, False)
    # save the new value in production.ini
    cmd = su('cd %s && "%s/bin/rhodecode-config" --update --filename=%s "%s=%s" ' % (c["data_path"], c["system_path"], c["ini_filename"],key, value))
    if "windows" in PLATFORM:
        cmd = cmd.replace("/bin/", "/Scripts/")
        cmd = cmd.replace("/", "\\")
    out, err = run(cmd, False)
    if err != "":
        return False
    # start service again
    if service_was_running:
        cmd = "%s%s start" % (c["sudo"], service_file)
        out, err = run(cmd, False)
    return True


def actions():
    """
    Shows a menu of advanced actions
    """
    loop = True
    while loop:
        c, config = config_variables()

        clear()
        _print(HEADER)

        if len(c["version"]) < 3:
            error("RhodeCode is missing!","Sorry, it seems RhodeCode Enterprise is not properly installed."
            "\nPlease install it before performing advanced actions.")
            return False

        warning("WARNING: all advanced actions deeply interfere with your operating system or installation.\n"
                 "I recommend running them at first at in test environment and always with a prior full backup of your system.")

        service_file = "/etc/init.d/rhodecode"
        if os.path.isfile("/etc/arch-release"):
            service_file = "/etc/conf.d/rhodecode"

        txt = "\nPlease select an option:\n"
        txt = "%s[1] Run initial database setup again (can delete data!)\n" % txt
        if os.path.isfile(service_file):
            txt = "%s[2] Remove the service of the RhodeCode Enterprise\n" % txt
        else:
            txt = "%s[2] Install the RhodeCode Enterprise service\n" % txt
        txt = "%s[3] Show the logs (requires installation of service)\n" % txt
        txt = "%s[b] Back to main menu\n" % txt
        txt = "%s[q] Quit installer\n" % txt
        txt = "%s> " % txt

        ninp = noninteractive("actions_menu")
        inp = raw_input(txt).lower() if not ninp else ninp
        if inp == "q":
            quit()
        if inp == "" or inp == "b":
            return True
        if inp == "1":
            setup()
        if inp == "2":
            if os.path.isfile(service_file):
                # stop service and remove file
                cmd = "%s%s stop" % (c["sudo"], service_file)
                out, err = run(cmd, False)
                os.remove(service_file)
            else:
                install_initd()
        if inp == "3":
            show_log()

def install_initd(headline="", silent=False):
    """
    Downloads the init.d script for the platform,
    pastes the correct config settings and copies it
    to /etc/init.d/ as rhodecode.
    Arch is still unsupported!
    """
    global SECTION, PLATFORM
    c, config = config_variables()
    if not silent:
        if headline == "":
            headline = "With an init.d script you can run RhodeCode Enterprise as a service and have it autostart on reboot."
        clear()
        _print(HEADER)
        _print(headline)
    service_file = "/etc/init.d/rhodecode"
    if "ubuntu" in PLATFORM or "debian" in PLATFORM or "mint" in PLATFORM:
        source_file = "rhodecode-daemon-debian.sh"
    elif "fedora" in PLATFORM or "redhat" in PLATFORM or "centos" in PLATFORM or "amzn1" in PLATFORM:
        source_file = "rhodecode-daemon-redhat.sh"
    elif "suse" in PLATFORM:
        source_file = "rhodecode-daemon-suse.sh"
    else:
        source_file = ""
    """
    # deactivated because Arch had issues
    if source_file == "" and os.path.isfile("/etc/arch-release"):
        source_file = "rhodecode-daemon-arch"
        service_file = "/etc/conf.d/rhodecode"
    """
    if source_file == "":
        error("Unsupported system.","Sorry, there is no init.d file for your operating system: %s" % PLATFORM)
        return False

    log.debug("Trying to install init.d script %s" % service_file)
    # download the file
    tmp_file = "/tmp/rhodecode-initd-template"
    _print("\nPlease wait, I am downloading the init.d file for your operating system ...")
    dl_url = "https://rhodecode.com/dl"
    if os.path.isfile(tmp_file):
        os.remove(tmp_file)
    download_file("%s/%s" % (dl_url, source_file), tmp_file)
    if not os.path.isfile(tmp_file):
        error("Download error.","Sorry, the download of the init.d file %s to %s failed." % (source_file, tmp_file))
        return False

    # change the constants in the file
    _print("\nPlease wait, I am customizing the init.d file for your installation ...")
    changes = {"APP_PATH=": "APP_PATH=%s" % c["data_path"],
                "CONF_NAME=": "CONF_NAME=%s" % c["ini_filename"],
                "PYTHON_PATH=": "PYTHON_PATH=%s" % c["system_path"],
                "APP_NAME=": "APP_NAME=rhodecode",
                "APP_NAME_OUTPUT=": "APP_NAME_OUTPUT='RhodeCode Enterprise'",
                "RUN_AS=": "RUN_AS=%s" % c["user"],
                "LOG_PATH=": "LOG_PATH=/var/log/rhodecode/rhodecode.log",
    }

    for change in changes:
        ok = replace_line_in_file(tmp_file, change, changes[change])
        if not ok:
                error("Customization error.","Sorry, I could not change the line starting with '%s' to '%s' at %s" % (change, changes[change], tmp_file))
                return False
    # prepare log folder and log file
    log_folder = "/var/log/rhodecode"
    log_file = "%s/rhodecode.log" % log_folder
    _print("\nI create the log folder %s if not existing, yet ..." % log_folder)
    cmd = "%smkdir %s" % (c["sudo"], log_folder)
    out, err = run(cmd)

    _print("\nI create the log file %s if not existing, yet ..." % log_file)
    cmd = "%stouch %s" % (c["sudo"], log_file)
    out, err = run(cmd)

    _print("\nI set the proper write permissions for the log file ...")
    cmd = "%schmod 0666 %s" % (c["sudo"], log_file)
    out, err = run(cmd)

    # copy the file to /etc/init.d/rhodecode
    _print("\nI copy the init.d file to %s ..." % service_file)
    cmd = "%scp %s %s" % (c["sudo"], tmp_file, service_file)
    out, err = run(cmd)
    if err != "":
            error("Copy error.","Sorry, I could not copy the file %s to %s."
                "\nThe following error occured:\n%s" % (tmp_file, service_file, err))
            return False

    _print("\nI make the file %s executable ..." % service_file)
    cmd = "%schmod +x %s" % (c["sudo"], service_file)
    out, err = run(cmd)

    # final check
    _print("\nI am verifying the correct installation of the init.d file ...")
    if not os.path.exists(log_file) or not os.path.exists(service_file):
        error("Missing files.","Sorry, The file %s or %s was not created." % (log_file, service_file))
        return False
    _print("\nI am trying to restart the new service ...")
    cmd = "%s%s restart" % (c["sudo"], service_file)
    out, err = run(cmd)
    if err != "":
            error("Restart error.","Sorry, I could not restart the service."
                "\nThe following error occured:\n%s" % (err))
            return False
    # stop the service
    #cmd = "%s %s stop" % (c["sudo"], service_file)
    #out, err = run(cmd, False)

    if not silent:
        clear()
        _print(HEADER)
        _print("The RhodeCode Enterprise service was installed and is already running on port 5000!")
        _print("\nYou can start, stop, restart and get the status of the service with: ")
        _print("%s%s%s {start|stop|restart|status}%s" % (GREEN, c["sudo"], service_file, RESET))
        basic_menu()
    return True

def service_is_running():
    """
    :returns: boolean if rhodecode service is running
    """
    c, config = config_variables()
    process = "%s/bin/paster serve --daemon" % (c["system_path"])
    cmd = su("ps aux | grep \"%s\"" % process)
    out, err = run(cmd, False)
    # check if output contains full process to filter out the ps aux call itself
    if err == "" and "rhodecode.log" in out:
        return True
    return False

def show_log():
    """
    prints the command to browse the logs
    RhodeCode Enterprise installation as a single-thread.
    """
    clear()
    _print(HEADER)

    c, config = config_variables()
    service_file = "/etc/init.d/rhodecode"
    if os.path.isfile("/etc/arch-release"):
        service_file = "/etc/conf.d/rhodecode"
    if os.path.isfile(service_file) == False:
        error("Service missing!","Sorry, it seems the RhodeCode Enterprise service is not installed at %s.""\nPlease install it at the menu and try again." % service_file)
        return False

    _print("Please open a new terminal window and copy & paste this line to see the self-updating log file:\n")
    cmd = "tail -f /var/log/rhodecode/rhodecode.log"
    _print(GREEN+cmd+RESET)
    basic_menu()

def check_installer_version(enforce_upgrade=False):
    """
    checks if a new installer version is existing
    and explains upgrade
    """
    global PLATFORM, BUILD
    clear()
    _print(HEADER)

    c, config = config_variables()

    # get the version list
    versions = []
    latest_version = []
    url = "https://rhodecode.com/api/v1/info/installer_versions"
    resp = open_url(url)
    html = resp.read()
    if not '"versions":' in html or not "release_date" in html:
        error("Connection error!","Sorry, I could not get the list of installer versions from rhodecode.com."
                "\nPlease check your internet connection.")
        return False
    # convert from json
    try:
        json_resp = json.loads(html)
        versions = json_resp["versions"]
        latest_version = versions[0]
    except:
        log.exception('')

    if len(versions) < 1 or not "general" in latest_version or not "version" in latest_version:
        error("Data error!","Sorry, I could not find the latest version data."
                "\nPlease check your internet connection.")
        return False

    local_version_int = convert_version_to_int(c["installer_version"])
    latest_version_int = convert_version_to_int(latest_version["version"])

    # it can be that local version is newer than latest online version (during dev!)
    if local_version_int >= latest_version_int and not enforce_upgrade:
        success("I am already on the latest version!")
        basic_menu()
        return True

    if "windows" in PLATFORM and not BUILD:
        warning("Attention: please rename the current rhodecode-installer.exe to anything else and then run it again to successfully upgrade it!\n")

    # upgrade instructions
    _print("%sA new installer version %s is available!\n%s" % (BOLD, latest_version["version"], RESET))
    if len(latest_version["general"]) > 0:
        _print("What is new in the version?")
        for txt in latest_version["general"]:
            print ("- %s " % txt)

    do_download = False
    loop = True
    while loop:
        txt = "\nCan I download and install the new installer for you?\n[y]es\n[n]o\n> "
        ninp = noninteractive("start_upgrade_installer")
        inp = raw_input(txt).lower() if not ninp else ninp
        if inp == "q":
            quit()
        if inp == "n":
            loop = False
        if inp == "y":
            do_download = True
            loop = False
    if do_download:
        # installer.exe wants to upgrade itself? Then download an exe!
        if "windows" in PLATFORM and not BUILD:
            _print("\nI am starting the upgrade of RhodeCode Installer ...")
            install_prebuilt_windows("upgrade", 1)
        else:
            url = get_download_link("upgrade", 1)
            download_file(url, "rhodecode-installer.py")
        # store the new installer version
        save_config_variable(config, "installer", latest_version["version"])
        success("I downloaded and installed the latest installer version. Please re-open me to see it in action.")
        quit()


def valid_os():
    """
    checks if OS is okay

    :returns: boolean. False if not Linux or Windows
    """
    global PLATFORM
    # check OS and exclude Darwin (=Mac OS X) for now
    if ("posix" in os.name  and "darwin" not in PLATFORM) or ("windows" in PLATFORM):
        return True
    else:
        return False

def is_root():
    """
    checks if a user is root. On Windows return True

    :returns: boolean
    """
    global PLATFORM
    # check if user typed "sudo" or is root
    if not "windows" in PLATFORM:
        user = getpass.getuser()
        log.info("Running Installer as user '%s'" % user)
        if user != "root":
            return False
    return True


def copy_folder(from_folder="", to_folder="", user=""):
    """
    is running the xcopy or copy command
    on the system because shutil.copytree does not
    copy the permissions!
    """
    global PLATFORM
    if user == "" and not "windows" in PLATFORM:
        c, config = config_variables()
        user = c["user"]
    if "windows" in PLATFORM:
        cmd = 'xcopy /Y /H /E /C /I "%s" "%s"' % (from_folder, to_folder)
    else:
        cmd = "cp -r %s %s" % (from_folder, to_folder)
        cmd = su(cmd, user)
    out, err = run(cmd, False)

def config_file_existing():
    """
    checks if new folder structure and
    config file is existing

    :returns: boolean
    """
    global SECTION, CONFIG_FILE, PLATFORM
    # does the new data/installer.ini structure exist?
    if not os.path.exists(CONFIG_FILE) :
        return False
    else:
        c, config = config_variables()
        if not "user" in c:
            log.error("found config file but user was missing")
            return False
    # check if all folders are existing so that a simple re-install
    # can be done by deleting the system folder for example
    base_folder = install_path(c["user"])
    # target folders
    data_path = os.path.join(base_folder, "data")
    system_path = os.path.join(base_folder, "system")
    repo_path = os.path.join(base_folder, "repos")
    if os.path.exists(data_path) and os.path.exists(system_path) and os.path.exists(repo_path):
        return True
    return False

def setup_folders_view():
    """
    Creates folder structure and on existing installation
    interactively ask for old folders and migrates them

    :returns: boolean, True if migrated, False if new setup
    :returns: string, username
    """
    global PLATFORM
    clear()
    _print(HEADER)
    # ask for existing installation
    cfg = {}
    cfg["user"] = ""
    user = ""
    headline = ""
    already_installed = False
    loop = True
    while loop:
        txt = "Do you already have RhodeCode or RhodeCode Enterprise installed on this server?\n[y]es\n[n]o\n> "
        ninp = noninteractive("already_installed")
        inp = raw_input(txt).lower() if not ninp else ninp
        print "'%s'" % inp
        if inp == "q":
            quit()
        if inp == "n":
            loop = False
        if inp == "y":
            already_installed = True
            loop = False

    if not "windows" in PLATFORM:
        clear()
        _print(HEADER)
        loop = True
        while loop:
            if already_installed:
                txt = "Under which Linux user did you install RhodeCode Enterprise?\n> "
            else:
                txt = "Under which Linux user do you want to install RhodeCode Enterprise?\n> "
            ninp = noninteractive("os_user")
            inp = raw_input(txt).lower() if not ninp else ninp
            if inp == "q":
                quit()
            if len(inp) > 1:
                cmd = su("pwd", inp)
                out, err = run(cmd, False)
                if err == "":
                    if os.getcwd() == install_path(inp):
                        loop = False
                    else:
                        warning("\nPlease move me into the folder %s "
                                    "and run me again. Thanks!" % install_path(inp))
                        sys.exit()
                else:
                    warning("User %s does not exist or does not have a home folder. Please try another one." % inp)
        cfg["user"] = inp
        user = inp

    base_folder = install_path(cfg["user"])

    # target folders
    data_path = os.path.join(base_folder, "data")
    system_path = os.path.join(base_folder, "system")
    repo_path = os.path.join(base_folder, "repos")

    ######
    # installation existing, migrate folders
    if already_installed:
        clear()
        if "windows" in PLATFORM:
            headline = """From Installer version 0.5.0 on, we are introducing a more standardized folder structure in the format:
$CURRENT_FOLDER/data - for ini files and SQLite
$CURRENT_FOLDER/system - for virtualenv or pre-built app code
$CURRENT_FOLDER/repos - for repositories
In the following steps I will create this folder structure and move or copy existing folders.\n"""
        else:
            headline = """From Installer version 0.5.0 on, we are introducing a more standardized folder structure in the format:
%s
%s/data - for ini files and SQLite
%s/system - for virtualenv or pre-built app code
%s/data - for repositories (can be a symlink!)
In the following steps I will create this folder structure and move or copy existing files.\n""" % (base_folder, base_folder, base_folder, base_folder)
        _print(HEADER)
        _print(headline)

        # try to find the old .rhodecode_config file on different locations
        # alternative for searching: http://bit.ly/1ad7Is1
        if "windows" in PLATFORM:
            conf_locations = [os.path.join(os.getcwd(), ".rhodecode_config")]
        else:
            base_path_parent, tail = os.path.split(base_folder)
            conf_locations = ["/home/%s/.rhodecode_config" % user,
                                        "/home/%s/rhodecode/.rhodecode_config" % user,
                                        os.path.join(base_folder, ".rhodecode_config"),
                                        os.path.join(base_path_parent, ".rhodecode_config")
                                        ]
        found_cfg = False
        for old_conf_file in conf_locations:
            log.debug("Searching %s ..." % old_conf_file)
            if os.path.exists(old_conf_file) and not found_cfg:
                log.debug("Found old config file %s" % old_conf_file)
                _print("Reading your former folder structure from %s ..." % old_conf_file)
                c, config = config_variables_old_installer(old_conf_file)
                cfg = c
                cfg["cfg_file"] = old_conf_file
                found_cfg = True

        # manually ask for folders
        if not found_cfg:
            """
            # ask for venv folder
            loop = True
            while loop:
                txt = ("\nWhat is the absolute path to your Virtualenv (rhodecode-venv) folder?\n> ")
                ninp = noninteractive("migration_venv_path")
                inp = raw_input(txt) if not ninp else ninp
                if inp == "q":
                    quit()
                if len(inp) > 2:
                    # try to get the rhodecode version
                    v = get_installed_version(inp, user)
                    if v == "":
                        warning("Sorry, there is no valid RhodeCode installation in %s."
                                "\nPlease check again." % (inp))
                    else:
                        cfg["venv_path"] = inp
                        old_version = v
                        loop = False
              """
            # ask for app folder
            loop = True
            while loop:
                txt = ("\nWhat is the absolute path to your RhodeCode .ini file (including the filename)?\n> ")
                ninp = noninteractive("migration_ini_path")
                inp = raw_input(txt) if not ninp else ninp
                if inp == "q":
                    quit()
                if len(inp) > 2:
                    if os.path.exists(inp) and ".ini" in inp:
                        cfg["app_path"], cfg["ini_filename"] = os.path.split(inp)
                        loop = False
                    else:
                        warning("The path %s does not exist or the filename is missing. "
                                    "Please correct it or leave empty for default." % inp)
            # ask for repo path
            loop = True
            while loop:
                txt = ("\nWhat is the absolute path to your repositories?\n> ")
                ninp = noninteractive("migration_repo_path")
                inp = raw_input(txt) if not ninp else ninp
                if inp == "q":
                    quit()
                if len(inp) > 2:
                    if os.path.exists(inp):
                        cfg["repo_path"] = inp
                        loop = False
                    else:
                        warning("The path %s does not exist. Please correct it or leave empty for default." % inp)
            loop = True

        if not "user" in cfg or not "repo_path" in cfg or not "app_path" in cfg:
            log.error(cfg)
            error("Config error!", "Could not migrate the folders. Some configurations are missing.")

        ########
        # move / copy / symlink the files to the new folders
        clear()
        _print(HEADER)
        if headline != "":
            _print(headline)

        if not "windows" in PLATFORM:
            # stop running service
            cmd = "%s/etc/init.d/rhodecode stop" % sudo_cmd()
            out, err = run(cmd, False)

        # what about the repos?
        loop = True
        if cfg["repo_path"] != repo_path:
            if "windows" in PLATFORM:
                repo_action = "copy"
            else:
                repo_action = "symlink"
            # copy or create symlink to new repos folder
            if repo_action == "copy":
                msg = "Copying %s to %s ..." % (cfg["repo_path"],repo_path)
                _print(msg)
                copy_folder(cfg["repo_path"], repo_path, cfg["user"])
            if repo_action == "symlink":
                if not os.path.lexists(repo_path):
                    _print("Creating symlink at %s pointing to %s ..." % (repo_path, cfg["repo_path"]))
                    os.symlink(cfg["repo_path"], repo_path)
                else:
                    error("Folder already existing!",
                            "I could not create a symlink at %s because the folder is already existing." % repo_path)

        #create data folder
        if not os.path.exists(data_path):
            _print("Creating data folder %s ..." % data_path)
            cmd = su('mkdir "%s"' % data_path, cfg["user"])
            out, err = run(cmd, False)
        # move .ini, .db files and folders from app_path to data

        # move folders from old app_path/data/* folder to data/*
        old_data_dir = os.path.join(cfg["app_path"],"data")
        if os.path.exists(old_data_dir):
            files = os.listdir(old_data_dir)
            for f in files:
                source_path = os.path.join(old_data_dir, f)
                dest_path = os.path.join(data_path, f)
                if source_path != dest_path:
                    _print("Copying %s to %s ..." % (source_path, dest_path))
                    copy_folder(source_path, dest_path, cfg["user"])
                    #shutil.rmtree(source_path)
        # move .ini, .db files from app_path to data
        files = os.listdir(cfg["app_path"])
        for f in files:
            if f.endswith(".ini") or f.endswith(".db"):
                source_path = os.path.join(cfg["app_path"],f)
                dest_path = os.path.join(data_path, f)
                if source_path != dest_path:
                    _print("Moving %s to %s ..." % (source_path, dest_path))
                    shutil.move(source_path, dest_path)

        """
        # copy rhodecode-venv folder to system
        if "venv_path" in cfg and cfg["venv_path"] != "":
            # under Windows the virtualenv call needs to be made relative
            # already before renaming
            if "windows" in PLATFORM:
                cmd = su("cd %s && cd .. && virtualenv --relocatable %s" % (c["venv_path"], os.path.basename(c["venv_path"])))
                out, err = run(cmd, False)
            _print("Copying %s to %s ..." % (cfg["venv_path"], system_path))
            copy_folder(cfg["venv_path"], system_path, cfg["user"])
        """

        # copy old config file to data and rename it to installer.ini
        if "cfg_file" in cfg:
            _print("Moving %s to %s ..." % (cfg["cfg_file"], CONFIG_FILE))
            shutil.move(cfg["cfg_file"], CONFIG_FILE)

        # rename old cfg["ini_filename"] to production.ini
        ini_filename = os.path.join(base_folder, "data", "production.ini")
        if not os.path.exists(ini_filename):
            shutil.move(os.path.join(base_folder, "data", cfg["ini_filename"]), ini_filename)

        """
        # delete old venv-path
        try:
            _print("Deleting old folder %s ..." % cfg["venv_path"])
            shutil.rmtree(cfg["venv_path"])
        except:
            pass
        """
        # clean base_folder
        files = os.listdir(base_folder)
        for f in files:
            rm_files = [".rhodecode_config", ".ini", ".mako", ".db", ".log"]
            for rm_file in rm_files:
                if f.endswith(rm_file):
                    try:
                        log.debug("Deleting %s ..." % os.path.join(base_folder, f))
                        os.remove(os.path.join(base_folder, f))
                    except:
                        log.exception('')

    ######
    # new installation, create basic folder structure
    if not already_installed:
        if not os.path.exists(data_path):
            _print("Creating folder %s ..." % data_path)
            cmd = su('mkdir "%s"' % data_path, cfg["user"])
            out, err = run(cmd, False)
        system_path = os.path.join(base_folder, "system")
        if not os.path.exists(system_path):
            _print("Creating folder %s ..." % system_path)
            cmd = su('mkdir "%s"' % system_path, cfg["user"])
            out, err = run(cmd, False)
        repo_path = os.path.join(base_folder, "repos")
        if not os.path.exists(repo_path):
            _print("Creating folder %s ..." % repo_path)
            cmd = su('mkdir "%s"' % repo_path, cfg["user"])
            out, err = run(cmd, False)
    return already_installed, cfg["user"]


def create_config(user="", migrated=False):
    """
    creates a new installer.ini in data folder if not already existing.
    Just fills missing stuff and removes deprecated options.
    The user parameter is just necessary on creation.

    :returns: boolean, True if created, False is updated
    """
    global SECTION, CONFIG_FILE, PLATFORM, MY_VERSION

    if user == "" and not "windows" in PLATFORM:
        c, config2 = config_variables()
        user = c["user"]

    base_folder = install_path(user)

    # default values
    config = ConfigParser.ConfigParser()
    data_path = os.path.join(base_folder, "data")
    system_path = os.path.join(base_folder, "system")
    repo_path = os.path.join(base_folder, "repos")

    # create a new installer.ini
    if not os.path.exists(CONFIG_FILE):
        #database = ask_database(data_path)
        log.info("Config file %s is not existing. Creating it ..." % CONFIG_FILE)
        config.add_section(SECTION)
        proxy, proxy_cert = ask_proxy()
        options = {"user": user,
                        "data_path": data_path,
                        "system_path": system_path,
                        "repo_path": repo_path,
                        "ini_filename": "production.ini",
                        "version":"",
                        "installer_version": MY_VERSION,
                        "proxy": proxy,
                        "proxy_cert": proxy_cert
                    }
        for option in options:
            config.set(SECTION, option, options[option])
        # save config file
        with open(CONFIG_FILE, 'wb') as configfile:
            config.write(configfile)
        return True

    else:  # config file is existing, do migration
        config.read(CONFIG_FILE)
        if SECTION not in config.sections():
            config.add_section(SECTION)
        # set again the non-changable options (creates them if non existing)
        config.set(SECTION, "data_path", data_path)
        config.set(SECTION, "system_path", system_path)
        config.set(SECTION, "repo_path", repo_path)
        config.set(SECTION, "ini_filename", "production.ini")
        config.set(SECTION, "installer_version", MY_VERSION)
        # remove deprecated options
        depr_options = ["app_path", "venv_path", "database"]
        for depr_option in depr_options:
            try:
                app_path_value = config.get(SECTION, depr_option)
                config.remove_option(SECTION, depr_option)
            except:
                pass
        # missing proxy value
        try:
            proxyc = config.get(SECTION, "proxy")
        except:
            config.set(SECTION, "proxy", "")
        # missing cert value for Pip calls
        try:
            certc = config.get(SECTION, "proxy_cert")
        except:
            config.set(SECTION, "proxy_cert", "")
        # save config file
        with open(CONFIG_FILE, 'wb') as configfile:
            config.write(configfile)
        return False

def fix_path_issues():
    """
    Idempotent. Fixes possible issues with:
    - hardcoded virtualenv paths
    - old paths in production.ini
    - old paths in service script
    """
    global SECTION, CONFIG_FILE, PLATFORM
    c, config = config_variables()
    #database = ask_database(c["data_path"])

    _print("I am starting to fix possible issues ...")

    # deprecated because on issues we just throw away the virtualenv and install
    # RCE again
    """
    # under Windows a normal virtualenv call is enough to make paths relative
    if "windows" in PLATFORM:
        cmd = su("cd %s && cd .. && virtualenv --relocatable %s" % (c["system_path"], os.path.basename(c["system_path"])))
        out, err = run(cmd, False)
    else:
        # under Linux the venv_move.py script fixes the virtualenv paths
        # download the file
        dl_url = "https://rhodecode.com/dl/venv_move.py"
        tmp_file = os.path.join(os.getcwd(), "venv_move.py")  # tempfile.gettempdir()
        download_file(dl_url, tmp_file)
        if not os.path.isfile(tmp_file):
            log.error("could not download %s" %dl_url)
        else:
            _print("I am fixing folder relationships in system folder ...")
            cmd = su("%s %s --update-path=auto %s" % (c["python"], tmp_file, c["system_path"]))
            out, err = run(cmd, False)
        if os.path.isfile(tmp_file):
            os.remove(tmp_file)

    # now repair the relative paths in production.ini -> needs to be done that way because it
    # can be that rhodecode tools are not installed, yet
    _print("I am fixing folder relationships in config files ...")
    changes = {"cache_dir =": "cache_dir = %s" % c["data_path"],
                    "index_dir =": "index_dir = %s" % os.path.join(c["data_path"], "index"),
                    "archive_cache_dir =": "archive_cache_dir = %s" % os.path.join(c["data_path"], "tarballcache"),
                    "beaker.cache.data_dir =": "beaker.cache.data_dir = %s" % os.path.join(c["data_path"], "cache", "data"),
                    "sqlalchemy.db1.url": "sqlalchemy.db1.url = %s" % database}
    for change in changes:
        ok = replace_line_in_file(os.path.join(c["data_path"], c["ini_filename"]), change, changes[change])
    """
    # install, stop before db creation and migrate db instead
    install(True)
    # upgrade database
    _print("\nPlease wait, I am upgrading the database ...")
    cmd2 = 'paster" upgrade-db %s --force-yes' % c["ini_filename"]
    cmd = su('cd "%s" && "%s/bin/%s' % (c["data_path"], c["system_path"], cmd2))
    if "windows" in PLATFORM:
        cmd = cmd.replace("/bin/", "/Scripts/")
        cmd = cmd.replace("/", "\\")
    out, err = run(cmd, False)
    if err != "":
        error("Upgrade error!","Sorry, I could not upgrade your database. "
                "\nThe following error occured:\n%s" % (err))
        return False

    """
    # store the new version
    # this may fail if there was a server still running:
    #v = get_installed_version()
    v = latest_version["version"]
    save_config_variable(config, "version", str(v))

    # start service again
    if service_was_running:
        _print("I am starting the service again ...")
        cmd = "%s%s start" % (c["sudo"], service_file)
        out, err = run(cmd)
    success("\nI successfully upgraded RhodeCode Enterprise to version %s" % v)
    create_bat_files()
    """

    # verify rhodecode version
    _print("Trying to get the application version ...")
    installed_version = get_installed_version(c["system_path"], c["user"])
    if installed_version != "":
        _print("Found version %s" % installed_version)
        # store the new version
        ver = get_installed_version()
        save_config_variable(config, "version", str(ver))
        v = convert_version_to_int(installed_version)
        # re-install service if version 2.x
        if not "windows" in PLATFORM and v > convert_version_to_int("1.9.9"):
            _print("Trying to (re)install service ...")
            # re-install service
            service_file = "/etc/init.d/rhodecode"
            if os.path.isfile(service_file):
                os.remove(service_file)
            service_installed = install_initd(silent=True)
            if service_installed:
                _print("\nI (re)installed RhodeCode Enterprise as a service.")
    if git_is_too_old():
        install_new_git_on_linux()
    _print("I finished with fixing issues.")
    basic_menu()

def main_menu_view(direct_install=False, enforce_upgrade=False):
    """
    displays the main menu
    if direct_install is True then it directly starts the installation process
    """
    global HEADER, SECTION, CONFIG_FILE, PLATFORM
    loop = True
    while loop:
        clear()
        _print(HEADER)

        do_install = True
        if config_file_existing() and get_installed_version() != "":
            do_install = False

        txt = "Please select an option:\n"
        if do_install:
            txt = "%s[1] Install RhodeCode Enterprise\n" % txt
        else:
            txt = "%s[1] Upgrade RhodeCode Enterprise\n" % txt
            txt = "%s[2] Show the start command\n" % txt
        if not "windows" in PLATFORM and not do_install:
            txt = "%s[3] Change the settings\n" % txt
            txt = "%s[4] Perform advanced actions\n" % txt
        txt = "%s[0] Upgrade RhodeCode Installer\n" % txt
        txt = "%s[q] Quit installer\n" % txt
        txt = "%s> " % txt

        if do_install and direct_install:
            inp = "1"
            direct_install = False
        else:
            ninp = noninteractive("main_menu")
            inp = raw_input(txt) if not ninp else ninp

        if inp == "q":
            quit()
        if inp == "1":
            if do_install:
                install()
            else:
                if not enforce_upgrade:
                    can_upgrade()
                else:
                    can_upgrade(20000, False) # fake an older local version to enforce upgrades
        if inp == "2":
            start()
        if inp == "3" and not "windows" in PLATFORM and not do_install:
            settings()
        if inp == "4" and not "windows" in PLATFORM and not do_install:
            actions()
        if inp == "0":
            check_installer_version(enforce_upgrade)


######################
# CLI OUTPUT STARTS HERE
######################
if __name__ == '__main__':

    parser = optparse.OptionParser()
    parser.add_option("-f", "--fix", action="store_true", help='fix common configuration issues')
    parser.add_option("-v", "--version", action="store_true", help='shows the Installer version')
    parser.add_option("-b", "--build", action="store_true", help='build/compile system (for Windows & 32bit Linux)')
    parser.add_option("-i", "--install", action="store_true", help='directly start installation')
    parser.add_option("-u", "--upgrade", action="store_true", help='enforces an upgrade of unchanged version')
    parser.add_option("-n", "--noninteractive", action="store_true", help='runs Installer noninteractively by using data/noninteractive.ini file')
    (options, args) = parser.parse_args()
    OPTIONS = options

    if options.version:
        print(MY_VERSION)
        sys.exit()

    if options.build or os.path.isfile("/etc/arch-release") or "-armv" in PLATFORM:
        BUILD = True
    else:
        BUILD = False

    try:
        clear()
        # check OS and exclude Darwin (=Mac OS X) for now
        if not valid_os:
            error("\nInvalid operating system!","This installer just supports Linux and Windows,"
            "but you have %s installed. Please download the correct installer "
            "for your operation system." % PLATFORM, False)

        IS_ROOT = is_root()
        # break if not root on linux (ignored on windows)
        if not IS_ROOT:
            error("\nAs root please!",
                "You need to run me with root / sudo privileges. Please type 'sudo python linux-installer.py'.", False)

        HEADER = "\nRhodeCode Installer %s\n-------------------------\n" % MY_VERSION
        txt=("\nI am your assistant for installing, upgrading & adjusting of RhodeCode Enterprise. "
                "You can always quit me by typing 'q' on the prompt.")
        _print(HEADER+txt)

        migrated = False
        if not config_file_existing():
            migrated, user = setup_folders_view()
            create_config(user, migrated)
        else:
            _print("\nTesting internet connection ...")
            try:
                can_reach_internet()
            except:
                log.exception('')
                c, config = config_variables()
                proxy, proxy_cert = ask_proxy("I could not reach https://rhodecode.com/ping "
                "to test your internet connection "
                "and optional proxy settings. Please adjust your settings now. "
                "I am supporting proxy servers with username:password authentication "
                "(called basic auth) and proxy servers without authentication.\n")
                save_config_variable(config, "proxy", proxy)
                save_config_variable(config, "proxy_cert", proxy_cert)

        if options.fix or migrated:
            fix_path_issues()
        create_config()  # idempotent
        ########
        # put test calls here
        #if git_is_too_old():
        #    print install_new_git_on_linux()
        #install_wheels()
        #exit()
        #########
        # if the autostart_setup option is in config.ini then direct start setup
        try:
            c, config = config_variables()
            autostart_setup = config.get(SECTION, "autostart_setup")
            if autostart_setup:
                setup(True)
        except:
            pass
        main_menu_view(options.install, options.upgrade)
    except (KeyboardInterrupt, SystemExit):
        print("")
        pass
    except:
        print("\nSorry, an error did occur!\nYou can see details in the Installer log file %s" % tmp_file)
        print("\nIf you can not fix the error by yourself then please contact us:")
        print("1. Go to https://rhodecode.com/help")
        print("2. Start a new discussion")
        print("3. Tell us about your system and the versions of the installed RhodeCode applications")
        print("4. Attach to the discussion the above mentioned Installer log file")
        print("\nThanks & Sorry again!\n")

        log.exception('')

