#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

echo -n "Input database name: "
read -r database

backup=$(fzf --query=".sql$" --header="Select the backup file")

echo "Restoring backup '$backup' to database '$database'"

PGOPTIONS='--client-min-messages=warning' psql -X -q -1 -v ON_ERROR_STOP=1 --pset pager=off -d "$database" -f "$backup" -L restore_$(date +%Y%m%d_%H%M%S).log

