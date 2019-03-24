#!/bin/sh

current_file_directory=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
set -o allexport; source $current_file_directory/../../.env; set +o allexport

hosts+="123 my.host\n"
hosts+="323 other.host"

sed -ni "/vdocker-config/{p;:a;N;/vdocker/!ba;s/.*\n/${hosts}\n/};p" test.txt