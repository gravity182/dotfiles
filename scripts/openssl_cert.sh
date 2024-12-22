#!/usr/bin/env bash

if [[ -z "$1" ]]; then
    echo "Please provide a url to check"
    exit 1
fi

domain="$1"
openssl s_client -servername "$domain" -connect "$domain":443

