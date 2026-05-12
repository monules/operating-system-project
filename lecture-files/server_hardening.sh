#!/bin/bash

# Comprehensive Educational Script for Server Hardening and Reversal
# Author: Prof. Mehdi Pirahandeh
# This script applies several security measures to an Ubuntu system and then undoes them.

### PACKAGE UPDATES AND INSTALLATIONS ###
# Updates the list of packages and installs firewalld and ClamAV to manage firewall settings and virus protection.
echo "Updating package list..."
sudo apt update
echo "Installing Firewalld and ClamAV..."
sudo apt install -y firewalld clamav clamav-daemon

### SETTING A GRUB PASSWORD ###
# Secure the GRUB bootloader by setting a password.
echo "Generating a GRUB password hash..."
# Generates a PBKDF2 hash of the password 'password' (change as necessary).
grub_password_hash=$(echo "password" | sudo grub-mkpasswd-pbkdf2 | sed -n 's/.*PBKDF2 hash is //p')
echo "Updating GRUB configuration..."
# Adds a superuser and their password to the GRUB configuration.
echo "set superusers=\"root\"" | sudo tee -a /etc/grub.d/40_custom
echo "password_pbkdf2 root $grub_password_hash" | sudo tee -a /etc/grub.d/40_custom
sudo update-grub

### DENYING ROOT SSH ACCESS ###
# Modifies the SSH configuration to enhance security by denying root login.
echo "Modifying SSH configuration to deny root login..."
sudo sed -i 's/^PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sudo systemctl restart sshd

### USER MANAGEMENT ###
# Adds a user with sudo privileges for administrative tasks without using the root account.
username="newuser"  # Change username as necessary
echo "Adding new user '$username'..."
sudo adduser --disabled-password --gecos "" $username
echo "Adding new user to sudo group..."
sudo usermod -aG sudo $username

### TCP WRAPPERS ###
# Configures host-based access control via TCP Wrappers.
echo "Configuring TCP Wrappers for SSH..."
# Allows SSH access only from the subnet 192.168.1.0/24.
echo "sshd : 192.168.1." | sudo tee -a /etc/hosts.allow
# Denies SSH access from all other sources.
echo "sshd : ALL" | sudo tee -a /etc/hosts.deny

### FIREWALL CONFIGURATION ###
# Configures the firewall to manage network access.
echo "Starting and enabling Firewalld..."
sudo systemctl start firewalld
sudo systemctl enable firewalld
echo "Configuring Firewalld rules..."
# Opens the SSH port and allows traffic from a specified IP range.
sudo firewall-cmd --zone=public --add-port=22/tcp --permanent
sudo firewall-cmd --zone=public --add-source=192.168.1.0/24 --permanent
sudo firewall-cmd --reload

### ANTIVIRUS SETUP ###
# Updates virus definitions to protect against malware.
echo "Updating virus definitions..."
sudo freshclam

### LOG ROTATION ###
# Configures log rotation to manage and archive system logs.
echo "Configuring log rotation..."
# Sets up weekly rotation and compression for all log files in /var/log.
echo "/var/log/*.log {
    weekly
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    create 0640 root adm
}" | sudo tee /etc/logrotate.d/custom

### ADDITIONAL SECURITY MEASURES ###
# Additional security configurations such as blocking ICMP requests and scheduling virus scans.
echo "Blocking ICMP requests..."
sudo firewall-cmd --zone=public --add-rich-rule='rule protocol value="icmp" drop' --permanent
sudo firewall-cmd --reload
echo "Scheduling daily virus scans..."
# Adds a cron job to perform daily scans of the /home directory.
echo "0 3 * * * root clamscan -r /home" | sudo tee -a /etc/crontab

### UNDOING MODIFICATIONS ###
# Section to reverse all modifications made in the script for learning and restoration purposes.
echo "Script is complete. Starting cleanup..."
# Removes the installed packages and any residual configurations.
sudo apt remove --purge -y firewalld clamav clamav-daemon
sudo apt autoremove -y
echo "Restoring original GRUB configuration..."
# Restores the original GRUB configuration from a backup.
sudo cp /etc/grub.d/40_custom.backup /etc/grub.d/40_custom
sudo update-grub
echo "Reverting SSH configuration changes..."
# Resets SSH configuration to allow root login.
sudo sed -i 's/^PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
sudo systemctl restart sshd
echo "Removing created user..."
# Deletes the previously created user and their home directory.
sudo deluser --remove-home newuser
echo "Resetting TCP Wrappers configuration..."
# Removes the specific TCP Wrapper settings for SSH.
sudo sed -i '/sshd : 192.168.1./d' /etc/hosts.allow
sudo sed -i '/sshd : ALL/d' /etc/hosts.deny
echo "Stopping and disabling Firewalld..."
# Stops and disables the Firewalld service, resetting all rules.
sudo systemctl stop firewalld
sudo systemctl disable firewalld
sudo firewall-cmd --complete-reload
echo "Restoring log rotation settings..."
# Restores the original log rotation configuration from a backup.
sudo cp /etc/logrotate.conf.backup /etc/logrotate.conf
echo "Removing scheduled virus scans from cron..."
# Removes the cron job for virus scans.
sudo sed -i '/clamscan -r \/home/d' /etc/crontab

echo "All modifications have been undone. System restored to previous state."

# #!/bin/bash

# # Fully automated Shell script for DNS and Routing configuration on Ubuntu 20.04
#Prof. Mehdi Pirahandeh
# # Exit on any error
# set -e

# # Function to ensure systemd-resolved is installed and active
# function ensure_systemd_resolved_active() {
#     echo "Step 1: Checking if systemd-resolved is installed and starting it if necessary..."
#     if ! systemctl is-active --quiet systemd-resolved; then
#         echo "systemd-resolved is not active, starting it now..."
#         sudo systemctl enable systemd-resolved
#         sudo systemctl start systemd-resolved
#     else
#         echo "systemd-resolved is active and running."
#     fi
# }



# # Main function to orchestrate all operations
# function main() {
#     ensure_systemd_resolved_active

# }

# # Execute the main function
# main