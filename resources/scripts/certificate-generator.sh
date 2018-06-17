#!/bin/sh

# $1 - domain name

current_file_directory="$( cd "$(dirname "$0")" ; pwd -P )"
nginx_volume=$(realpath $current_file_directory/../../volumes/nginx)

mkdir -p $current_file_directory/../ssl
cd $(realpath "$current_file_directory/../ssl")

if [[ "$(uname -a)" = *"MINGW"* ]]; then
	subjectCA="//C=RO\ST=Ilfov\L=Bucuresti\O=VirtualDocker\OU=VD\CN=VirtualDocker"
	subjectDomain="//C=RO\ST=None\L=BUCURESTI\O=None\CN=$1"
else
	subjectCA="/C=RO/ST=Ilfov/L=Bucuresti/O=VirtualDocker/OU=VD/CN=VirtualDocker"
	subjectDomain="/C=RO/ST=None/L=BUCURESTI/O=None/CN=$1"
fi

if [ ! -f vdockerCA.pem ] || [ ! -f vdockerCA.key ];  then

	openssl genrsa -out vdockerCA.key 2048
	openssl req -x509 -new -nodes -key vdockerCA.key -sha256 -days 1024 -out vdockerCA.pem -subj $subjectCA
	
fi

# Create a new private key if one doesnt exist, or use the existing one if it does
if [ -f private.key ]; then
  KEY_OPT="-key"
else
  KEY_OPT="-keyout"
fi

# build config file for a certificate
cat <<EOF >v3.ext
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = ${1}
DNS.2 = *.${1}
EOF
	
# build the certificate
openssl req -new -newkey rsa:2048 -sha256 -nodes $KEY_OPT private.key -subj $subjectDomain -out private.csr
openssl x509 -req -in private.csr -CA vdockerCA.pem -CAkey vdockerCA.key -CAcreateserial -out private.crt -days 999 -sha256 -extfile v3.ext

# move output files to final filenames
cp private.key $nginx_volume/ssl/"$1.key"
mv private.crt $nginx_volume/ssl/"$1.crt"
