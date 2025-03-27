#!/bin/bash

# Helper script for managing n8n Docker deployment

set -e

function show_help {
  echo "Usage: ./n8n-docker.sh [command]"
  echo ""
  echo "Commands:"
  echo "  start       - Start n8n containers"
  echo "  stop        - Stop n8n containers"
  echo "  restart     - Restart n8n containers"
  echo "  logs        - Show logs from n8n container"
  echo "  status      - Show status of containers"
  echo "  backup      - Create a backup of n8n data"
  echo "  update      - Update n8n to latest version"
  echo "  reset       - Reset n8n (WARNING: Deletes all data)"
  echo "  help        - Show this help message"
}

function start_containers {
  echo "Starting n8n containers..."
  docker compose up -d
  echo "n8n is now running at http://localhost:5678"
}

function stop_containers {
  echo "Stopping n8n containers..."
  docker compose down
}

function show_logs {
  echo "Showing logs from n8n container..."
  docker compose logs -f n8n
}

function show_status {
  echo "Container status:"
  docker compose ps
}

function create_backup {
  BACKUP_DIR="./backups"
  BACKUP_FILE="$BACKUP_DIR/n8n_backup_$(date +%Y%m%d_%H%M%S).tar"
  
  mkdir -p "$BACKUP_DIR"
  
  echo "Creating backup of n8n data..."
  docker run --rm \
    --volumes-from $(docker compose ps -q n8n) \
    -v "$(pwd)/$BACKUP_DIR:/backup" \
    alpine tar cf "/backup/$(basename $BACKUP_FILE)" /home/node/.n8n
  
  echo "Backup created: $BACKUP_FILE"
}

function update_n8n {
  echo "Updating n8n to latest version..."
  docker compose pull
  docker compose down
  docker compose up -d
  echo "n8n has been updated and restarted."
}

function reset_n8n {
  echo "WARNING: This will delete all n8n data!"
  read -p "Are you sure you want to continue? (y/N): " confirm
  
  if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
    echo "Stopping containers..."
    docker compose down
    
    echo "Removing n8n data volume..."
    docker volume rm dockertesting_n8n_data
    
    echo "Starting fresh n8n instance..."
    docker compose up -d
    
    echo "n8n has been reset and is now running with fresh data."
  else
    echo "Reset operation cancelled."
  fi
}

# Main script execution
case "$1" in
  start)
    start_containers
    ;;
  stop)
    stop_containers
    ;;
  restart)
    stop_containers
    start_containers
    ;;
  logs)
    show_logs
    ;;
  status)
    show_status
    ;;
  backup)
    create_backup
    ;;
  update)
    update_n8n
    ;;
  reset)
    reset_n8n
    ;;
  help|*)
    show_help
    ;;
esac