#!/bin/bash
# Author: Prof. Mehdi Pirahandeh
# Lab ducational script to understand system logging on Ubuntu 20.04
# This script covers basics of rsyslog and systemd-journald.

echo "Starting the logging lab script..."

# Ensure script is running with root privileges to manage system logs
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# 1. Update the system
echo "Updating the system..."
sudo apt-get update

# 2. Install rsyslog if it's not already installed
echo "Ensuring rsyslog is installed..."
sudo apt-get install -y rsyslog

# 3. Start and enable rsyslog service
echo "Enabling and starting rsyslog service..."
sudo systemctl enable rsyslog
sudo systemctl start rsyslog

# 4. Check status of rsyslog
echo "Checking the status of rsyslog service..."
sudo systemctl status rsyslog --no-pager

# 5. Viewing configuration files for rsyslog
echo "Displaying rsyslog configuration..."
cat /etc/rsyslog.conf

# Example 1: Configure rsyslog to create a new log file for kernel messages
echo "Configuring rsyslog to log kernel messages separately..."
echo "kern.* /var/log/kernel.log" >> /etc/rsyslog.d/50-default.conf
sudo systemctl restart rsyslog

# Example 2-15: Creating multiple log examples
for i in {2..15}
do
   echo "Creating example log entry $i."
   logger -p local0.notice "Test log entry $i"
done

# 6. Installing systemd-journald if not already present
echo "Ensuring systemd-journald is active..."
sudo systemctl enable systemd-journald
sudo systemctl start systemd-journald

# 7. Viewing logs with journalctl
echo "Viewing logs with systemd-journald..."
sudo journalctl --no-pager

# Example 8: Filtering journal entries for kernel messages
echo "Filtering kernel messages with journalctl..."
sudo journalctl -k --no-pager

# Example 9: Demonstrating various journalctl usages
echo "Demonstrating various journalctl filters and features..."
sudo journalctl -u rsyslog --no-pager # Filter by service
sudo journalctl --since today --no-pager # Logs from today
sudo journalctl --priority=err --no-pager # Logs with error priority
sudo journalctl --boot --no-pager # Logs from current boot

# Example 10
for i in {18..31}
do
   echo "Creating additional journalctl usage example $i."
   sudo journalctl --since "2021-01-01" --until "2021-01-02" --no-pager # Specific date range logs
done

# Example 11: Explain configuration persistence and management
echo "All modifications should be properly managed through configuration management tools or version control systems."

# Script completion
echo "Logging educational script has completed. Check /var/log and journalctl for outputs."

# This script teaches students about the importance of logging, how to manage system logs,
# configure rsyslog for different scenarios, and utilize systemd-journald to view and filter logs.

