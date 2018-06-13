#!/bin/sh

current_file_directory=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

rm -rf $current_file_directory/../../volumes/nginx/ssl/*
rm -rf $current_file_directory/../../volumes/nginx/conf.d/*.conf