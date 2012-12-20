Vagrant::Config.run do |config|
  config.vm.box = "precise64"
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"
  config.vm.network :hostonly, "10.8.0.97"

  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = 'manifests'
    puppet.manifest_file = 'vagrant.pp'
    puppet.module_path = 'modules'
  end

  local_anwiki_repository = "../anwiki"
  if File.directory?(local_anwiki_repository)
    config.vm.share_folder("local_anwiki_repository",
      "/mnt/local_anwiki_repository", local_anwiki_repository)
  end
end
