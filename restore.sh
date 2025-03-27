#!/bin/bash

# Restore script for n8n

set -e

# Check if backup file is provided
if [ -z "$1" ]; then
  echo "Error: No backup file specified."
  echo "Usage: $0 <backup_file>"
  echo "Example: $0 ./backups/n8n_backup_20230101_120000.tar.gz"
  exit 1
fi

BACKUP_FILE="$1"

# Check if backup file exists
if [ ! -f "$BACKUP_FILE" ]; then
  echo "Error: Backup file '$BACKUP_FILE' not found."
  exit 1
fi

# Confirm with user
echo "WARNING: This will replace all current n8n data with the backup."
echo "Backup file: $BACKUP_FILE"
read -p "Are you sure you want to continue? (y/N): " confirm

if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
  echo "Restore cancelled."
  exit 0
fi

# Stop n8n container
echo "Stopping n8n container..."
docker compose down n8n

# Create a temporary container to restore data
echo "Restoring data from backup..."
docker run --rm \
  -v dockertesting_n8n_data:/home/node/.n8n \
  -v "$(pwd)/$(dirname $BACKUP_FILE):/backup" \
  alpine sh -c "rm -rf /home/node/.n8n/* && tar xzf /backup/$(basename $BACKUP_FILE) -C /"

# Start n8n container
echo "Starting n8n container..."
docker compose up -d n8n

echo "Restore completed successfully."
echo "n8n is now running with the restored data."