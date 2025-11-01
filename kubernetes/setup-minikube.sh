#!/bin/bash

# Minikube Setup Script for WSL

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🚀 Setting up Minikube on WSL${NC}"
echo ""

# Install kubectl
echo -e "${BLUE}1️⃣  Installing kubectl...${NC}"
if ! command -v kubectl &> /dev/null; then
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm kubectl
    echo -e "${GREEN}✅ kubectl installed${NC}"
else
    echo -e "${GREEN}✅ kubectl already installed${NC}"
fi
echo ""

# Install minikube
echo -e "${BLUE}2️⃣  Installing Minikube...${NC}"
if ! command -v minikube &> /dev/null; then
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    sudo install minikube-linux-amd64 /usr/local/bin/minikube
    rm minikube-linux-amd64
    echo -e "${GREEN}✅ Minikube installed${NC}"
else
    echo -e "${GREEN}✅ Minikube already installed${NC}"
fi
echo ""

# Start minikube
echo -e "${BLUE}3️⃣  Starting Minikube cluster...${NC}"
echo "This may take a few minutes..."
minikube start --driver=docker --cpus=4 --memory=4096 --disk-size=20g

echo -e "${GREEN}✅ Minikube cluster started${NC}"
echo ""

# Enable addons
echo -e "${BLUE}4️⃣  Enabling Minikube addons...${NC}"
minikube addons enable ingress
minikube addons enable metrics-server
minikube addons enable dashboard
echo -e "${GREEN}✅ Addons enabled${NC}"
echo ""

# Verify installation
echo -e "${BLUE}5️⃣  Verifying installation...${NC}"
kubectl cluster-info
kubectl get nodes
echo ""

echo -e "${GREEN}🎉 Minikube setup complete!${NC}"
echo ""
echo -e "${YELLOW}📝 Useful commands:${NC}"
echo "  minikube status              - Check cluster status"
echo "  minikube stop                - Stop the cluster"
echo "  minikube start               - Start the cluster"
echo "  minikube dashboard           - Open Kubernetes dashboard"
echo "  minikube service list        - List all services"
echo "  minikube ip                  - Get cluster IP"
echo "  kubectl get pods -A          - List all pods"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "  1. Run: ./deploy.sh"
echo "  2. Add Minikube IP to /etc/hosts:"
echo "     echo \"\$(minikube ip) microservices.local\" | sudo tee -a /etc/hosts"
echo ""
