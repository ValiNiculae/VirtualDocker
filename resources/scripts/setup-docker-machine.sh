#!/bin/sh

# $1 - machine name
# $2 - docker path
# $3 - projects path

# stop if we dont have virtualbox installed
if ! type "$VBOX_MSI_INSTALL_PATH"vboxmanage &> /dev/null; then
	echo -e "\e[91mWe can not find \"vboxmanage\" anywhere. Did you installed VirtualBox?\e[0m" >&2
	exit;
fi

# install docker-machine
if [ ! -x "$(command -v docker-machine)" ]; then

	echo -e "\e[91mI can't find 'docker-machine' in your PATH\e[0m"
	echo -e "\e[36mInstalling docker-machine\e[0m"

	base=https://github.com/docker/machine/releases/download/v0.14.0 &&
	mkdir -p "$HOME/bin" &&
	curl -L $base/docker-machine-Windows-x86_64.exe > "$HOME/bin/docker-machine.exe" &&
	chmod +x "$HOME/bin/docker-machine.exe"
fi

# default VM settings
CPU="1"
DISK_SIZE="10000"
RAM="2048"
NETWORK="192.168.50.1/24"		
	
# CREATE VM
docker-machine create --virtualbox-cpu-count $CPU --virtualbox-disk-size $DISK_SIZE --virtualbox-memory $RAM --driver virtualbox --virtualbox-hostonly-cidr $NETWORK $1
docker-machine stop $1

# SHARE FOLDERS
"$VBOX_MSI_INSTALL_PATH"vboxmanage sharedfolder add $1 --name "docker/machine" --hostpath "$2" --automount
"$VBOX_MSI_INSTALL_PATH"vboxmanage sharedfolder add $1 --name "docker/projects" --hostpath "$3" --automount	
"$VBOX_MSI_INSTALL_PATH"vboxmanage setextradata $1 VBoxInternal2/SharedFoldersEnableSymlinksCreate/docker/projects 1

docker-machine start $1
docker-machine ssh $1 "sudo sh /docker/machine/resources/boot.sh"	
docker-machine ssh $1 "cd /docker/machine && docker-compose up -d"