import json
import os
import time

# Robust path finding
SRC_DIR = os.path.dirname(os.path.abspath(__file__))
BASE_DIR = os.path.dirname(SRC_DIR)
DATA_DIR = os.path.join(BASE_DIR, "data")
STATUS_FILE = os.path.join(DATA_DIR, "system_status.json")
LOG_FILE = os.path.join(BASE_DIR, "logs/aegis_events.log")

def log_traffic(message):
    timestamp = time.strftime("%Y-%m-%d %H:%M:%S")
    with open(LOG_FILE, "a") as f:
        f.write(f"[{timestamp}] [Traffic-Controller] {message}\n")

class BankersAlgorithm:
    def __init__(self, available, maximum, allocation):
        self.available, self.maximum, self.allocation = available, maximum, allocation
        self.n, self.m = len(maximum), len(available)
        self.need = [[self.maximum[i][j] - self.allocation[i][j] for j in range(self.m)] for i in range(self.n)]

    def is_safe(self):
        work, finish, safe_sequence = list(self.available), [False] * self.n, []
        while len(safe_sequence) < self.n:
            found = False
            for p in range(self.n):
                if not finish[p] and all(self.need[p][j] <= work[j] for j in range(self.m)):
                    for j in range(self.m): work[j] += self.allocation[p][j]
                    finish[p], found = True, True
                    safe_sequence.append(p)
            if not found: return False, []
        return True, safe_sequence

def run_simulation():
    log_traffic("Starting Deadlock Prevention Simulation...")
    available = [3, 3, 2]
    maximum = [[7, 5, 3], [3, 2, 2], [9, 0, 2], [2, 2, 2], [4, 3, 3]]
    allocation = [[0, 1, 0], [2, 0, 0], [3, 0, 2], [2, 1, 1], [0, 0, 2]]
    banker = BankersAlgorithm(available, maximum, allocation)
    safe, sequence = banker.is_safe()
    status = "SAFE" if safe else "UNSAFE"
    log_traffic(f"System State: {status}. Sequence: {sequence}")
    
    if os.path.exists(STATUS_FILE):
        with open(STATUS_FILE, "r+") as f:
            data = json.load(f)
            data["deadlock_status"] = status
            f.seek(0)
            json.dump(data, f, indent=4)
            f.truncate()

if __name__ == "__main__":
    run_simulation()
