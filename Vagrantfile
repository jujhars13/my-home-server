# vagrant version to test desktop options
# taken from https://github.com/davestephens/ansible-nas
Vagrant.require_version ">= 2.2.2"

Vagrant.configure(2) do |config|
  # ubuntu 20.10 - non LTS
  config.vm.box = "ubuntu/impish64" #21.10
  #config.vm.box = "ubuntu/focal64" #20.00
  config.vm.network "private_network", ip: "172.30.1.10"
  config.ssh.insert_key = true

  config.vm.provider "virtualbox" do |v|
    v.memory = 8000
    v.cpus = 2
  end

  config.vm.provision "prepare-installation", privileged: true, type: "shell", inline: <<-SHELL
  ls /vagrant
  /vagrant/provision_ubuntu_server.sh
  # ansible-pull -v --url https://github.com/jujhars13/my-ubuntu-setup.git
  #apt-get install -y python3-pip python3-dev libffi-dev libssl-dev openssh-server
  #pip3 install ansible markupsafe
  SHELL

  # config.vm.provision "ansible_local" do |ansible|
  #   #ansible.compatibility_mode = "2.0"
  #   ansible.playbook = "local.yml"
  #   ansible.galaxy_role_file = "ansible-galaxy.yml"
  #   ansible.become = true
  # end

end
