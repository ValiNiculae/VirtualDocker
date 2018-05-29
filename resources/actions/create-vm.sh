#!/bin/sh


#   ____  _  _  __ _   ___  ____  __  __   __ _  ____ 
#  (  __)/ )( \(  ( \ / __)(_  _)(  )/  \ (  ( \/ ___)
#   ) _) ) \/ (/    /( (__   )(   )((  O )/    /\___ \
#  (__)  \____/\_)__) \___) (__) (__)\__/ \_)__)(____/
#

# usage: get_projects_path 
# return path to projects folder
get_projects_path()
{
	while [ ! -d "${PROJECTS_DIRECTORY_PATH}" ]
	do
		echo -e "\e[36mWhere can we find your projects folder?\e[0m" >&2
		read -e -p $'\e[32m> \e[0m' PROJECTS_DIRECTORY_PATH
						
		PROJECTS_DIRECTORY_PATH=$(realpath "$PROJECTS_DIRECTORY_PATH")
			
		if [ ! -d "$PROJECTS_DIRECTORY_PATH" ]; then
			read -e -p $'\e[91mPath does not exist!\e[0m \e[36mWould you like to create it for you?\e[0m (y/n) ' RESPONSE
			
			if [ $RESPONSE = "y" ]; then
				mkdir -p "${PROJECTS_DIRECTORY_PATH}"
			fi
		fi
	done
	
	echo "$PROJECTS_DIRECTORY_PATH"
}

# usage: create_VM <machine_name>
create_VM()
{
	# default VM settings
	CPU="1"
	DISK_SIZE="10000"
	RAM="2048"
	NETWORK="192.168.50.1/24"		
		
	# CREATE VM
	docker-machine create --virtualbox-cpu-count $CPU --virtualbox-disk-size $DISK_SIZE --virtualbox-memory $RAM --driver virtualbox --virtualbox-hostonly-cidr $NETWORK $1
	docker-machine stop $1
}

# usage: install_docker_machine
install_docker_machine()
{
	if [ -x "$(command -v docker-machine)" ]; then
		return 1;
	fi
	
	echo -e "\e[91mI can't find 'docker-machine' in your PATH\e[0m"
	echo -e "\e[36mInstalling docker-machine\e[0m"
	
	base=https://github.com/docker/machine/releases/download/v0.14.0 &&
	mkdir -p "$HOME/bin" &&
	curl -L $base/docker-machine-Windows-x86_64.exe > "$HOME/bin/docker-machine.exe" &&
	chmod +x "$HOME/bin/docker-machine.exe"
}


# usage: add_shared_folder <machine_name> <folder_to_share>
add_shared_folders()
{
	if ! type "$VBOX_MSI_INSTALL_PATH"vboxmanage &> /dev/null; then
		echo -e "\e[91mWe can not find \"vboxmanage\" anywhere. Did you installed VirtualBox?\e[0m" >&2
		exit;
	fi

	# SHARE FOLDERS
	echo "Adding shared folders" >&2
	echo "${2}" >&2
	"$VBOX_MSI_INSTALL_PATH"vboxmanage sharedfolder add $1 --name "docker/machine" --hostpath $(PWD) --automount
	"$VBOX_MSI_INSTALL_PATH"vboxmanage sharedfolder add $1 --name "docker/projects" --hostpath "$2" --automount	
}


# usage: generate_nginx_config <local_projects_path>
generate_nginx_config()
{
	HOSTS_IP=$(docker-machine ip $MACHINE_NAME)
	NGINX_CONFIG=$(pwd)/volumes/nginx/conf.d

	for d in "$1"/*/ ; do
		FOLDER_NAME=$(basename "$d")
		FOLDER_DOMAIN_NAME=$(basename "${d// /-}").local	
		
		HOSTS+="$HOSTS_IP $FOLDER_DOMAIN_NAME\n"	
	done
	
	HOSTS+="$HOSTS_IP docker\n"
	
	echo "$HOSTS"
}


#   _  _   __   __  __ _ 
#  ( \/ ) / _\ (  )(  ( \
#  / \/ \/    \ )( /    /
#  \_)(_/\_/\_/(__)\_)__)

LOCAL_PROJECTS_PATH=$(get_projects_path)
PROJECT_NAME=$(basename $LOCAL_PROJECTS_PATH)

# 1 - install docker-machine if is missing
install_docker_machine

echo -e "\e[36mNow lets build a VirtualBox machine. What do you want to call it?\e[0m" >&2
read -e -p $'\e[32m> \e[0m' MACHINE_NAME

# 2 - create a VM using boot2docker.iso
create_VM $MACHINE_NAME

# 3 - add shared folder to the docker and projects folder.
add_shared_folders $MACHINE_NAME "$LOCAL_PROJECTS_PATH"

# 4 - start machine and add a small provisioning script that will run on every VM boot
docker-machine start $MACHINE_NAME
docker-machine ssh $MACHINE_NAME "sudo sh /docker/machine/resources/boot.sh"	

# 5- start all containers
docker-machine ssh $MACHINE_NAME "cd /docker/machine && docker-compose up -d"

# this needs to be here
PROJECTS_DIRECTORY_PATH=/docker/projects/

HOSTS=$(generate_nginx_config "$LOCAL_PROJECTS_PATH")

# write to ENV file
cp .env.sample .env
sed -i "s#PROJECTS_PATH=.*#PROJECTS_PATH=$PROJECTS_DIRECTORY_PATH#g" .env 
sed -i "s#LOCAL_PROJECTS_PATH=.*#LOCAL_PROJECTS_PATH=${LOCAL_PROJECTS_PATH}#g" .env 
sed -i "s#DOCKER_MACHINE_NAME=.*#DOCKER_MACHINE_NAME=${MACHINE_NAME}#g" .env 
sed -i "s#USE_VM=.*#USE_VM=${USE_VM}#g" .env 


# hosts settings
echo -e "\e[92mDon't forget to update your hosts file with the following: "
echo -e "\e[33m# docker settings"
echo -e "$HOSTS"


# finish line
echo -e "\e[32mYour \e[33m$MACHINE_NAME\e[0m machine was created successfully."
echo -e "\e[32mYou can connect to it using the following command:\e[0m \"\e[33mdocker-machine ssh $MACHINE_NAME\e[0m\""

