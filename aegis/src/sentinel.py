import os
import time
import json
import subprocess

BASE_DIR = "./aegis"
LOG_FILE = os.path.join(BASE_DIR, "logs/aegis_events.log")
STATUS_FILE = os.path.join(BASE_DIR, "data/system_status.json")

def log_sentinel(message):
    timestamp = time.strftime("%Y-%m-%d %H:%M:%S")
    with open(LOG_FILE, "a") as f:
        f.write(f"[{timestamp}] [Sentinel] {message}\n")

def update_status(updates):
    with open(STATUS_FILE, "r+") as f:
        data = json.load(f)
        data.update(updates)
        f.seek(0)
        json.dump(data, f, indent=4)
        f.truncate()

def monitor_logs():
    log_sentinel("Sentinel monitoring started...")
    process = subprocess.Popen(["tail", "-f", LOG_FILE], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    failed_attempts = 0
    last_reset = time.time()
    try:
        while True:
            line = process.stdout.readline()
            if not line: continue
            if "Failed Password" in line:
                failed_attempts += 1
                if failed_attempts >= 5:
                    log_sentinel("CRITICAL: Brute force detected! Triggering Lockdown.")
                    update_status({"security_level": "CRITICAL", "lockdown_active": True, "active_threats": 1})
                    failed_attempts = 0
            if "Rapid File Modification" in line:
                log_sentinel("WARNING: Ransomware behavior detected! Triggering Emergency Rollback.")
                subprocess.run(["./aegis/src/time_weaver.sh", "rollback"])
            if time.time() - last_reset > 30:
                failed_attempts = 0
                last_reset = time.time()
    except Exception as e:
        log_sentinel(f"Sentinel error: {str(e)}")
        process.terminate()

if __name__ == "__main__":
    monitor_logs()
