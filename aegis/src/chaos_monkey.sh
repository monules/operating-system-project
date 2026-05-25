#!/bin/bash
# chaos_monkey.sh - The Adversarial Stress Generator

# Robust path finding
SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SRC_DIR")"
LOG_FILE="$BASE_DIR/logs/aegis_events.log"
DATA_DIR="$BASE_DIR/data"
STATUS_FILE="$DATA_DIR/system_status.json"

log_event() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [Chaos-Monkey] $1" >> "$LOG_FILE"
}

simulate_brute_force() {
    log_event "Starting simulated SSH brute force attack..."
    for i in {1..10}; do
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] [SYSTEM] Failed Password for root from 192.168.1.100 port 22" >> "$LOG_FILE"
        sleep 0.5
    done
    log_event "Brute force simulation complete."
}

simulate_ransomware() {
    log_event "Starting simulated ransomware attack on /data..."
    # Set locale to C for the whole function to avoid 'Illegal byte sequence' on macOS
    local OLD_LC_ALL=$LC_ALL
    export LC_ALL=C
    for i in {1..10}; do
        # Generate high-entropy content
        RAND_STR=$(head -c 100 /dev/urandom | tr -dc A-Za-z0-9 | head -c 10)
        echo "CORRUPTED_$RAND_STR" > "$DATA_DIR/file_$i.txt"
        log_event "Rapid File Modification: Modified $DATA_DIR/file_$i.txt"
        sleep 0.2
    done
    export LC_ALL=$OLD_LC_ALL
    log_event "Ransomware simulation complete."
}

simulate_cpu_stress() {
    log_event "Starting CPU stress simulation..."
    python3 -c "import json; f=open('$STATUS_FILE', 'r+'); data=json.load(f); data['resource_usage']['cpu']=95; f.seek(0); json.dump(data, f, indent=4); f.truncate()"
    sleep 5
    python3 -c "import json; f=open('$STATUS_FILE', 'r+'); data=json.load(f); data['resource_usage']['cpu']=15; f.seek(0); json.dump(data, f, indent=4); f.truncate()"
    log_event "CPU stress simulation ended."
}

case "$1" in
    brute) simulate_brute_force ;;
    ransom) simulate_ransomware ;;
    cpu) simulate_cpu_stress ;;
    *) echo "Usage: $0 {brute|ransom|cpu}"; exit 1 ;;
esac
