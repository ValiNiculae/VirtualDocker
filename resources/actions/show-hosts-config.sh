#!/bin/sh

current_file_directory=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
set -o allexport; source $current_file_directory/../../.env; set +o allexport

# generate configs and certificates for all folders
docker_machine_ip=$(docker-machine ip $MACHINE_NAME)

for d in "$LOCAL_PROJECTS_PATH"/*/ ; do
	domain_name=$(basename "${d// /-}").$DOMAIN_EXTENSION
	hosts+="$docker_machine_ip $domain_name\n"
done

hosts+="$docker_machine_ip docker\n"

# hosts settings
echo -e "\e[92mYou need to have this settings in your windows \e[33mhosts\e[0m \e[92mfile:\e[0m"
echo -e "\e[33m# docker settings"
echo -e "$hosts"