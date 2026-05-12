#!/bin/bash
# init_aegis.sh - Foundation for Project A.E.G.I.S.

BASE_DIR="./aegis"
LOG_DIR="$BASE_DIR/logs"
DATA_DIR="$BASE_DIR/data"
BACKUP_DIR="$BASE_DIR/backups"
SRC_DIR="$BASE_DIR/src"

# Create Directory Structure
mkdir -p "$LOG_DIR" "$DATA_DIR" "$BACKUP_DIR" "$SRC_DIR"

# Initialize Shared State JSON
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

# Initialize Global Event Log
touch "$LOG_DIR/aegis_events.log"

echo "Project A.E.G.I.S. Infrastructure Initialized."
