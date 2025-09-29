# WAHA (WhatsApp HTTP API) Docker Setup

🚀 **WAHA** adalah WhatsApp HTTP API yang memungkinkan Anda berinteraksi dengan WhatsApp melalui HTTP requests. Project ini menyediakan setup Docker yang mudah untuk menjalankan WAHA dengan konfigurasi yang fleksibel.

## 📋 Table of Contents

- [Features](#features)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [Scripts](#scripts)
- [Environment Variables](#environment-variables)
- [Usage](#usage)
- [API Documentation](#api-documentation)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)

## ✨ Features

- 🐳 **Docker containerized** - Easy deployment and management
- 🔧 **Environment-based configuration** - Flexible setup via `.env` file
- 🔄 **Auto-cleanup** - Automatic stop and removal of previous containers
- 📦 **Auto-update** - Pulls latest image before running
- 🌐 **Host networking** - Direct network access for better performance
- 🔒 **Redis integration** - Internal or external Redis support
- 🎯 **WEBJS engine** - Stable WhatsApp Web interface
- 📊 **Dashboard included** - Web-based management interface
- 🐙 **Docker Compose** - Modern container orchestration
- 🔧 **Multiple deployment modes** - Internal Redis or host networking

## 🛠 Prerequisites

- Docker and Docker Compose installed
- Git (for cloning the repository)
- Internet connection (for pulling Docker images)
- Generate SHA512 Key: https://waha.devlike.pro/docs/how-to/security/#set-api-key-hash

## 🚀 Quick Start

1. **Clone the repository:**
   ```bash
   git clone https://github.com/ilhamsabir/waha-app.git
   cd waha-app
   ```

2. **Copy and configure environment file:**
   ```bash
   cp .env.example .env
   # Edit .env file with your configuration
   ```

3. **Make scripts executable:**
   ```bash
   chmod +x run-waha.sh stop-waha.sh run-waha-simple.sh docker-compose.sh
   ```

4. **Run WAHA (Choose one method):**

   **Method 1: Docker Compose (Recommended)**
   ```bash
   ./docker-compose.sh up
   ```

5. **Access the dashboard:**
   Open http://localhost:3000 in your browser

## ⚙️ Configuration

### Environment Variables

Create a `.env` file based on `.env.example`:

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `WAHA_API_KEY` | SHA512 hashed API key for authentication | - | ✅ |
| `WAHA_API_KEY_PLAIN` | Plain text API key | - | ✅ |
| `WAHA_DASHBOARD_USERNAME` | Dashboard login username | `admin` | ✅ |
| `WAHA_DASHBOARD_PASSWORD` | Dashboard login password | `admin` | ✅ |
| `WAHA_APPS_ENABLED` | Enable WAHA apps functionality | `true` | ❌ |
| `CONTAINER_NAME` | Docker container name | `waha` | ✅ |
| `HOST_PORT` | Port to expose on host | `3000` | ✅ |
| `CONTAINER_PORT` | Internal container port | `3000` | ✅ |
| `SESSIONS_PATH` | Path to store session data | `./sessions` | ✅ |
| `REDIS_URL` | Redis connection URL (external Redis) | - | ❌ |
| `REDIS_PASSWORD` | Redis password (internal Redis) | `defaultpassword` | ❌ |

### Redis Configuration

**Two Redis Setup Options:**

**Option 1: Internal Redis (Recommended for Docker Compose)**
```env
# Local Redis password for Docker Compose
REDIS_PASSWORD=your_secure_password_here
```

**Option 2: External Redis**
```env
# External Redis connection
REDIS_URL=redis://username:password@hostname:port
```

**Benefits of Redis integration:**
- 📊 Persistent session storage
- 🔄 Support for multiple WAHA instances
- ⚡ Improved performance
- 🛡️ Data reliability

**Setup Modes:**
- **Docker Compose `up`**: Uses internal Redis container
- **Docker Compose `up-host`**: Requires external Redis
- **Shell scripts**: Uses Redis URL from environment

## 📜 Scripts

### `docker-compose.sh` (Recommended Method)
Modern Docker Compose management script with:
- ✅ Auto-cleanup of existing containers
- ✅ Multiple deployment modes (internal/external Redis)
- ✅ Comprehensive logging and monitoring
- ✅ Easy service management

**Available Commands:**
```bash
./docker-compose.sh up          # Start with internal Redis (recommended)
./docker-compose.sh up-host     # Start with host network (external Redis)
./docker-compose.sh up-redis    # Start Redis only
./docker-compose.sh down        # Stop all services
./docker-compose.sh clean       # Clean up containers
./docker-compose.sh logs -f     # Follow logs
./docker-compose.sh status      # Check status
```

### Stopping WAHA

**Docker Compose:**
```bash
./docker-compose.sh down
```

**Shell Script:**
```bash
# Use dedicated stop script
./stop-waha.sh

# Or manually
docker stop waha
docker rm waha
```

### Viewing Logs

**Docker Compose:**
```bash
# All services logs
./docker-compose.sh logs -f

# WAHA logs only
./docker-compose.sh logs-waha -f

# Redis logs only
./docker-compose.sh logs-redis -f
```

**Direct Docker:**
```bash
# Real-time logs
docker logs -f waha

# Last 100 lines
docker logs --tail 100 waha
```

### Container Management

**Docker Compose:**
```bash
# Check service status
./docker-compose.sh status

# Restart all services
./docker-compose.sh restart

# Pull latest images
./docker-compose.sh pull

# Clean up containers
./docker-compose.sh clean
```

**Direct Docker:**
```bash
# Check container status
docker ps

# Enter container shell
docker exec -it waha /bin/bash

# Restart container
docker restart waha
```

## 📚 API Documentation

Once WAHA is running, you can:

### Dashboard Access
- **URL:** http://localhost:3000
- **Username:** Set in `WAHA_DASHBOARD_USERNAME`
- **Password:** Set in `WAHA_DASHBOARD_PASSWORD`

### API Endpoints
- **Base URL:** http://localhost:3000
- **Authentication:** Use API key from `WAHA_API_KEY_PLAIN`

Example API call:
```bash
curl -X GET "http://localhost:3000/api/sessions" \
  -H "X-Api-Key: YOUR_API_KEY_PLAIN"
```

### Common API Operations

#### Start a Session
```bash
curl -X POST "http://localhost:3000/api/sessions" \
  -H "Content-Type: application/json" \
  -H "X-Api-Key: YOUR_API_KEY" \
  -d '{"name": "default", "config": {"engine": "WEBJS"}}'
```

#### Send a Message
```bash
curl -X POST "http://localhost:3000/api/sendText" \
  -H "Content-Type: application/json" \
  -H "X-Api-Key: YOUR_API_KEY" \
  -d '{
    "session": "default",
    "chatId": "628123456789@c.us",
    "text": "Hello from WAHA!"
  }'
```

## 🐛 Troubleshooting

### Common Issues

#### Container Name Conflict
```bash
Error: name already in use
```
**Solution:** Use cleanup commands
```bash
# Docker Compose
./docker-compose.sh clean
./docker-compose.sh up

# Shell Script
./stop-waha.sh
./run-waha.sh
```

#### Port Already in Use
```bash
Error: port is already allocated
```
**Solution:**
- Change `HOST_PORT` in `.env`, or
- Stop service using port 3000, or
- Use cleanup: `./docker-compose.sh clean`

#### Environment Variables Not Loading
```bash
Error: Missing required environment variables
```
**Solution:** Check `.env` file exists and has correct format

#### Redis Connection Issues
```bash
Error: Redis connection failed
```
**Solution:** Verify `REDIS_URL` format and Redis server availability

#### Ubuntu 20 Compatibility Issue
```bash
docker-compose.sh: Syntax error: "(" unexpected
```
**Solution:** Use bash explicitly:
```bash
bash ./docker-compose.sh up
```

### Debug Mode

Enable debug logging by adding to `.env`:
```env
DEBUG=true
WAHA_LOG_LEVEL=debug
```

### Health Check

Check if WAHA is responding:
```bash
curl http://localhost:3000/api/health
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔗 Links

- [WAHA Documentation](https://waha.devlike.pro/)
- [WAHA GitHub Repository](https://github.com/devlikeapro/waha)
- [Docker Hub - WAHA Image](https://hub.docker.com/r/devlikeapro/waha)

## ⭐ Support

If you find this project helpful, please give it a star! ⭐

For issues and questions:
- 🐛 [Report Bug](https://github.com/ilhamsabir/waha-app/issues)
- 💡 [Request Feature](https://github.com/ilhamsabir/waha-app/issues)
- 💬 [Discussion](https://github.com/ilhamsabir/waha-app/discussions)

---

Made with ❤️ by [Ilham Sabir](https://github.com/ilhamsabir)
