#!/bin/bash

# WAHA Docker Stop Script
# This script stops and removes the WAHA container

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

echo "Stopping WAHA container..."

# Check if container exists
if docker ps -a --format 'table {{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    # Stop the container if it's running
    if docker ps --format 'table {{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        echo "Stopping container '${CONTAINER_NAME}'..."
        docker stop ${CONTAINER_NAME}
        if [ $? -eq 0 ]; then
            echo "Container stopped successfully!"
        else
            echo "Failed to stop container"
            exit 1
        fi
    else
        echo "Container '${CONTAINER_NAME}' is already stopped."
    fi

    # Remove the container
    echo "Removing container '${CONTAINER_NAME}'..."
    docker rm ${CONTAINER_NAME}
    if [ $? -eq 0 ]; then
        echo "Container removed successfully!"
    else
        echo "Failed to remove container"
        exit 1
    fi
else
    echo "Container '${CONTAINER_NAME}' does not exist."
fi

echo "Cleanup completed."
