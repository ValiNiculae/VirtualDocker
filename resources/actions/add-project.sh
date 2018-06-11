#!/bin/sh

set -o allexport
source ./.env
set +o allexport

IFS=$'\n'
PS3='Please enter your choice: '

# ====================================================================================
dirs=($(find $LOCAL_PROJECTS_PATH -mindepth 1 -maxdepth 1 -type d -printf "%f\n" ))
echo -e "\e[36mWhat project do you want to add?\e[0m"
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



cp "./volumes/nginx/conf.d/www.conf.sample" "./volumes/nginx/conf.d/$PROJECT_DOMAIN_NAME.conf"

sed -i "s#{{folder_name}}#${PROJECT}#g" "volumes/nginx/conf.d/$PROJECT_DOMAIN_NAME.conf"
sed -i "s#{{folder_domain}}#${PROJECT_DOMAIN_NAME}#g" "volumes/nginx/conf.d/$PROJECT_DOMAIN_NAME.conf"
sed -i "s#root .*#root '/applications/$PROJECT/$PROJECT_ROOT';#g" "volumes/nginx/conf.d/$PROJECT_DOMAIN_NAME.conf"

docker-machine ssh "$MACHINE_NAME" "docker restart machine_nginx_1"

HOSTS=$(docker-machine ip $MACHINE_NAME)
HOSTS+="  $PROJECT_DOMAIN_NAME"
# hosts settings
echo -e "\e[92mDon't forget to update your hosts file with the following: "
echo -e "$HOSTS"