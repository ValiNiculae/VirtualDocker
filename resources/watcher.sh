#!/bin/sh

readonly projects_path=/docker/projects
readonly docker_path=/docker/machine

current_file_directory=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

if [ -f $current_file_directory/../../.env ]; then
	set -o allexport; source $docker_path/.env; set +o allexport
else
	set -o allexport; source $docker_path/.env.sample; set +o allexport
fi

sha=0
previous_sha=0

function build()
{
	$current_file_directory/scripts/configs-generator.sh $1
	cd /docker/machine && docker-compose restart nginx
}

# start watcher
while true; 
do
	sha=`ls -l "$projects_path" | grep "^d" | sha1sum`
	
	# something changed - a folder was added or removed
	if [ ! "$sha" = "$previous_sha" ]; then 
		build $projects_path
		
		previous_sha=$sha
	fi
	read -s -t 1 && (build $projects_path )
done

