#!/usr/bin/env python
#
# This file is part of the Adblock Plus infrastructure
# Copyright (C) 2018-present eyeo GmbH
#
# Adblock Plus is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 3 as
# published by the Free Software Foundation.
#
# Adblock Plus is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Adblock Plus.  If not, see <http://www.gnu.org/licenses/>.

import argparse
from filecmp import dircmp
import hashlib
import os
import sys
import shutil
import tarfile
import tempfile
import urllib
import traceback


__doc__ = """This script MUST be renamed in the form of $WEBSITE, e.g.
          help.eyeo.com, --name must be provided in order to fetch the
          files, expected files to be fetched are $NAME.tar.gz and $NAME.md5 in
          order to compare the hashes. --source must be an URL, e.g.
          https://helpcenter.eyeofiles.com"""


def download(url, temporary_directory):
    file_name = url.split('/')[-1]
    absolute_file_path = os.path.join(temporary_directory, file_name)
    print 'Downloading: ' + file_name
    urllib.urlretrieve(url, absolute_file_path)
    return absolute_file_path


def calculate_md5(file):
    with open(file) as file_handle:
        data = file_handle.read()
        md5_result = hashlib.md5(data).hexdigest()
    return md5_result.strip()


def read_md5(file):
    with open(file) as file_handle:
        md5_result = file_handle.readline()
    return md5_result.strip()


def untar(tar_file, temporary_directory):
    if tarfile.is_tarfile(tar_file):
        with tarfile.open(tar_file, 'r:gz') as tar:
            tar.extractall(temporary_directory)


def remove_tree(to_remove):
    if os.path.exists(to_remove):
        if os.path.isdir(to_remove):
            shutil.rmtree(to_remove)
        else:
            os.remove(to_remove)


def deploy_files(directory_comparison):
    for name in directory_comparison.diff_files:
        copytree(directory_comparison.right, directory_comparison.left)
    for name in directory_comparison.left_only:
        remove_tree(os.path.join(directory_comparison.left, name))
    for name in directory_comparison.right_only:
        copytree(directory_comparison.right, directory_comparison.left)
    for subdirectory_comparison in directory_comparison.subdirs.values():
        deploy_files(subdirectory_comparison)


# shutil.copytree copies a tree but the destination directory MUST NOT exist
# this might break the site for the duration of the files being deployed
# for more info read: https://docs.python.org/2/library/shutil.html
def copytree(source, destination):
    if not os.path.exists(destination):
        os.makedirs(destination)
        shutil.copystat(source, destination)
    source_items = os.listdir(source)
    for item in source_items:
        source_path = os.path.join(source, item)
        destination_path = os.path.join(destination, item)
        if os.path.isdir(source_path):
            copytree(source_path, destination_path)
        else:
            shutil.copy2(source_path, destination_path)


if __name__ == '__main__':
    website = os.path.basename(__file__)
    parser = argparse.ArgumentParser(
        description="""Fetch a compressed archive in the form of $NAME.tar.gz
                    and deploy it to /var/www/{0} folder""".format(website),
        epilog=__doc__,
    )
    parser.add_argument('--name', action='store', type=str, required=True,
                        help='Name of the tarball to deploy')
    parser.add_argument('--source', action='store', type=str, required=True,
                        help='The source where files will be downloaded')
    arguments = parser.parse_args()
    name = arguments.name
    source = arguments.source
    url_file = '{0}/{1}.tar.gz'.format(source, name)
    url_md5 = '{0}/{1}.md5'.format(source, name)
    temporary_directory = tempfile.mkdtemp()
    try:
        downloaded_file = download(url_file, temporary_directory)
        downloaded_md5 = download(url_md5, temporary_directory)
        if calculate_md5(downloaded_file) == read_md5(downloaded_md5):
            untar(downloaded_file, temporary_directory)
            tarball_directory = os.path.join(temporary_directory, name)
            destination = os.path.join('/var/www/', website)
            directory_comparison = dircmp(destination, tarball_directory)
            print 'Deploying files'
            deploy_files(directory_comparison)
        else:
            error_message = """{0}.tar.gz md5 computation doesn't match {0}.md5
                            contents""".format(name)
            sys.exit(error_message)
    except Exception as error:
        traceback.print_exc()
        sys.exit(error)
    finally:
        shutil.rmtree(temporary_directory)
