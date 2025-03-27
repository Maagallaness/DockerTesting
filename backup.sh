#!/bin/bash

# Automated backup script for n8n

set -e

# Configuration
BACKUP_DIR="./backups"
MAX_BACKUPS=7  # Keep only the last 7 backups
DATETIME=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/n8n_backup_$DATETIME.tar.gz"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Check if n8n is running
if ! docker compose ps | grep -q "n8n.*Up"; then
  echo "Error: n8n container is not running. Please start it before backing up."
  exit 1
fi

# Create backup
echo "Creating backup of n8n data..."
docker run --rm \
  --volumes-from $(docker compose ps -q n8n) \
  -v "$(pwd)/$BACKUP_DIR:/backup" \
  alpine tar czf "/backup/$(basename $BACKUP_FILE)" /home/node/.n8n

echo "Backup created: $BACKUP_FILE"

# Clean up old backups
echo "Cleaning up old backups..."
ls -t "$BACKUP_DIR"/n8n_backup_*.tar.gz 2>/dev/null | tail -n +$((MAX_BACKUPS+1)) | xargs -r rm

echo "Backup process completed successfully."

# Optional: Add commands here to copy backups to remote storage
# For example:
# aws s3 cp "$BACKUP_FILE" s3://your-bucket/n8n-backups/
# or
# scp "$BACKUP_FILE" user@remote-server:/path/to/backup/