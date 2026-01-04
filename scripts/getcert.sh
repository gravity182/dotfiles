#!/usr/bin/env bash

# SSL Certificate Information Display Tool
# Retrieves and displays SSL certificate details from HTTPS URLs

if [[ "$1" == "-h" || "$1" == "--help" || -z "$1" ]]; then
    echo "Usage: $0 <url>"
    echo ""
    echo "Displays SSL certificate information for the specified HTTPS URL"
    echo "Shows certificate details including issuer, subject, validity dates, and extensions"
    echo ""
    echo "Arguments:"
    echo "  url               HTTPS URL to check (with or without https:// prefix)"
    echo ""
    echo "Options:"
    echo "  -h, --help        Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 google.com"
    echo "  $0 https://github.com"
    echo "  $0 example.com:8443"
    echo ""
    echo "Requirements:"
    echo "  - openssl command line tool"
    echo ""
    [[ "$1" == "-h" || "$1" == "--help" ]] && exit 0 || exit 1
fi

url="$1"
parsed_url=$(printf "%s" "$url" | sed 's|https://||g')
printf '\n' | openssl s_client -connect "$parsed_url":443 -showcerts | openssl x509 -noout -text

