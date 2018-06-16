#!/bin/sh

current_file_directory=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
set -o allexport; source $current_file_directory/../../.env; set +o allexport

rm -rf $current_file_directory/../../volumes/nginx/ssl/*
rm -rf $current_file_directory/../../volumes/nginx/conf.d/*.conf

$current_file_directory/../scripts/configs-generator.sh $LOCAL_PROJECTS_PATH

if [ $(docker-machine status $MACHINE_NAME) = "Running" ]; then
	docker-machine ssh $MACHINE_NAME "cd /docker/machine && docker-compose restart nginx"
else
	docker-machine start $MACHINE_NAME;
fi

