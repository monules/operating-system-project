#!/bin/bash
# run_aegis.sh - Master Orchestrator for Project A.E.G.I.S.

# 1. Initialize Infrastructure
./aegis/src/init_aegis.sh

# 2. Start Sentinel (Background)
python3 aegis/src/sentinel.py &
SENTINEL_PID=$!

# 3. Start Chaos Monkey Simulation (Optional individual attacks)
# We will leave this for the user to trigger manually or add a demo mode.
echo "Project A.E.G.I.S. is running."
echo "Sentinel PID: $SENTINEL_PID"
echo "You can trigger attacks using: ./aegis/src/chaos_monkey.sh {brute|ransom|cpu}"

# 4. Start Dashboard (Foreground)
python3 aegis/src/dashboard.py

# Cleanup on exit
kill $SENTINEL_PID
