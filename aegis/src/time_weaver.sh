#!/bin/bash
# time_weaver.sh - Automated Differential Rollback System

BASE_DIR="./aegis"
BACKUP_DIR="$BASE_DIR/backups"
DATA_DIR="$BASE_DIR/data"
SNAPSHOT_FILE="$BACKUP_DIR/snapshot.snar"
LOG_FILE="$BASE_DIR/logs/aegis_events.log"

log_event() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [Time-Weaver] $1" >> "$LOG_FILE"
}

perform_backup() {
    local backup_name="backup_$(date '+%Y%m%d_%H%M%S').tar.gz"
    tar --create --gzip \
        --file="$BACKUP_DIR/$backup_name" \
        --listed-incremental="$SNAPSHOT_FILE" \
        "$DATA_DIR" 2>/dev/null
    
    log_event "Incremental backup created: $backup_name"
    
    python3 -c "import json; f=open('$DATA_DIR/system_status.json', 'r+'); data=json.load(f); data['last_backup']='$backup_name'; f.seek(0); json.dump(data, f, indent=4); f.truncate()"
}

perform_rollback() {
    log_event "ROLLBACK TRIGGERED. Purging corrupted data..."
    rm -rf "$DATA_DIR"/*
    
    for backup in $(ls -v "$BACKUP_DIR"/*.tar.gz 2>/dev/null); do
        tar --extract --listed-incremental=/dev/null --file="$backup" -C / 2>/dev/null
    done
    
    log_event "System rolled back to the latest safe state."
}

case "$1" in
    backup) perform_backup ;;
    rollback) perform_rollback ;;
    *) echo "Usage: $0 {backup|rollback}"; exit 1 ;;
esac
