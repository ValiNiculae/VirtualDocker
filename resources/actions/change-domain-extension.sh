#!/bin/sh

current_file_directory=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )


if [ ! -f $current_file_directory/../../.env ]; then
	echo -e "\e[91mYou don't have an .env file in your docker folder which means you did not create a vm. Please do that first :)\e[0m"
	exit
fi


# load env variables
set -o allexport; source $current_file_directory/../../.env; set +o allexport

# ask for a domain extenson until it gives a corect one
while [[ ! "$domain_extension" =~ ^[[:alpha:]]*$ ]] || [[ $domain_extension = "" ]];
do
	echo -e "\e[36mWhat domain extension do you want? (current:\"\e[33m.$DOMAIN_EXTENSION\e[36m\")\e[0m" >&2
	read -e -p $'\e[32m> \e[0m' domain_extension
	
	if [[ ! "$domain_extension" =~ ^[[:alpha:]]*$ ]]; then
		echo -e "\e[91mINVALID DOMAIN EXTENSION.\e[0m \e[92mPlease try again\e[0m"
	fi
done

# remove any dots from input
domain_extension="${domain_extension//./}"

# update env file and regenerate-configs if extension changed
if [ ! $DOMAIN_EXTENSION = $domain_extension ]; then
	sed -i "s#DOMAIN_EXTENSION=.*#DOMAIN_EXTENSION=$domain_extension#g" $current_file_directory/../../.env

	echo -e "\e[92mDomain extension change succesfully\e[0m"	
	"$current_file_directory/regenerate-configs.sh"
fi