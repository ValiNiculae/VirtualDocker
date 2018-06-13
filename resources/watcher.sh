#!/bin/sh

sha=0
previous_sha=0

readonly PROJECTS_PATH=/docker/projects
readonly NGINX_CONFIG=/docker/machine/volumes/nginx
readonly SSL_FOLDER=/docker/machine/resources/ssl


# creates a Certificate Authority if we don't have one
function create_CA()
{
	if [ ! -f $SSL_FOLDER/vdockerCA.pem ] || [ ! -f $SSL_FOLDER/vdockerCA.key ];  then
		openssl genrsa -out $SSL_FOLDER/vdockerCA.key 2048
		openssl req -x509 -new -nodes -key $SSL_FOLDER/vdockerCA.key -sha256 -days 1024 -out $SSL_FOLDER/vdockerCA.pem -subj "//C=RO\ST=Ilfov\L=Bucuresti\O=VirtualDocker\OU=VD\CN=VirtualDocker"
	fi
}


function build () {
	# for each folder in $PROJECTS_PATH
	find $PROJECTS_PATH -mindepth 1 -maxdepth 1 -type d | while read D;
	do
		FOLDER_NAME=${D##*/}
		FOLDER_DOMAIN_NAME="${FOLDER_NAME// /-}.test"
		
		# skip if we already have a NGINX config for this folder
		if [ ! -f "$NGINX_CONFIG/conf.d/$FOLDER_DOMAIN_NAME.conf" ] && [ ! "$FOLDER_NAME" = "New folder" ]; then
			cp "$NGINX_CONFIG/conf.d/www.conf.sample" "$NGINX_CONFIG/conf.d/$FOLDER_DOMAIN_NAME.conf"
			
			sed -i "s#{{folder_name}}#${FOLDER_NAME}#g" "$NGINX_CONFIG/conf.d/$FOLDER_DOMAIN_NAME.conf"
			sed -i "s#{{folder_domain}}#${FOLDER_DOMAIN_NAME}#g" "$NGINX_CONFIG/conf.d/$FOLDER_DOMAIN_NAME.conf"

		fi
		
		# skip if we already have a ssl certificate for this comain
		if [ [ ! -f "$NGINX_CONFIG/ssl/$FOLDER_DOMAIN_NAME.key" ] || [ ! -f "$NGINX_CONFIG/ssl/$FOLDER_DOMAIN_NAME.crt" ] ] && [ ! "$FOLDER_NAME" = "New folder" ]; then
			./scripts/certificate-generator.sh $FOLDER_DOMAIN_NAME
		fi
		
		docker restart machine_nginx_1
	done
}


function compare () {
    sha=`ls -l "$PROJECTS_PATH" | grep "^d" | sha1sum`
	
	# something changed - a folder was added or removed
    if [ ! "$sha" = "$previous_sha" ]; then 
		build
		previous_sha=$sha
	fi
}

if [ $# -eq 0 ]; then
    build
else
	# start watcher
	while true; 
	do
		compare
		read -s -t 1 && (build)
	done
fi

