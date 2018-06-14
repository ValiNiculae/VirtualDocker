#!/bin/sh

# $1 - projects_path

current_file_directory=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
projects_path=$1


# load and .env file
set -o allexport;
if [ -f $current_file_directory/../../.env ]; then
	source $docker_path/.env;
else
	source $docker_path/.env.sample; 
fi
set +o allexport


# loop through all projects
find "$1" -mindepth 1 -maxdepth 1 -type d | while read D;
do
	folder_name=${D##*/}
	domain_name="${folder_name// /-}.$DOMAIN_EXTENSION"
	
	if [ "$folder_name" = "New folder" ]; then
		continue
	fi
	
	# skip if we already have a NGINX config for this folder
	if [ ! -f "$current_file_directory/../../volumes/nginx/conf.d/$domain_name.conf" ]; then
		$current_file_directory/nginx-config-generator.sh "$folder_name" "$DOMAIN_EXTENSION"
	fi
	
	# skip if we already have a ssl certificate for this comain
	if [ ! -f "$current_file_directory/../../volumes/nginx/ssl/$domain_name.key" ] || [ ! -f "$docker_path/volumes/nginx/ssl/$domain_name.crt" ]; then
		#generate ssl certificates
		$current_file_directory/certificate-generator.sh "${domain_name// /-}.$DOMAIN_EXTENSION"
	fi
done