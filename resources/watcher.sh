#!/bin/sh

sha=0
previous_sha=0

PROJECTS_PATH=/docker/projects #../projects
NGINX_CONFIG=/docker/machine/volumes/nginx/conf.d # ./volumes/nginx/conf.d


build () {
	find $PROJECTS_PATH -mindepth 1 -maxdepth 1 -type d | while read D;
	do
		FOLDER_NAME=${D##*/}
		FOLDER_DOMAIN_NAME="${FOLDER_NAME// /-}.test"
		
		if [ ! -f "$NGINX_CONFIG/$FOLDER_DOMAIN_NAME.conf" ] && [ ! "$FOLDER_NAME" = "New folder" ]; then
			cp "$NGINX_CONFIG/www.conf.sample" "$NGINX_CONFIG/$FOLDER_DOMAIN_NAME.conf"
			
			sed -i "s#{{folder_name}}#${FOLDER_NAME}#g" "$NGINX_CONFIG/$FOLDER_DOMAIN_NAME.conf"
			sed -i "s#{{folder_domain}}#${FOLDER_DOMAIN_NAME}#g" "$NGINX_CONFIG/$FOLDER_DOMAIN_NAME.conf"
			
			echo $FOLDER_DOMAIN_NAME
		fi
		
		docker restart machine_nginx_1
	done
}

compare () {
    sha=`ls -l "$PROJECTS_PATH" | grep "^d" | sha1sum`
    if [ ! "$sha" = "$previous_sha" ]; then 
		build
		previous_sha=$sha
	fi
}

# start program
while true; 
do
	compare
	read -s -t 1 && (build)
done