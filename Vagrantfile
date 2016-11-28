require 'yaml'

VAGRANTFILE_API_VERSION = "2"
REPOSITORY_DIR = File.dirname(__FILE__)
DEPENDENCY_SCRIPT = File.join(REPOSITORY_DIR, "ensure_dependencies.py")

if !system("python", DEPENDENCY_SCRIPT)
  error = Vagrant::Errors::VagrantError
  error.error_message("Failed to ensure dependencies being up-to-date!")
  raise error
end

def define_standard_vm(config, host_name, ip, role=nil)
  config.vm.define host_name do |config|
    config.vm.box = 'precise64'
    config.vm.box_url = 'http://cloud-images.ubuntu.com/vagrant/precise/current/precise-server-cloudimg-amd64-vagrant-disk1.box'
    config.vm.host_name = "#{host_name}.adblockplus.org"
    config.vm.network :private_network, ip: ip
    config.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--cpus", 1]

      # Work around https://www.virtualbox.org/ticket/11649
      vb.customize ['modifyvm', :id, '--natdnshostresolver1', 'on']

      setup_path = File.join(REPOSITORY_DIR, "hiera", "roles", "#{role}.yaml")
      setup = YAML.load_file(setup_path) rescue {}
      requirements = setup.fetch("requirements", {})

      requirements.each do |key, value|
        vb.customize ['modifyvm', :id, "--#{key}", "#{value}"]
      end

    end

    # The repository location in the production system's puppet master
    config.vm.synced_folder ".", "/etc/puppet/infrastructure"

    config.vm.provision :shell, :inline => '
      sudo /etc/puppet/infrastructure/hiera/install_precise.py
    '

    config.vm.provision :puppet do |puppet|
      puppet.options = [
        '--environment=development',
        '--external_nodes=/etc/puppet/infrastructure/hiera/puppet_node_classifier.rb',
        '--node_terminus=exec',
        '--verbose',
        '--debug',
      ]
      puppet.manifests_path = 'manifests'
      puppet.manifest_file = 'site.pp'
      puppet.module_path = 'modules'
    end

    yield(config) if block_given?
  end
end

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config_path = File.join(REPOSITORY_DIR, "modules/private/hiera/hosts.yaml")
  config_data = YAML.load_file(config_path)
  servers = config_data["servers"]
  servers.each do |server, items|
    ip = items["ip"][0]
    role = items.fetch("role", "default")
    define_standard_vm(config, server, ip, role)
  end
end
