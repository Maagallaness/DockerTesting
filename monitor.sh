#!/bin/bash

# Monitoring script for n8n

set -e

# Configuration
N8N_URL="http://localhost:5678"
HEALTH_ENDPOINT="/healthz"
LOG_FILE="./logs/n8n_monitor.log"
ALERT_EMAIL="your-email@example.com"  # Change this to your email

# Create logs directory if it doesn't exist
mkdir -p "./logs"

# Log function
log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Check if n8n container is running
check_container() {
  if ! docker compose ps | grep -q "n8n.*Up"; then
    log "ERROR: n8n container is not running!"
    return 1
  else
    log "INFO: n8n container is running."
    return 0
  fi
}

# Check n8n health endpoint
check_health() {
  local status_code
  status_code=$(curl -s -o /dev/null -w "%{http_code}" "$N8N_URL$HEALTH_ENDPOINT")
  
  if [ "$status_code" -eq 200 ]; then
    log "INFO: n8n health check passed (HTTP $status_code)."
    return 0
  else
    log "ERROR: n8n health check failed (HTTP $status_code)!"
    return 1
  fi
}

# Check system resources
check_resources() {
  # Get container stats
  local stats
  stats=$(docker stats --no-stream --format "{{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}" | grep n8n)
  
  log "INFO: Resource usage: $stats"
  
  # Extract memory usage percentage
  local mem_usage
  mem_usage=$(echo "$stats" | awk '{print $3}' | grep -o '[0-9.]*%' | grep -o '[0-9.]*')
  
  # Alert if memory usage is above 90%
  if (( $(echo "$mem_usage > 90" | bc -l) )); then
    log "WARNING: High memory usage detected: $mem_usage%"
    return 1
  fi
  
  return 0
}

# Send alert
send_alert() {
  local message="$1"
  log "Sending alert: $message"
  
  # Uncomment and modify one of these methods to enable alerting
  
  # Email alert using mail command
  # echo "$message" | mail -s "n8n Alert: Issue Detected" "$ALERT_EMAIL"
  
  # Slack webhook alert
  # curl -X POST -H 'Content-type: application/json' \
  #   --data "{\"text\":\"$message\"}" \
  #   https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK
}

# Main monitoring function
monitor() {
  log "Starting n8n monitoring check..."
  
  local has_error=0
  
  # Run checks
  check_container || has_error=1
  check_health || has_error=1
  check_resources || has_error=1
  
  # Send alert if any check failed
  if [ $has_error -eq 1 ]; then
    send_alert "n8n monitoring detected issues. Please check the logs at $LOG_FILE"
  fi
  
  log "Monitoring check completed."
}

# Run the monitoring
monitor