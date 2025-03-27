#!/bin/bash

# Script to run n8n in development mode

echo "Starting n8n in development mode..."

# Make sure we have the latest image
docker pull docker.n8n.io/n8nio/n8n

# Run n8n with development settings
docker run -it --rm \
  --name n8n-dev \
  -p 5678:5678 \
  -v "$(pwd)/data:/home/node/.n8n" \
  -e N8N_DIAGNOSTICS_ENABLED=false \
  -e N8N_HIRING_BANNER_ENABLED=false \
  -e NODE_ENV=development \
  -e N8N_HOST=localhost \
  -e N8N_PORT=5678 \
  -e N8N_PROTOCOL=http \
  -e WEBHOOK_URL=http://localhost:5678/ \
  docker.n8n.io/n8nio/n8n