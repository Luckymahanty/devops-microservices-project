#!/bin/bash

# Docker Push Script - Push images to DockerHub
# Make sure to run 'docker login' first

set -e

echo "🚀 Pushing Docker images to DockerHub..."
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Your DockerHub username (locked to alpha0029)
DOCKER_REGISTRY="alpha0029"
VERSION=${VERSION:-"latest"}

# Ensure Docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}❌ Docker is not running. Please start Docker first.${NC}"
    exit 1
fi

echo -e "${BLUE}📦 Using DockerHub registry: ${DOCKER_REGISTRY}${NC}"
echo ""

# Push User Service
echo -e "${BLUE}📤 Pushing User Service...${NC}"
docker push ${DOCKER_REGISTRY}/user-service:${VERSION}
docker push ${DOCKER_REGISTRY}/user-service:latest
echo -e "${GREEN}✅ User Service pushed successfully${NC}"
echo ""

# Push Product Service
echo -e "${BLUE}📤 Pushing Product Service...${NC}"
docker push ${DOCKER_REGISTRY}/product-service:${VERSION}
docker push ${DOCKER_REGISTRY}/product-service:latest
echo -e "${GREEN}✅ Product Service pushed successfully${NC}"
echo ""

# Push Order Service
echo -e "${BLUE}📤 Pushing Order Service...${NC}"
docker push ${DOCKER_REGISTRY}/order-service:${VERSION}
docker push ${DOCKER_REGISTRY}/order-service:latest
echo -e "${GREEN}✅ Order Service pushed successfully${NC}"
echo ""

# Done
echo -e "${GREEN}🎉 All images pushed successfully!${NC}"
echo ""
echo "Your images are now available at:"
echo "  🔗 https://hub.docker.com/r/${DOCKER_REGISTRY}/user-service"
echo "  🔗 https://hub.docker.com/r/${DOCKER_REGISTRY}/product-service"
echo "  🔗 https://hub.docker.com/r/${DOCKER_REGISTRY}/order-service"

