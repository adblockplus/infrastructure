# coding: utf-8
# vi: set fenc=utf-8 ft=ruby ts=8 sw=2 sts=2 et:
require 'shellwords'
require 'yaml'

# https://issues.adblockplus.org/ticket/170
if !system('python', File.expand_path('../ensure_dependencies.py', __FILE__))
  message = 'Failed to ensure dependencies being up-to-date!'
  raise Vagrant::Errors::VagrantError, message
end

# https://www.vagrantup.com/docs/vagrantfile/version.html
Vagrant.configure('2') do |config|

  # The repository location in the production system's puppet master
  sync_path = '/etc/puppet/infrastructure'
  sync_type = system('which', 'rsync', :out => File::NULL) ? 'rsync' : nil

  # See also modules/adblockplus/manifests/host.pp
  hosts_file = File.expand_path('../modules/private/hiera/hosts.yaml', __FILE__)
  hosts_data = YAML.load_file(hosts_file)
  hosts_data.fetch('adblockplus::hosts', {}).each_pair do |name, record|

    # Formerly present hosts not destroyed yet require manual intervention
    next if record['ensure'] == 'absent'

    # https://docs.puppet.com/puppet/latest/man/apply.html
    puppet_options = Shellwords.split ENV.fetch('PUPPET_OPTIONS', '--verbose')
    puppet_options << '--debug' unless ENV.fetch('PUPPET_DEBUG', '').empty?
    puppet_options << '--environment=development'
    puppet_options << "--external_nodes=#{sync_path}/hiera/puppet_node_classifier.rb"
    puppet_options << '--node_terminus=exec'

    # https://www.vagrantup.com/docs/multi-machine/
    config.vm.define name do |host|

      if record.fetch('os', 'ubuntu-precise') == 'ubuntu-precise'

        # http://cloud-images.ubuntu.com/vagrant/precise/current/
        host.vm.box = 'precise64'
        host.vm.box_url = 'http://cloud-images.ubuntu.com/vagrant/precise/current/precise-server-cloudimg-amd64-vagrant-disk1.box'

        # https://www.vagrantup.com/docs/provisioning/shell.html
        host.vm.provision :shell, :privileged => true, :inline => <<-end
          python /etc/puppet/infrastructure/hiera/install_precise.py
        end

        # https://www.vagrantup.com/docs/synced-folders/
        host.vm.synced_folder '.', sync_path, type: sync_type

      elsif record['os'] == 'debian-jessie'

        # https://www.vagrantup.com/docs/boxes.html
        host.vm.box = 'debian/contrib-jessie64'
        host.vm.box_url = 'https://atlas.hashicorp.com/debian/boxes/contrib-jessie64'

        # https://packages.debian.org/jessie/puppet
        host.vm.provision :shell, :privileged => true, :inline => <<-end
          set -e -- '#{sync_path}' /etc/puppet/hiera.yaml
          if ! which puppet >/dev/null; then
            apt-get -y update
            apt-get -y install puppet
          fi
          test -e "$1" || ln -s /vagrant "$1"
          test -e "$2" || ln -s infrastructure/hiera/hiera.yaml "$2"
          puppet agent --enable
        end

        # https://docs.puppet.com/puppet/latest/configuration.html#hieraconfig
        puppet_options << "--hiera_config=#{sync_path}/hiera/hiera.yaml"

      else
        message = "Unrecognized OS '#{record['os']}' for host '#{name}'"
        raise Vagrant::Errors::VagrantError, message
      end

      # https://www.vagrantup.com/docs/vagrantfile/machine_settings.html
      host.vm.hostname = record.fetch('fqdn', "#{name}.test")

      # https://www.vagrantup.com/docs/networking/
      host.vm.network :private_network, ip: record['ips'][0]

      # https://www.vagrantup.com/docs/virtualbox/configuration.html
      host.vm.provider :virtualbox do |virtualbox|

        # The GUI would be just annoying to pop up by default every time
        virtualbox.gui = !ENV.fetch('VIRTUALBOX_GUI', '').empty?

        # Individual box configuration may increase the number of CPUs
        virtualbox.customize ['modifyvm', :id, '--cpus', 1]
        # Work around https://www.virtualbox.org/ticket/11649
        virtualbox.customize ['modifyvm', :id, '--natdnshostresolver1', 'on']

        # Role-specific requirements, optional
        role_name = record.fetch('role', 'default')
        role_file = File.expand_path("../hiera/roles/#{role_name}.yaml", __FILE__)
        role_data = File.exists?(role_file) ? YAML.load_file(role_file) : {}
        role_data.fetch('requirements', {}).each do |key, value|
          virtualbox.customize ['modifyvm', :id, "--#{key}", value.to_s]
        end

      end

      # https://www.vagrantup.com/docs/provisioning/puppet_apply.html
      host.vm.provision :puppet do |puppet|
        puppet.manifests_path = 'manifests'
        puppet.manifest_file = 'site.pp'
        puppet.module_path = 'modules'
        puppet.options = puppet_options
      end

      # https://github.com/mitchellh/vagrant/issues/1673
      host.ssh.shell = "sh -c 'BASH_ENV=/etc/profile exec bash'"

    end

  end

end
