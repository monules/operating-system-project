import json
import os
import time
from datetime import datetime

# Robust path finding
SRC_DIR = os.path.dirname(os.path.abspath(__file__))
BASE_DIR = os.path.dirname(SRC_DIR)
STATUS_FILE = os.path.join(BASE_DIR, "data/system_status.json")
LOG_FILE = os.path.join(BASE_DIR, "logs/aegis_events.log")

def get_status():
    if not os.path.exists(STATUS_FILE): 
        return {
            "security_level": "UNKNOWN", "lockdown_active": False, 
            "active_threats": 0, "deadlock_status": "UNKNOWN", 
            "last_backup": "None", "resource_usage": {"cpu": 0, "ram": 0}
        }
    with open(STATUS_FILE, "r") as f: return json.load(f)

def get_recent_logs(n=5):
    if not os.path.exists(LOG_FILE): return []
    with open(LOG_FILE, "r") as f: return f.readlines()[-n:]

def render_dashboard():
    while True:
        try:
            status, logs = get_status(), get_recent_logs(8)
            os.system('clear' if os.name == 'posix' else 'cls')
            print("="*60 + f"\n PROJECT A.E.G.I.S. | {datetime.now().strftime('%H:%M:%S')}\n" + "="*60)
            print(f"\n[SECURITY] {status.get('security_level', 'N/A')} | [LOCKDOWN] {'ACTIVE' if status.get('lockdown_active') else 'OFF'}")
            print(f"[THREATS]  {status.get('active_threats', 0)} | [DEADLOCK] {status.get('deadlock_status', 'N/A')}")
            print(f"[RECOVERY] {status.get('last_backup', 'None')}")
            cpu_val = status.get('resource_usage', {}).get('cpu', 0)
            print(f"\n[CPU USAGE] [{'#'*(cpu_val//5)}{'-'*(20-cpu_val//5)}] {cpu_val}%")
            print("\n" + "-"*60 + "\n RECENT SYSTEM EVENTS\n" + "-"*60)
            for log in logs: print(f" > {log.strip()}")
            print("\n" + "="*60 + "\n (Ctrl+C to exit dashboard)")
            time.sleep(2)
        except KeyboardInterrupt: break
        except Exception as e: print(f"Dashboard Error: {e}"); time.sleep(5)

if __name__ == "__main__":
    render_dashboard()
