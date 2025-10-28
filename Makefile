# Makefile for DevOps Microservices Project

.PHONY: help build up down logs test clean rebuild push

# Variables
DOCKER_REGISTRY ?= yourusername
VERSION ?= latest

# Default target
help:
	@echo "🚀 DevOps Microservices - Available Commands:"
	@echo ""
	@echo "  make build          - Build all Docker images"
	@echo "  make up             - Start all services with Docker Compose"
	@echo "  make down           - Stop all services"
	@echo "  make logs           - View logs from all services"
	@echo "  make test           - Run tests on containerized services"
	@echo "  make clean          - Remove all containers, volumes, and images"
	@echo "  make rebuild        - Clean and rebuild everything"
	@echo "  make push           - Push images to DockerHub"
	@echo "  make dev            - Start in development mode with hot reload"
	@echo "  make ps             - Show running containers"
	@echo "  make stats          - Show container resource usage"
	@echo ""

# Build all Docker images
build:
	@echo "🐳 Building Docker images..."
	@chmod +x docker-build.sh
	@./docker-build.sh

# Start all services
up:
	@echo "🚀 Starting all services..."
	docker compose up -d
	@echo "✅ Services started! Waiting for health checks..."
	@sleep 5
	@docker compose ps

# Start in development mode
dev:
	@echo "🔧 Starting in development mode..."
	docker compose -f docker-compose.dev.yml up

# Stop all services
down:
	@echo "🛑 Stopping all services..."
	docker compose down

# View logs
logs:
	docker compose logs -f

# View logs for specific service
logs-user:
	docker compose logs -f user-service

logs-product:
	docker compose logs -f product-service

logs-order:
	docker compose logs -f order-service

# Run tests
test:
	@chmod +x docker-test.sh
	@./docker-test.sh

# Show container status
ps:
	docker compose ps

# Show container resource usage
stats:
	docker stats

# Clean everything
clean:
	@echo "🧹 Cleaning up..."
	docker compose down -v
	docker system prune -f
	@echo "✅ Cleanup complete!"

# Rebuild everything from scratch
rebuild: clean build up

# Push images to DockerHub
push:
	@chmod +x docker-push.sh
	@./docker-push.sh

# Install dependencies for local development
install:
	@echo "📦 Installing dependencies..."
	cd services/user-service && npm install
	cd services/product-service && npm install
	cd services/order-service && npm install
	@echo "✅ Dependencies installed!"

# Run local development (without Docker)
run-local:
	@echo "🏃 Running services locally..."
	@chmod +x start-all.sh
	@./start-all.sh
