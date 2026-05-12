#!/bin/bash
# Author: Prof. Mehdi Pirahandeh
:'
Explanation of the Script:
Initial Setup and Package Installation: Updates the system and installs ssh and rsync, which are necessary for remote file transfers.
Local Archiving Examples: Demonstrates how to create archives using different compression methods (gzip, bzip2, xz) and how to extract them.
Remote Archiving Examples: Shows how to use tar in conjunction with ssh to archive and transfer files remotely, including a hypothetical example of backing up to a cloud service.
Advanced Tar Operations: Introduces incremental backups, handling of large directories with split archives, and archive integrity verification.
Educational Goal: Each command includes comments explaining its purpose, aiming to provide a practical learning experience on file management and archiving techniques.
This script is designed to be comprehensive, providing hands-on experience with a wide range of scenarios involving the tar command, suitable for both local and remote file management contexts.
'
# The script to understand archiving and transferring files on Ubuntu 20.04
# This script covers the use of the tar command for local and remote archiving.

echo "Starting the archiving and file transfer lab script..."

# Ensure script is running with root privileges for certain operations
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# 1. Update the system
echo "Updating the system..."
sudo apt-get update

# 2. Install necessary packages
echo "Installing ssh and rsync for remote operations..."
sudo apt-get install -y ssh rsync

# Example 1: Creating a simple archive of a directory
echo "Archiving the /etc directory..."
tar -cvf /tmp/etc_backup.tar /etc

# Example 2-4: Adding compression with gzip, bzip2, and xz
echo "Creating a gzip-compressed archive..."
tar -czvf /tmp/etc_backup.tar.gz /etc

echo "Creating a bzip2-compressed archive..."
tar -cjvf /tmp/etc_backup.tar.bz2 /etc

echo "Creating an xz-compressed archive..."
tar -cJvf /tmp/etc_backup.tar.xz /etc

# Example 5-7: Extracting archives
echo "Extracting the gzip-compressed archive..."
tar -xzvf /tmp/etc_backup.tar.gz -C /tmp/etc_restore

echo "Extracting the bzip2-compressed archive..."
tar -xjvf /tmp/etc_backup.tar.bz2 -C /tmp/etc_restore

echo "Extracting the xz-compressed archive..."
tar -xJvf /tmp/etc_backup.tar.xz -C /tmp/etc_restore

# Example 8-10: Using tar with ssh for remote operations
echo "Archiving and transferring a directory to a remote server..."
tar czvf - /etc | ssh user@remotehost "cat > /remote/path/etc_backup.tar.gz"

echo "Retrieving an archive from a remote server..."
ssh user@remotehost "tar czvf - /remote/path" | tar xzvf - -C /local/path

echo "Backing up and archiving directly to a cloud service (assuming mounted cloud storage)..."
tar czvf /mnt/cloud_storage/etc_backup.tar.gz /etc

# Example 11-15: Advanced tar operations
echo "Creating incremental backups of /etc..."
tar -czvf /tmp/etc_backup_inc.tar.gz --listed-incremental=/tmp/snapshot.file /etc

echo "Restoring from an incremental backup..."
tar -xzvf /tmp/etc_backup_inc.tar.gz -C /tmp/etc_restore --listed-incremental=/tmp/snapshot.file

echo "Creating split archives of a large directory..."
tar cvzf - /var | split --bytes=100M - /tmp/var_backup.tar.gz.part

echo "Combining split archives for extraction..."
cat /tmp/var_backup.tar.gz.part* | tar xzvf - -C /tmp/var_restore

echo "Using tar to verify the integrity of an archive..."
tar --verify -xzf /tmp/etc_backup.tar.gz

# Example 16: Explain configuration persistence and management
echo "All configurations should be properly managed through configuration management tools or version control systems."

# Script completion
echo "Archiving and file transfer educational script has completed. Check /tmp for outputs."

# This script teaches students about various aspects of file archiving and transferring,
# using tar for local and remote operations, and handling different compression formats.
