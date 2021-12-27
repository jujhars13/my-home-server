#!/bin/bash
# provision home server

echo "sudoers"
echo "jujhar ALL=(ALL) NOPASSWD:ALL" | sudo tee -a "/etc/sudoers.d/jujhar"

echo "set screen timeout"
echo -e '\033[9;5]' > /dev/tty1

echo "install stuff"
sudo apt-get update && sudo apt-get install -y \
    git vim \
	tig ncdu zsh nethogs python3-pip tmux curl \
	wget jq htop \
	net-tools powertop \
	tree shellcheck lastpass-cli bmon \
	pass socat xstow

echo "install docker"
curl -fsSL https://get.docker.com | sudo sh \
	&& sudo systemctl enable --now docker \
	&& sudo usermod -aG docker "jujhar"

# letsencrypt
# acme.sh --issue -d example.com -w /home/wwwroot/example.com
curl https://get.acme.sh | sudo sh

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - \
	&& echo "deb https://apt.kubernetes.io/ kubernetes-$(lsb_release -c -s) main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list \
	sudo apt-get update && sudo apt-get install -y kubectl

# install k3s
curl -sfL https://get.k3s.io | sh -

# helm
snap install helm --classic
# tell helm hwere to look for k8s creds
echo "#\!/bin/sh
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
" | tee /etc/profile.d/z99-k3s-helm.sh

echo "sort our resolv"
sudo systemctl disable systemd-resolved
sudo systemctl stop systemd-resolved
# disable systemd sitting on port53
echo DNSStubListener=no | sudo tee -a /etc/systemd/resolved.conf

echo DNS=192.168.178.1 | sudo tee -a /etc/systemd/resolved.conf
echo FallbackDNS=1.1.1.1 | sudo tee -a /etc/systemd/resolved.conf
echo Domains=local | sudo tee -a /etc/systemd/resolved.conf
sudo ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf

# disable sleep on lid close
echo 'HandleLidSwitch=ignore' | sudo tee --append /etc/systemd/logind.conf
echo 'HandleLidSwitchDocked=ignore' | sudo tee --append /etc/systemd/logind.conf
echo 'event=button/lid.*' | sudo tee --append /etc/acpi/events/lm_lid
echo 'action=/etc/acpi/lid.sh' | sudo tee --append /etc/acpi/events/lm_lid
sudo mkdir -p /etc/acpi
sudo touch /etc/acpi/lid.sh
sudo chmod +x /etc/acpi/lid.sh

echo "#\!/bin/bash

USER=jujhar

grep -q close /proc/acpi/button/lid/*/state

if [ $? = 0 ]; then
  su -c  \"sleep 1 && xset -display :0.0 dpms force off\" - \$USER
fi

grep -q open /proc/acpi/button/lid/*/state

if [ $? = 0 ]; then
  su -c  \"xset -display :0 dpms force on &> /tmp/screen.lid\" - \$USER
fi
" | sudo tee /etc/acpi/lid.sh
