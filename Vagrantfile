def define_standard_vm(config, name, address)
  config.vm.define name do |config|
    config.vm.box = 'precise64'
    config.vm.box_url = 'http://files.vagrantup.com/precise64.box'
    config.vm.network :hostonly, address

    config.vm.provision :puppet do |puppet|
      puppet.manifests_path = 'manifests'
      puppet.manifest_file = name.to_s() + '.pp'
      puppet.module_path = 'modules'
    end

    yield(config) if block_given?
  end

end

Vagrant::Config.run do |config|
  define_standard_vm config, :webserver, '10.8.0.97' do |config|
    local_anwiki_repository = '../anwiki'
    if File.directory?(local_anwiki_repository)
      config.vm.share_folder('local_anwiki_repository',
        '/mnt/local_anwiki_repository', local_anwiki_repository)
    end
  end

  define_standard_vm config, :monitoringserver, '10.8.0.98'
end
