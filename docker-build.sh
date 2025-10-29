#!/bin/bash

# Docker Build Script for All Microservices
# This script builds Docker images for all services

set -e  # Exit on error

echo "🐳 Building Docker images for all microservices..."
echo ""

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Docker registry (change this to your DockerHub username)
DOCKER_REGISTRY=${DOCKER_REGISTRY:-"alpha0029"}
VERSION=${VERSION:-"latest"}

# Build User Service
echo -e "${BLUE}📦 Building User Service...${NC}"
docker build -t ${DOCKER_REGISTRY}/user-service:${VERSION} \
  -t ${DOCKER_REGISTRY}/user-service:latest \
  ./services/user-service

if [ $? -eq 0 ]; then
  echo -e "${GREEN}✅ User Service built successfully${NC}"
else
  echo -e "${RED}❌ User Service build failed${NC}"
  exit 1
fi
echo ""

# Build Product Service
echo -e "${BLUE}📦 Building Product Service...${NC}"
docker build -t ${DOCKER_REGISTRY}/product-service:${VERSION} \
  -t ${DOCKER_REGISTRY}/product-service:latest \
  ./services/product-service

if [ $? -eq 0 ]; then
  echo -e "${GREEN}✅ Product Service built successfully${NC}"
else
  echo -e "${RED}❌ Product Service build failed${NC}"
  exit 1
fi
echo ""

# Build Order Service
echo -e "${BLUE}📦 Building Order Service...${NC}"
docker build -t ${DOCKER_REGISTRY}/order-service:${VERSION} \
  -t ${DOCKER_REGISTRY}/order-service:latest \
  ./services/order-service

if [ $? -eq 0 ]; then
  echo -e "${GREEN}✅ Order Service built successfully${NC}"
else
  echo -e "${RED}❌ Order Service build failed${NC}"
  exit 1
fi
echo ""

echo -e "${GREEN}🎉 All images built successfully!${NC}"
echo ""
echo "Built images:"
docker images | grep -E "user-service|product-service|order-service"
echo ""
echo "To push images to DockerHub:"
echo "  1. docker login"
echo "  2. ./docker-push.sh"
echo ""
echo "To run with Docker Compose:"
echo "  docker-compose up -d"
