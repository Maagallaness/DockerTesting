# n8n Docker Setup

This repository contains a Docker-based setup for running [n8n](https://n8n.io/), a workflow automation tool.

## Prerequisites

- Docker and Docker Compose installed on your system
- Basic knowledge of Docker and containerization

## Quick Start

1. Clone this repository
2. Copy the example environment file: `cp .env.example .env`
3. Start n8n: `docker compose up -d`
4. Access n8n at: http://localhost:5678

## Configuration

### Environment Variables

Copy the example environment file and modify as needed:

```bash
cp .env.example .env
```

Edit the `.env` file to configure your n8n instance. Important variables include:

- `N8N_HOST`: The host name n8n runs on (default: localhost)
- `N8N_PROTOCOL`: Protocol to use (http/https)
- `N8N_ENCRYPTION_KEY`: Secret key for encryption (required for production)

See the `.env.example` file for more configuration options.

### Database Options

By default, n8n uses SQLite for data storage. For production use, it's recommended to use PostgreSQL:

1. Uncomment the PostgreSQL service in `docker-compose.yml`
2. Uncomment the database environment variables in the n8n service
3. Restart the containers: `docker compose down && docker compose up -d`

## Usage

### Using Docker Compose

```bash
# Start containers
docker compose up -d

# View logs
docker compose logs -f

# Stop containers
docker compose down

# Update to latest version
docker compose pull
docker compose down
docker compose up -d
```

### Using Helper Script

This repository includes a helper script for common operations:

```bash
# Make the script executable
chmod +x n8n-docker.sh

# Start n8n
./n8n-docker.sh start

# View logs
./n8n-docker.sh logs

# Stop n8n
./n8n-docker.sh stop

# Create a backup
./n8n-docker.sh backup

# Update n8n
./n8n-docker.sh update
```

Run `./n8n-docker.sh help` to see all available commands.

## Data Persistence

All n8n data is stored in a Docker volume named `n8n_data`. This ensures your workflows and credentials persist across container restarts.

## Production Deployment

For production deployments, consider the following:

1. Use PostgreSQL instead of SQLite
2. Set `NODE_ENV=production`
3. Configure a proper `N8N_ENCRYPTION_KEY`
4. Set up proper authentication
5. Consider using a reverse proxy (like Nginx or Traefik) for SSL termination

## Troubleshooting

### Container won't start

Check the logs for errors:

```bash
docker compose logs n8n
```

### Data persistence issues

Ensure the Docker volume is properly created:

```bash
docker volume ls | grep n8n_data
```

## Reference Commands

### Docker Image Management

```bash
# Pull latest (stable) version
docker pull docker.n8n.io/n8nio/n8n

# Pull specific version
docker pull docker.n8n.io/n8nio/n8n:1.81.0

# Pull next (unstable) version
docker pull docker.n8n.io/n8nio/n8n:next
```

### Manual Container Management

```bash
# Find your container ID
docker ps -a

# Stop the container
docker stop <container_id>

# Remove the container
docker rm <container_id>

# Start a container manually
docker run -it --rm --name n8n -p 5678:5678 -v n8n_data:/home/node/.n8n docker.n8n.io/n8nio/n8n
```

