def define_standard_vm(config, host_name, ip)
  config.vm.define host_name do |config|
    config.vm.box = 'precise64'
    config.vm.box_url = 'http://files.vagrantup.com/precise64.box'
    config.vm.host_name = "#{host_name}.adblockplus.org"
    config.vm.network :hostonly, ip, { nic_type: 'Am79C970A' }
    config.vm.customize ["modifyvm", :id, "--cpus", 1]

    config.vm.provision :shell, :inline => '
if ! test -f /usr/bin/puppet; then
  sudo apt-get update && sudo apt-get install -y puppet
fi'

    manifest_files = ['vagrant.pp', 'nodes.pp']
    manifest_files.each do |manifest_file|
      config.vm.provision :puppet do |puppet|
        puppet.options = ['--environment=development']
        puppet.manifests_path = 'manifests'
        puppet.manifest_file = manifest_file
        puppet.module_path = 'modules'
      end
    end

    yield(config) if block_given?
  end
end

Vagrant::Config.run do |config|
  define_standard_vm config, 'server1', '10.8.0.105'
  define_standard_vm config, 'server3', '10.8.0.99'
  define_standard_vm config, 'server4', '10.8.0.98'
  define_standard_vm config, 'server5', '10.8.0.100'
  define_standard_vm config, 'server6', '10.8.0.101'
  define_standard_vm config, 'server7', '10.8.0.102'
  define_standard_vm config, 'server8', '10.8.0.103'
  define_standard_vm config, 'server9', '10.8.0.104'
  define_standard_vm config, 'server10', '10.8.0.105' do |config|
    config.vm.customize ["modifyvm", :id, "--memory", 1024]
  end
  define_standard_vm config, 'server11', '10.8.0.106'
  define_standard_vm config, 'server12', '10.8.0.107'
  define_standard_vm config, 'server13', '10.8.0.108'
  define_standard_vm config, 'server14', '10.8.0.109'
  define_standard_vm config, 'server15', '10.8.0.110'
end
