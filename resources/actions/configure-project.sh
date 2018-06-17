#!/bin/sh

current_file_directory=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
set -o allexport; source $current_file_directory/../../.env; set +o allexport

IFS=$'\n'
PS3='Please enter your choice: '

# ====================================================================================
dirs=($(find $LOCAL_PROJECTS_PATH -mindepth 1 -maxdepth 1 -type d -printf "%f\n" ))
echo -e "\e[36mWhat project do you want to configure?\e[0m"
select opt in "${dirs[@]}"; 
do
	if [[ " ${dirs[@]} " =~ " ${opt} " ]]; then
		break
	else
		echo -e "\e[91mThat option does not exists. Please try again!\e[0m"
	fi
done
	
PROJECT=$opt	

echo -e "\n"
# ====================================================================================
dirs=(".")
dirs+=($(find "$LOCAL_PROJECTS_PATH/$PROJECT" -mindepth 1 -maxdepth 1 -type d -printf "%f\n" ))
echo -e "\e[36mWhat is your nginx root/public directory?\e[0m"
select opt in "${dirs[@]}"; 
do
	if [[ " ${dirs[@]} " =~ " ${opt} " ]]; then
		if [ "$opt" = "." ]; then
			opt=""
		fi
		break
	else
		echo -e "\e[91mThat option does not exists. Please try again!\e[0m"
	fi
done

PROJECT_ROOT=$opt

echo -e "\n"
# ====================================================================================
echo -e "\e[36mWhat domain extension do you want? (default:\"\e[33m.test\e[36m\")\e[0m" >&2
read -e -p $'\e[32m> \e[0m' domain_extension
PROJECT_DOMAIN_EXTENSION="${domain_extension//./}"
if [ -z "$PROJECT_DOMAIN_EXTENSION" ]; then
	PROJECT_DOMAIN_EXTENSION="test"
fi

PROJECT_DOMAIN_NAME="${PROJECT// /-}.$PROJECT_DOMAIN_EXTENSION"



rm -rf $current_file_directory/../../volumes/nginx/ssl/${PROJECT}.*
rm -rf $current_file_directory/../../volumes/nginx/conf.d/${PROJECT}.*

$current_file_directory/../scripts/nginx-config-generator.sh "$PROJECT" "$PROJECT_DOMAIN_NAME" "$PROJECT_ROOT"
$current_file_directory/../scripts/certificate-generator.sh "$PROJECT_DOMAIN_NAME"

docker-machine ssh "$MACHINE_NAME" "docker restart machine_nginx_1"


HOSTS="$(docker-machine ip $MACHINE_NAME) $PROJECT_DOMAIN_NAME"

# hosts settings
echo -e "\e[92mDon't forget to update your hosts file with the following: "
echo -e "$HOSTS"