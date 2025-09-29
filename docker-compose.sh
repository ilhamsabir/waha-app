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

# Function to show usage
show_help() {
    echo "WAHA Docker Compose Management Script"
    echo ""
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  up              Start WAHA services (production mode with host network)"
    echo "  up-dev          Start WAHA services (development mode with port mapping)"
    echo "  up-redis        Start only Redis service"
    echo "  down            Stop and remove all services"
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
    echo "  $0 up                    # Start production services"
    echo "  $0 up-dev                # Start development services"
    echo "  $0 logs -f               # Follow logs in real-time"
    echo "  $0 down                  # Stop all services"
}

# Main command handling
case "${1:-help}" in
    "up")
        print_status "Starting WAHA services (Production mode)..."
        docker-compose --profile production up -d
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

    "up-dev")
        print_status "Starting WAHA services (Development mode)..."
        docker-compose --profile development up -d
        if [ $? -eq 0 ]; then
            print_status "WAHA (Dev) started successfully!"
            print_info "Dashboard: http://localhost:${HOST_PORT:-3000}"
            print_info "Username: ${WAHA_DASHBOARD_USERNAME:-admin}"
            print_info "Password: ${WAHA_DASHBOARD_PASSWORD:-admin}"
        else
            print_error "Failed to start WAHA development services"
            exit 1
        fi
        ;;

    "up-redis")
        print_status "Starting Redis service only..."
        docker-compose --profile redis up -d redis
        if [ $? -eq 0 ]; then
            print_status "Redis started successfully!"
        else
            print_error "Failed to start Redis service"
            exit 1
        fi
        ;;

    "down")
        print_status "Stopping WAHA services..."
        docker-compose --profile production --profile development down
        print_status "All services stopped"
        ;;

    "restart")
        print_status "Restarting WAHA services..."
        docker-compose --profile production --profile development restart
        print_status "Services restarted"
        ;;

    "logs")
        shift
        docker-compose logs "$@"
        ;;

    "logs-waha")
        shift
        docker-compose logs waha waha-dev "$@"
        ;;

    "logs-redis")
        shift
        docker-compose logs redis "$@"
        ;;

    "status")
        print_status "Service status:"
        docker-compose ps
        ;;

    "pull")
        print_status "Pulling latest images..."
        docker-compose pull
        ;;

    "cleanup")
        print_warning "This will remove all containers, networks, and volumes!"
        read -p "Are you sure? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_status "Cleaning up..."
            docker-compose --profile production --profile development down -v --remove-orphans
            docker system prune -f
            print_status "Cleanup completed"
        else
            print_info "Cleanup cancelled"
        fi
        ;;

    "help"|*)
        show_help
        ;;
esac
