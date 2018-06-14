#!/bin/sh

# $1 - folder name
# $2 - domain extension

current_file_directory="$( cd "$(dirname "$0")" ; pwd -P )"
nginx_volume=$(realpath "$current_file_directory/../../volumes/nginx")

set -o allexport; source $current_file_directory/../../.env; set +o allexport


cp "$nginx_volume/conf.d/www.conf.sample" "$nginx_volume/conf.d/$2.conf"

sed -i "s#{{folder_name}}#${1}#g" "$nginx_volume/conf.d/$2.conf"
sed -i "s#{{folder_domain}}#${2}#g" "$nginx_volume/conf.d/$2.conf"