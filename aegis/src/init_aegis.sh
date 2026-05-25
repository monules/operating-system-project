#!/bin/bash
# init_aegis.sh - Foundation for Project A.E.G.I.S.

# Robust path finding
SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SRC_DIR")"
LOG_DIR="$BASE_DIR/logs"
DATA_DIR="$BASE_DIR/data"
BACKUP_DIR="$BASE_DIR/backups"

# Create Directory Structure
mkdir -p "$LOG_DIR" "$DATA_DIR" "$BACKUP_DIR"

# Initialize Shared State JSON if it doesn't exist
if [ ! -f "$DATA_DIR/system_status.json" ]; then
cat <<EON > "$DATA_DIR/system_status.json"
{
    "security_level": "NORMAL",
    "lockdown_active": false,
    "last_backup": "None",
    "active_threats": 0,
    "deadlock_status": "SAFE",
    "resource_usage": {
        "cpu": 0,
        "ram": 0
    }
}
EON
fi

# Initialize Global Event Log
touch "$LOG_DIR/aegis_events.log"

echo "Project A.E.G.I.S. Infrastructure Initialized at $BASE_DIR"
