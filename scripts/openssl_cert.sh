#!/usr/bin/env bash

if [[ -z "$1" ]]; then
    echo "Please provide a url to check"
    exit 1
fi

openssl s_client -servername "$1" -connect "$1":443

