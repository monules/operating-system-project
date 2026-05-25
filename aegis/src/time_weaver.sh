#!/bin/bash
# time_weaver.sh - Automated Differential Rollback System

# Robust path finding
SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SRC_DIR")"
BACKUP_DIR="$BASE_DIR/backups"
DATA_DIR="$BASE_DIR/data"
SNAPSHOT_FILE="$BACKUP_DIR/snapshot.snar"
LOG_FILE="$BASE_DIR/logs/aegis_events.log"
STATUS_FILE="$DATA_DIR/system_status.json"

log_event() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [Time-Weaver] $1" >> "$LOG_FILE"
}

perform_backup() {
    local backup_name="backup_$(date '+%Y%m%d_%H%M%S').tar.gz"
    local backup_path="$BACKUP_DIR/$backup_name"
    
    echo "Creating backup at $backup_path..."
    
    # Check if we are on macOS (darwin) or Linux
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # bsdtar doesn't support --listed-incremental, so we do a simple backup
        tar --create --gzip --file="$backup_path" -C "$DATA_DIR" .
    else
        # GNU tar (Ubuntu) supports incremental backups
        tar --create --gzip \
            --file="$backup_path" \
            --listed-incremental="$SNAPSHOT_FILE" \
            -C "$DATA_DIR" .
    fi
    
    if [ $? -eq 0 ]; then
        log_event "Incremental backup created: $backup_name"
        if [ -f "$STATUS_FILE" ]; then
            python3 -c "import json; f=open('$STATUS_FILE', 'r+'); data=json.load(f); data['last_backup']='$backup_name'; f.seek(0); json.dump(data, f, indent=4); f.truncate()"
        fi
    else
        log_event "ERROR: Failed to create backup $backup_name"
    fi
}

perform_rollback() {
    log_event "ROLLBACK TRIGGERED. Purging corrupted data..."
    
    # Find all backup files in chronological order
    # ls -v is natural sort (GNU), on macOS we just use sort
    if [[ "$OSTYPE" == "darwin"* ]]; then
        BACKUPS=$(ls "$BACKUP_DIR"/*.tar.gz 2>/dev/null | sort)
    else
        BACKUPS=$(ls -v "$BACKUP_DIR"/*.tar.gz 2>/dev/null)
    fi
    
    if [ -z "$BACKUPS" ]; then
        log_event "ERROR: No backups found in $BACKUP_DIR"
        exit 1
    fi

    # To be safe, we'll delete file_*.txt which is what Chaos Monkey targets.
    rm -f "$DATA_DIR"/file_*.txt
    
    for backup in $BACKUPS; do
        log_event "Extracting $backup..."
        if [[ "$OSTYPE" == "darwin"* ]]; then
             tar --extract --file="$backup" -C "$DATA_DIR"
        else
             tar --extract --listed-incremental=/dev/null --file="$backup" -C "$DATA_DIR"
        fi
    done
    
    log_event "System rolled back to the latest safe state."
}

case "$1" in
    backup) perform_backup ;;
    rollback) perform_rollback ;;
    *) echo "Usage: $0 {backup|rollback}"; exit 1 ;;
esac
