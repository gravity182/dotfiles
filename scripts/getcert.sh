#!/usr/bin/env bash
#
# display certs from an https url

if [[ -z "$1" ]]; then
    echo "Please provide a url to check"
    exit 1
fi

url="$1"
parsed_url=$(printf "%s" "$url" | sed 's|https://||g')
printf '\n' | openssl s_client -connect "$parsed_url":443 -showcerts | openssl x509 -noout -text

