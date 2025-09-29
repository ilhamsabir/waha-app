#!/bin/bash

# WAHA Docker Compose Management Script
# This script manages WAHA using Docker Compose

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
	echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
	echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
	echo -e "${RED}[ERROR]${NC} $1"
}

print_info() {
	echo -e "${BLUE}[DEBUG]${NC} $1"
}

# Check if .env file exists
if [ ! -f .env ]; then
	print_error ".env file not found!"
	echo "Please create .env file with required configuration."
	exit 1
fi

# Load environment variables
export $(grep -v '^#' .env | grep -v '^$' | xargs)

# Function to cleanup existing containers
cleanup_containers() {
    print_status "Checking for existing containers..."

    # Stop and remove any running WAHA containers
    local containers=("${CONTAINER_NAME:-waha}" "${CONTAINER_NAME:-waha}-network" "${CONTAINER_NAME:-waha}-redis")

    for container in "${containers[@]}"; do
        if docker ps -a --format 'table {{.Names}}' | grep -q "^${container}$"; then
            print_warning "Found existing container '${container}'. Removing..."
            docker stop "$container" 2>/dev/null || true
            docker rm "$container" 2>/dev/null || true
        fi
    done

    # Also check for containers using port 3000
    local port_containers=$(docker ps --format 'table {{.Names}}\t{{.Ports}}' | grep ':3000->' | awk '{print $1}' || true)
    if [ -n "$port_containers" ]; then
        print_warning "Found containers using port 3000: $port_containers"
        echo "$port_containers" | xargs -r docker stop 2>/dev/null || true
        echo "$port_containers" | xargs -r docker rm 2>/dev/null || true
    fi

    print_status "Container cleanup completed"
}

# Function to show usage
show_help() {
	echo "WAHA Docker Compose Management Script"
	echo ""
	echo "Usage: $0 [COMMAND] [OPTIONS]"
	echo ""
	echo "Commands:"
	echo "  up              Start WAHA with internal Redis (recommended)"
	echo "  up-host         Start WAHA with host network (for external Redis)"
	echo "  up-redis        Start only Redis service"
	echo "  down            Stop and remove all services"
	echo "  clean           Clean up existing containers (run this if port conflicts occur)"
	echo "  restart         Restart all services"
	echo "  logs            Show logs from all services"
	echo "  logs-waha       Show logs from WAHA service only"
	echo "  logs-redis      Show logs from Redis service only"
	echo "  status          Show status of all services"
	echo "  pull            Pull latest images"
	echo "  cleanup         Remove all containers, networks, and volumes"
	echo "  help            Show this help message"
	echo ""
	echo "Examples:"
	echo "  $0 up                    # Start services with internal Redis"
	echo "  $0 up-host               # Start services with external Redis"
	echo "  $0 logs -f               # Follow logs in real-time"
	echo "  $0 down                  # Stop all services"
}

# Main command handling
case "${1:-help}" in
	"up")
		cleanup_containers
		print_status "Starting WAHA services with internal Redis..."
		docker compose up -d waha-network redis
		if [ $? -eq 0 ]; then
			print_status "WAHA started successfully!"
			print_info "Dashboard: http://localhost:${HOST_PORT:-3000}"
			print_info "Username: ${WAHA_DASHBOARD_USERNAME:-admin}"
			print_info "Password: ${WAHA_DASHBOARD_PASSWORD:-admin}"
		else
			print_error "Failed to start WAHA services"
			exit 1
		fi
		;;

	"up-host")
		cleanup_containers
		print_status "Starting WAHA services with host network (for external Redis)..."
		docker compose --profile production up -d waha redis
		if [ $? -eq 0 ]; then
			print_status "WAHA (Host Network) started successfully!"
			print_info "Dashboard: http://localhost:${HOST_PORT:-3000}"
			print_info "Username: ${WAHA_DASHBOARD_USERNAME:-admin}"
			print_info "Password: ${WAHA_DASHBOARD_PASSWORD:-admin}"
			print_warning "Make sure external Redis is running on localhost:6379"
		else
			print_error "Failed to start WAHA host services"
			exit 1
		fi
		;;

	"up-redis")
		cleanup_containers
		print_status "Starting Redis service only..."
		docker compose up -d redis
		if [ $? -eq 0 ]; then
			print_status "Redis started successfully!"
		else
			print_error "Failed to start Redis service"
			exit 1
		fi
		;;

	"down")
		print_status "Stopping WAHA services..."
		docker compose down
		print_status "All services stopped"
		;;

	"restart")
		print_status "Restarting WAHA services..."
		docker compose restart
		print_status "Services restarted"
		;;

	"logs")
		shift
		docker compose logs "$@"
		;;

	"logs-waha")
		shift
		docker compose logs waha "$@"
		;;

	"logs-redis")
		shift
		docker compose logs redis "$@"
		;;

	"status")
		print_status "Service status:"
		docker compose ps
		;;

	"pull")
		print_status "Pulling latest images..."
		docker compose pull
		;;

	"clean")
		cleanup_containers
		print_status "Manual cleanup completed"
		;;

	"cleanup")
		print_warning "This will remove only the 'waha' and 'redis' containers, networks, and volumes!"
		print_status "Cleaning up 'waha' and 'redis' services..."
		docker compose rm -sfv waha redis
		docker volume prune -f
		print_status "Cleanup completed"
		;;

	"help"|*)
		show_help
		;;
esac
