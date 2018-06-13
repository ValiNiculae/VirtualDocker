#!/bin/sh

current_file_directory=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )


# get or create projects path
while [ ! -d "${projects_directory_path}" ]
do
	echo -e "\e[36mWhere can we find your projects folder?\e[0m" >&2
	read -e -p $'\e[32m> \e[0m' projects_directory_path
					
	projects_directory_path=$(realpath "$projects_directory_path")
		
	if [ ! -d "$projects_directory_path" ]; then
		read -e -p $'\e[91mPath does not exist!\e[0m \e[36mWould you like to create it for you?\e[0m (y/n) ' RESPONSE
		
		if [ $RESPONSE = "y" ]; then
			mkdir -p "${projects_directory_path}"
		fi
	fi
done



# usage: generate_nginx_config <local_projects_path>
# function generate_nginx_config()
# {
	# docker_machine_ip=$(docker-machine ip $MACHINE_NAME)
	# NGINX_CONFIG=$(pwd)/volumes/nginx/conf.d

	# for d in "$1"/*/ ; do
		# folder_name=$(basename "$d")
		# domain_name=$(basename "${d// /-}").test	
		# ./resources/scripts/nginx-config-generator.sh $folder_name
		
		# #generate ssl certificates
		# ./resources/scripts/certificate-generator.sh ${domain_name// /-}.test
		
		# hosts+="$docker_machine_ip $domain_name\n"
	# done
	
	# hosts+="$docker_machine_ip docker\n"
	
	# echo "$hosts"
# }


echo -e "\e[36mNow lets build a VirtualBox machine. What do you want to call it?\e[0m" >&2
read -e -p $'\e[32m> \e[0m' machine_name

# docker machine setup
$current_file_directory/setup-docker-machine.sh $machine_name


#HOSTS=$(generate_nginx_config "$LOCAL_PROJECTS_PATH")

# write to ENV file
cp .env.sample .env

sed -i "s#LOCAL_PROJECTS_PATH=.*#LOCAL_PROJECTS_PATH=${projects_directory_path}#g" .env 
sed -i "s#MACHINE_NAME=.*#MACHINE_NAME=${machine_name}#g" .env 


# hosts settings
echo -e "\e[92mDon't forget to update your hosts file with the following: "
echo -e "\e[33m# docker settings"
echo -e "$HOSTS"


# finish line
echo -e "\e[32mYour \e[33m$MACHINE_NAME\e[0m \e[32m machine was created successfully."
echo -e "\e[32mYou can connect to it using the following command:\e[0m \"\e[33mdocker-machine ssh $MACHINE_NAME\e[0m\""

