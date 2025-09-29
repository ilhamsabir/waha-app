#!/bin/bash

# WAHA Docker Run Script - Alternative Version
# This script runs the WAHA (WhatsApp HTTP API) container

# Check if .env file exists
if [ ! -f .env ]; then
    echo "Error: .env file not found!"
    exit 1
fi

# Read .env file and set variables manually
while IFS='=' read -r key value; do
    # Skip comments and empty lines
    [[ $key =~ ^#.*$ ]] && continue
    [[ -z $key ]] && continue

    # Remove quotes if present
    value=$(echo "$value" | sed 's/^["'\'']//' | sed 's/["'\'']$//')

    # Export the variable
    export "$key"="$value"
done < .env

echo "Starting WAHA container..."

# Stop and remove existing container
if docker ps -a | grep -q "waha"; then
    echo "Stopping and removing existing container..."
    docker stop waha 2>/dev/null
    docker rm waha 2>/dev/null
fi

# Pull latest image
echo "Pulling latest image..."
docker pull devlikeapro/waha

# Run container
echo "Creating new container..."
docker run -d \
  -v "$(pwd)/sessions:/app/.sessions" \
  -p "3000:3000" \
  --name "waha" \
  --env-file .env \
  devlikeapro/waha

if [ $? -eq 0 ]; then
    echo "WAHA container started successfully!"
    echo "Dashboard: http://localhost:3000"
else
    echo "Failed to start container"
    exit 1
fi
