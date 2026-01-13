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
    echo "  - Downloads Ookla speedtest CLI (version 1.2.0)"
    echo "  - Automatically accepts license agreements"
    echo "  - Tests download and upload speeds"
    echo "  - Shows latency and server information"
    echo "  - Cleans up downloaded files after execution"
    echo ""
    echo "Options:"
    echo "  -h, --help        Show this help message"
    echo ""
    echo "Requirements:"
    echo "  - wget or curl for downloading the speedtest binary"
    echo "  - tar for extracting the archive"
    echo "  - Internet connection for download and testing"
    echo ""
    echo "Platform support:"
    echo "  - macOS (universal)"
    echo "  - Linux x86_64 (amd64)"
    echo "  - Linux aarch64 (arm64)"
    echo "  - Other architectures as detected by uname -m"
    echo "  - FreeBSD 12/13 x86_64 (via .pkg archive)"
    echo ""
    echo "Notes:"
    echo "  - First run requires accepting Ookla's license and privacy policy"
    echo "  - Script automatically accepts these agreements"
    echo "  - Temporary files are stored in /tmp via mktemp"
    echo "  - All files are cleaned up after execution"
    echo ""
    echo "Official Ookla Speedtest: https://www.speedtest.net/apps/cli"
    exit 0
fi

set -euo pipefail
IFS=$'\n\t'

require_cmd() {
    local name="$1"
    command -v "$name" >/dev/null 2>&1
}

download_file() {
    local url="$1"
    local out="$2"

    if require_cmd wget; then
        wget -q -O "$out" "$url"
        return 0
    fi

    if require_cmd curl; then
        curl -fsSL "$url" -o "$out"
        return 0
    fi

    echo "Error: neither wget nor curl is available for downloads." >&2
    return 1
}

version="1.2.0"
os="$(uname -s)"
arch="$(uname -m)"

filename=""
case "$os" in
    Linux)
        case "$arch" in
            amd64) arch="x86_64" ;;
            arm64) arch="aarch64" ;;
            armv7l) arch="armhf" ;;
            armv6l) arch="armel" ;;
        esac
        filename="ookla-speedtest-${version}-linux-${arch}.tgz"
        ;;
    Darwin)
        filename="ookla-speedtest-${version}-macosx-universal.tgz"
        ;;
    FreeBSD)
        case "$arch" in
            amd64) arch="x86_64" ;;
        esac
        freebsd_major="$(uname -r | cut -d. -f1)"
        case "$freebsd_major" in
            12|13) filename="ookla-speedtest-${version}-freebsd${freebsd_major}-${arch}.pkg" ;;
            *)
                echo "Error: unsupported FreeBSD major version: ${freebsd_major} (expected 12 or 13)." >&2
                exit 1
                ;;
        esac
        ;;
    *)
        echo "Error: unsupported OS for this script: ${os}" >&2
        exit 1
        ;;
esac

url="https://install.speedtest.net/app/cli/${filename}"

tmpdir="$(mktemp -d "${TMPDIR:-/tmp}/speedtest.XXXXXXXX")"
archive="${tmpdir}/${filename}"
cleanup() {
    rm -rf "$tmpdir"
}
trap cleanup EXIT

echo "Downloading Ookla Speedtest CLI..."
download_file "$url" "$archive"

tar -xf "$archive" -C "$tmpdir"

speedtest_bin=""
if [[ -x "${tmpdir}/speedtest" ]]; then
    speedtest_bin="${tmpdir}/speedtest"
elif [[ -x "${tmpdir}/usr/local/bin/speedtest" ]]; then
    speedtest_bin="${tmpdir}/usr/local/bin/speedtest"
elif [[ -x "${tmpdir}/usr/bin/speedtest" ]]; then
    speedtest_bin="${tmpdir}/usr/bin/speedtest"
else
    speedtest_bin="$(find "$tmpdir" -maxdepth 5 -type f -name speedtest -perm -111 2>/dev/null | head -n1 || true)"
fi

if [[ -z "$speedtest_bin" ]]; then
    echo "Error: could not find extracted speedtest binary in ${tmpdir}" >&2
    exit 1
fi

echo -ne 'yes\nyes\n' | "$speedtest_bin"
