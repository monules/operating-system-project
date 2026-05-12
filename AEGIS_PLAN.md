# Project A.E.G.I.S. Implementation Plan
**Autonomous Environment Guard & Intelligent Scheduler**

## Vision
A unified, self-regulating Ubuntu ecosystem simulated in Google Colab. The project consists of five interacting scenarios that simulate real-world OS stress, detection, resource management, and recovery, all visualized in a real-time dashboard.

---

## Technical Architecture

### 1. The Environment (Foundation)
*   **Target:** Ubuntu-based environment (Google Colab).
*   **Languages:** Bash (for system-level ops), Python (for logic and visualization).
*   **Shared State:** A `/aegis` directory to store logs, mock data, backups, and system status JSON files.

### 2. Scenario Breakdown

#### **Scenario 1: The Chaos Monkey (Threat Generator)**
*   **Logic:** A Bash script that randomly triggers events:
    *   *Log Injection:* Spams `/var/log/syslog` with fake "Failed Password" attempts from random IPs.
    *   *File Corruption:* Rapidly creates files in a target directory with high-entropy content (simulating ransomware).
    *   *Resource Stress:* Spawns dozens of dummy processes to simulate a CPU spike.
*   **Output:** Generates entries in `system_events.log`.

#### **Scenario 2: The Sentinel (Intrusion Detection)**
*   **Logic:** A background Python monitor using `grep` and `awk` via `subprocess`.
*   **Action:** Detects patterns from Scenario 1. If 5+ failed logins occur within 10 seconds, it triggers a "Lockdown" (writing to a `security_status.json`).
*   **Integration:** Communicates with Time-Weaver to trigger emergency backups.

#### **Scenario 3: The Traffic Controller (Deadlock Preventer)**
*   **Logic:** Python implementation of the **Banker's Algorithm**.
*   **Simulation:** Defines 3 resource types (CPU, RAM, I/O units) and 5 "Active Tasks".
*   **Action:** When a task requests resources, the script checks for a "Safe State". If unsafe (potential deadlock), it denies the request and logs a "Deadlock Prevented" event.

#### **Scenario 4: The Time-Weaver (Differential Rollback)**
*   **Logic:** Utilizes `tar --listed-incremental`.
*   **Action:** 
    *   Performs a "Level 0" full backup at startup.
    *   Performs "Level 1" incremental backups every minute.
    *   On a "Security Alert" from Sentinel, it automatically purges the corrupted directory and extracts the latest "safe" incremental archive.

#### **Scenario 5: The Command Center (Live Dashboard)**
*   **Logic:** Interactive Python cell in Colab using `Plotly` and `IPython.display`.
*   **Visuals:**
    *   **System Health:** Gauge charts for CPU/RAM stress.
    *   **Security Map:** A log of prevented attacks.
    *   **Deadlock Graph:** Visual state of the Banker's Algorithm allocation.
    *   **Recovery Timeline:** Marking backup and rollback points.

---

## Implementation Phases

### Phase 1: Infrastructure (Steps 1-2)
*   Setup directory structure and common logging utility.
*   Implement the shared JSON state file.

### Phase 2: Defense & Recovery (Steps 3-4)
*   Build Scenario 4 (Time-Weaver) for backup basics.
*   Build Scenario 2 (Sentinel) for log monitoring.

### Phase 3: The Threat (Step 5)
*   Build Scenario 1 (Chaos Monkey) to start the "Game".

### Phase 4: Intelligence (Step 6)
*   Build Scenario 3 (Traffic Controller) for Deadlock Prevention.

### Phase 5: The Interface (Step 7)
*   Build Scenario 5 (Command Center) and integrate all data streams.

### Phase 6: Finalization (Step 8)
*   Final testing, bug fixing, and writing the Reflection.
