#!/bin/bash
# provision home server

echo "install stuff"
apt-get update && apt-get install -y \
    curl git vim \
	tig ncdu zsh nethogs python3-pip tmux \
	wget jq htop \
	net-tools powertop \
	tree shellcheck bmon \
	pass socat

echo "set me up"
useradd -m -G adm jujhar
mkdir /home/jujhar/.ssh
curl https://github.com/jujhars13.keys > /home/jujhar/.ssh/authorized_keys
chown -R jujhar.jujhar /home/jujhar/.ssh
chmod 700 /home/jujhar/.ssh
chmod 644 /home/jujhar/.ssh/authorized_keys
echo "jujhar ALL=(ALL) NOPASSWD:ALL" | tee -a "/etc/sudoers.d/jujhar"

echo "set screen timeout"
echo -e '\033[9;5]' > /dev/tty1

echo "#\!/bin/sh
export EDITOR=/usr/bin/vim
" | tee /etc/profile.d/z99-custom.sh

echo "install docker"
curl -fsSL https://get.docker.com | sh \
	&& systemctl enable --now docker \
	&& usermod -aG docker "jujhar"

echo "docker compose, make sure you have /bin dir symlinked first"
curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# letsencrypt
# acme.sh --issue -d example.com -w /home/wwwroot/example.com
# curl https://get.acme.sh | sudo sh

# curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - \
# 	&& echo "deb https://apt.kubernetes.io/ kubernetes-$(lsb_release -c -s) main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list \
# 	sudo apt-get update && sudo apt-get install -y kubectl

# install k3s
# curl -sfL https://get.k3s.io | sh -

# helm
# snap install helm --classic
# export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
# # tell helm to look for k8s creds here
# echo "#\!/bin/sh
# export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
# " | tee /etc/profile.d/z99-k3s-helm.sh

# # install metallb
# helm repo add stable https://charts.helm.sh/stable
# helm repo update
# helm install metallb stable/metallb --namespace kube-system \
#   --set configInline.address-pools[0].name=default \
#   --set configInline.address-pools[0].protocol=layer2 \
#   --set configInline.address-pools[0].addresses[0]=192.168.178.20-192.168.178.50

echo "sort our resolv"
systemctl disable systemd-resolved
systemctl stop systemd-resolved
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
" | tee /etc/acpi/lid.sh
