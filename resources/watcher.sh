#!/bin/sh

sha=0
previous_sha=0

PROJECTS_PATH=/docker/projects
NGINX_CONFIG=/docker/machine/volumes/nginx
SSL_FOLDER=/docker/machine/resources/ssl


function create_CA()
{
	if [ ! -f $SSL_FOLDER/vdockerCA.pem ] || [ ! -f $SSL_FOLDER/vdockerCA.key ];  then
		openssl genrsa -out $SSL_FOLDER/vdockerCA.key 2048
		openssl req -x509 -new -nodes -key $SSL_FOLDER/vdockerCA.key -sha256 -days 1024 -out $SSL_FOLDER/vdockerCA.pem -subj "//C=RO\ST=Ilfov\L=Bucuresti\O=VirtualDocker\OU=VD\CN=VirtualDocker"
	fi
}

function generate_certificate_for_domain()
{
	create_CA

	# Create a new private key if one doesnt exist, or use the xeisting one if it does
	if [ -f $SSL_FOLDER/private.key ]; then
	  KEY_OPT="-key"
	else
	  KEY_OPT="-keyout"
	fi

	DOMAIN=$1
	COMMON_NAME=$1
	SUBJECT="/C=RO/ST=None/L=BUCURESTI/O=None/CN=$COMMON_NAME"
	NUM_OF_DAYS=999
	
	openssl req -new -newkey rsa:2048 -sha256 -nodes $KEY_OPT $SSL_FOLDER/private.key -subj "$SUBJECT" -out $SSL_FOLDER/private.csr
	
cat <<EOF >$SSL_FOLDER/v3.ext
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = ${COMMON_NAME}
EOF
	
	openssl x509 -req -in $SSL_FOLDER/private.csr -CA $SSL_FOLDER/vdockerCA.pem -CAkey $SSL_FOLDER/vdockerCA.key -CAcreateserial -out $SSL_FOLDER/private.crt -days $NUM_OF_DAYS -sha256 -extfile $SSL_FOLDER/v3.ext

	# move output files to final filenames
	mv $SSL_FOLDER/private.key $NGINX_CONFIG/ssl/"$DOMAIN.key"
	cp $SSL_FOLDER/private.crt $NGINX_CONFIG/ssl/"$DOMAIN.crt"

	# remove temp file
	rm -f $SSL_FOLDER/private.crt;
}


function build () {
	find $PROJECTS_PATH -mindepth 1 -maxdepth 1 -type d | while read D;
	do
		FOLDER_NAME=${D##*/}
		FOLDER_DOMAIN_NAME="${FOLDER_NAME// /-}.test"
		
		if [ ! -f "$NGINX_CONFIG/conf.d/$FOLDER_DOMAIN_NAME.conf" ] && [ ! "$FOLDER_NAME" = "New folder" ]; then
			cp "$NGINX_CONFIG/conf.d/www.conf.sample" "$NGINX_CONFIG/conf.d/$FOLDER_DOMAIN_NAME.conf"
			
			sed -i "s#{{folder_name}}#${FOLDER_NAME}#g" "$NGINX_CONFIG/conf.d/$FOLDER_DOMAIN_NAME.conf"
			sed -i "s#{{folder_domain}}#${FOLDER_DOMAIN_NAME}#g" "$NGINX_CONFIG/conf.d/$FOLDER_DOMAIN_NAME.conf"

		fi
		
		
		if [ ! -f "$NGINX_CONFIG/ssl/$FOLDER_DOMAIN_NAME" ] && [ ! "$FOLDER_NAME" = "New folder" ]; then
			generate_certificate_for_domain $FOLDER_DOMAIN_NAME
		fi
		
		docker restart machine_nginx_1
	done
}

function compare () {
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