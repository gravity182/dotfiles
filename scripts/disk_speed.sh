#!/bin/bash

# Disk speed test using fio

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo "Usage: $0"
    echo ""
    echo "Tests disk I/O performance using fio with random read/write operations"
    echo "Creates a 4GB test file and performs mixed 75% read/25% write operations"
    echo ""
    echo "Options:"
    echo "  -h, --help    Show this help message"
    echo ""
    echo "Requirements: fio (will be installed if not present)"
    exit 0
fi

# Install fio if not available
if [[ ! -x "$(command -v fio)" ]]; then
    echo "fio not found, installing..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install fio
    elif [[ -x "$(command -v apt)" ]]; then
        sudo apt update && sudo apt install fio
    elif [[ -x "$(command -v yum)" ]]; then
        sudo yum install fio
    else
        echo "Error: Unable to install fio automatically. Please install manually."
        exit 1
    fi
fi

echo "Starting disk speed test..."
fio --randrepeat=1 --ioengine=libaio --direct=1 --gtod_reduce=1 --name=test \
    --filename=test --bs=4k --iodepth=64 --size=4G --readwrite=randrw --rwmixread=75

# Clean up test file
rm -f test

