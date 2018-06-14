#!/bin/sh

# $1 - folder name
# $2 - domain extension

current_file_directory=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
nginx_volume=$current_file_directory/../../volumes/nginx

set -o allexport; source $current_file_directory/../../.env; set +o allexport

folder_name="$1"
domain_name="${folder_name// /-}.$2"

cp "$nginx_volume/conf.d/www.conf.sample" "$nginx_volume/conf.d/$domain_name.conf"

sed -i "s#{{folder_name}}#${folder_name}#g" "$nginx_volume/conf.d/$domain_name.conf"
sed -i "s#{{folder_domain}}#${domain_name}#g" "$nginx_volume/conf.d/$domain_name.conf"