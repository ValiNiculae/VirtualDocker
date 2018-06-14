#!/bin/sh

readonly projects_path=/docker/projects
readonly docker_path=/docker/machine

set -o allexport;
if [ -f $docker_path/.env ]; then
	source $docker_path/.env; 
else
echo "test"; exit;
	source $docker_path/.env.sample;
fi
set +o allexport

sha=0
previous_sha=0

function build()
{
	$docker_path/resources/scripts/configs-generator.sh "$(realpath $projects_path)";
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

