#!/usr/bin/env bash

COLOR_BOLD_RED='\033[1;31m'
COLOR_RESET='\033[0m'

DEFAULT_PROVIDER='openssl'
DEFAULT_LENGTH=14
LENGTH_RE='^[1-9][0-9]*$'

echo "Select provider [default: $DEFAULT_PROVIDER]"
echo "1: openssl"
echo "2: pwgen"
read provider
if [[ -z "$provider" ]]; then
    provider=${DEFAULT_PROVIDER}
fi

echo "Select length [default: $DEFAULT_LENGTH]"
read length
if [[ -z "$length" ]]; then
    length=${DEFAULT_LENGTH}
fi
if [[ ! "$length" =~ $LENGTH_RE ]]; then
    echo -e "${COLOR_BOLD_RED}Error: invalid length!${COLOR_RESET}"
    exit 1
fi

echo "Provider is ${provider}"
echo "Length is ${length}"

if [[ "$provider" == "1" || "$provider" =~ openssl ]]; then
    echo "Using openssl"
    openssl rand -hex $length
    # openssl rand 60 | base64 -w 0
elif [[ "$provider" == "2" || "$provider" =~ pwgen ]]; then
    echo "Using pwgen"
    pwgen -s -B -n $length 1
else
    echo -e "${COLOR_BOLD_RED}Error: unknown provider!${COLOR_RESET}"
    exit 1
fi

