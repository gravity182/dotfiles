#!/usr/bin/env bash

# Ookla Speedtest CLI Runner
# Downloads and executes the official Ookla speedtest command-line tool

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo "Usage: $0"
    echo ""
    echo "Downloads and runs the official Ookla Speedtest CLI tool"
    echo "Performs internet speed test and displays results"
    echo ""
    echo "Features:"
    echo "  - Downloads latest Ookla speedtest CLI (version 1.2.0)"
    echo "  - Automatically accepts license agreements"
    echo "  - Tests download and upload speeds"
    echo "  - Shows latency and server information"
    echo "  - Cleans up downloaded files after execution"
    echo ""
    echo "Options:"
    echo "  -h, --help        Show this help message"
    echo ""
    echo "Requirements:"
    echo "  - wget for downloading the speedtest binary"
    echo "  - tar for extracting the archive"
    echo "  - Internet connection for download and testing"
    echo ""
    echo "Platform support:"
    echo "  - Linux x86_64 (amd64)"
    echo "  - Linux aarch64 (arm64)"
    echo "  - Other architectures as detected by uname -m"
    echo ""
    echo "Notes:"
    echo "  - First run requires accepting Ookla's license and privacy policy"
    echo "  - Script automatically accepts these agreements"
    echo "  - Temporary files are stored in /tmp/speedtest"
    echo "  - All files are cleaned up after execution"
    echo ""
    echo "Official Ookla Speedtest: https://www.speedtest.net/apps/cli"
    exit 0
fi

set -euo pipefail
IFS=$'\n\t'

echo "Downloading Ookla Speedtest CLI..."
wget -q "https://install.speedtest.net/app/cli/ookla-speedtest-1.2.0-linux-$(uname -m).tgz"
mkdir -p "/tmp/speedtest"
tar -xf "ookla-speedtest-1.2.0-linux-$(uname -m).tgz" -C "/tmp/speedtest"
chmod u+x /tmp/speedtest/speedtest
echo -ne 'yes\nyes\n' | /tmp/speedtest/speedtest 
rm -rf "ookla-speedtest-1.2.0-linux-$(uname -m).tgz" \
    && rm -rf /tmp/speedtest

