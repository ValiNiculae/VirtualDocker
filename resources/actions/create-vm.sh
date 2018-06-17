#!/bin/sh

current_file_directory=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
set -o allexport; source $current_file_directory/../../.env.sample; set +o allexport


# get or create projects path
while [ ! -d "${projects_directory_path}" ]
do
	echo -e "\e[36mWhere can we find your projects folder?\e[0m" >&2
	read -e -p $'\e[32m> \e[0m' projects_directory_path
					
	projects_directory_path=$(realpath "$projects_directory_path")
		
	if [ ! -d "$projects_directory_path" ]; then
		read -e -p $'\e[91mPath does not exist!\e[0m \e[36mWould you like to create it for you?\e[0m (y/n) ' response
		
		if [ $response = "y" ]; then
			mkdir -p "${projects_directory_path}"
		fi
	fi
done

# get machine name
echo -e "\e[36mNow lets build a VirtualBox machine. What do you want to call it?\e[0m" >&2
read -e -p $'\e[32m> \e[0m' machine_name


# docker machine setup
$current_file_directory/../scripts/setup-docker-machine.sh ${machine_name} $(realpath "$current_file_directory/../../") $projects_directory_path

# write to ENV file
cp .env.sample .env

sed -i "s#LOCAL_PROJECTS_PATH=.*#LOCAL_PROJECTS_PATH=${projects_directory_path}#g" .env 
sed -i "s#MACHINE_NAME=.*#MACHINE_NAME=${machine_name}#g" .env 

$current_file_directory/../scripts/configs-generator.sh "$projects_directory_path";

# generate configs and certificates for all folders
docker_machine_ip=$(docker-machine ip $machine_name)

for d in "$projects_directory_path"/*/ ; do
	domain_name=$(basename "${d// /-}").$DOMAIN_EXTENSION
	hosts+="$docker_machine_ip $domain_name\n"
done

hosts+="$docker_machine_ip docker\n"


# hosts settings
echo -e "\e[92mDon't forget to update your hosts file with the following: "
echo -e "\e[33m# docker settings"
echo -e "$hosts"


# finish line
echo -e "\e[32mYour \e[33m$MACHINE_NAME\e[0m \e[32m machine was created successfully."
echo -e "\e[32mYou can connect to it using the following command:\e[0m \"\e[33mdocker-machine ssh $MACHINE_NAME\e[0m\""

