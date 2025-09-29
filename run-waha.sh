#!/bin/bash

# WAHA Docker Run Script
# This script runs the WAHA (WhatsApp HTTP API) container

# Check if .env file exists
if [ ! -f .env ]; then
    echo "Error: .env file not found!"
    echo "Please create .env file with required configuration."
    exit 1
fi

# Load environment variables from .env file
set -a  # automatically export all variables
source .env
set +a

echo "Starting WAHA container..."
echo "Loading configuration from .env file..."

# Check if container already exists and stop/remove it
if docker ps -a --format 'table {{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "Found existing container '${CONTAINER_NAME}'. Stopping and removing..."

    # Stop the container if it's running
    if docker ps --format 'table {{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        echo "Stopping container '${CONTAINER_NAME}'..."
        docker stop ${CONTAINER_NAME}
    fi

    # Remove the container
    echo "Removing container '${CONTAINER_NAME}'..."
    docker rm ${CONTAINER_NAME}
    echo "Previous container removed successfully."
fi

echo "Pulling latest WAHA image..."
docker pull devlikeapro/waha

if [ $? -eq 0 ]; then
    echo "Image pulled successfully!"
else
    echo "Warning: Failed to pull latest image. Using cached version..."
fi

echo "Creating new WAHA container... ${HOST_PORT}"

docker run -d \
  -v $(pwd)/${SESSIONS_PATH}:/app/.sessions \
  -p ${HOST_PORT:-3000}:${CONTAINER_PORT:-3000} \
  --name ${CONTAINER_NAME} \
  -e WAHA_API_KEY=${WAHA_API_KEY} \
  -e WAHA_API_KEY_PLAIN=${WAHA_API_KEY_PLAIN} \
  -e WAHA_APPS_ENABLED=${WAHA_APPS_ENABLED} \
  -e WAHA_DASHBOARD_USERNAME=${WAHA_DASHBOARD_USERNAME} \
  -e WAHA_DASHBOARD_PASSWORD=${WAHA_DASHBOARD_PASSWORD} \
  devlikeapro/waha

if [ $? -eq 0 ]; then
    echo "WAHA container started successfully!"
    echo "Dashboard will be available at: http://localhost:${HOST_PORT}"
    echo "Username: ${WAHA_DASHBOARD_USERNAME}"
    echo "Password: ${WAHA_DASHBOARD_PASSWORD}"
    echo ""
    echo "To check container status: docker ps"
    echo "To view logs: docker logs ${CONTAINER_NAME}"
    echo "To stop container: docker stop ${CONTAINER_NAME}"
    echo "To remove container: docker rm ${CONTAINER_NAME}"
else
    echo "Failed to start WAHA container"
    exit 1
fi
