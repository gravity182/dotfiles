#!/usr/bin/env bash

# PostgreSQL Backup Restoration Tool
# Restores SQL backup files to PostgreSQL databases with interactive selection

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo "Usage: $0 [database_name]"
    echo ""
    echo "Restores PostgreSQL backup files to specified database"
    echo "Uses interactive file selection for backup files"
    echo ""
    echo "Arguments:"
    echo "  database_name     Target database name (prompted if not provided)"
    echo ""
    echo "Options:"
    echo "  -h, --help        Show this help message"
    echo ""
    echo "Features:"
    echo "  - Interactive backup file selection using fzf"
    echo "  - Filters for .sql files by default"
    echo "  - Comprehensive error handling and logging"
    echo "  - Creates timestamped restore log files"
    echo "  - Stops on first error for safety"
    echo ""
    echo "Prerequisites:"
    echo "  - PostgreSQL client (psql) must be installed"
    echo "  - fzf must be installed for file selection"
    echo "  - Database must exist and be accessible"
    echo "  - Appropriate PostgreSQL credentials configured"
    echo ""
    echo "Examples:"
    echo "  $0                    # Interactive database name input"
    echo "  $0 myapp_production   # Restore to myapp_production database"
    echo ""
    echo "Log files:"
    echo "  - Creates restore_YYYYMMDD_HHMMSS.log in current directory"
    echo "  - Contains detailed restore output for troubleshooting"
    exit 0
fi

set -euo pipefail
IFS=$'\n\t'

# Get database name from argument or prompt
if [[ -n "${1:-}" ]]; then
    database="$1"
    echo "Using database: $database"
else
    echo -n "Input database name: "
    read -r database
fi

# Validate database name
if [[ -z "$database" ]]; then
    echo "Error: Database name cannot be empty" >&2
    exit 1
fi

# Check if database exists
if ! psql -lqt | cut -d \| -f 1 | grep -qw "$database"; then
    echo "Warning: Database '$database' may not exist or is not accessible"
    echo -n "Continue anyway? (y/N): "
    read -r confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "Aborted"
        exit 1
    fi
fi

backup=$(fzf --query=".sql$" --header="Select the backup file")

echo "Restoring backup '$backup' to database '$database'"

PGOPTIONS='--client-min-messages=warning' psql -X -q -1 -v ON_ERROR_STOP=1 --pset pager=off -d "$database" -f "$backup" -L restore_$(date +%Y%m%d_%H%M%S).log

