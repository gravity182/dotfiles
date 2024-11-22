#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

wget -q "https://install.speedtest.net/app/cli/ookla-speedtest-1.2.0-linux-$(uname -m).tgz"
mkdir -p "/tmp/speedtest"
tar -xf "ookla-speedtest-1.2.0-linux-$(uname -m).tgz" -C "/tmp/speedtest"
chmod u+x /tmp/speedtest/speedtest
echo -ne 'yes\nyes\n' | /tmp/speedtest/speedtest 
rm -rf "ookla-speedtest-1.2.0-linux-$(uname -m).tgz" \
    && rm -rf /tmp/speedtest

