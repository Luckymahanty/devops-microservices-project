#!/bin/bash

# Kubernetes Deployment Script

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🚀 Deploying Microservices to Kubernetes${NC}"
echo ""

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}❌ kubectl not found. Please install kubectl first.${NC}"
    exit 1
fi

# Check if cluster is accessible
if ! kubectl cluster-info &> /dev/null; then
    echo -e "${RED}❌ Cannot connect to Kubernetes cluster.${NC}"
    echo "Please ensure your cluster is running (minikube start or connect to cloud cluster)"
    exit 1
fi

echo -e "${GREEN}✅ Connected to Kubernetes cluster${NC}"
echo ""

# Prompt for Docker registry username
read -p "Enter your DockerHub username (default: yourusername): " DOCKER_USER
DOCKER_USER=${DOCKER_USER:-yourusername}

echo -e "${BLUE}📦 Using Docker registry: $DOCKER_USER${NC}"
echo ""

# Update image names in deployment files
echo -e "${BLUE}📝 Updating deployment files with Docker registry...${NC}"
sed -i.bak "s/yourusername/$DOCKER_USER/g" user-service.yaml product-service.yaml order-service.yaml
rm -f *.bak

# Step 1: Create Namespace
echo -e "${BLUE}1️⃣  Creating namespace...${NC}"
kubectl apply -f namespace.yaml
echo ""

# Step 2: Create ConfigMap and Secrets
echo -e "${BLUE}2️⃣  Creating ConfigMap and Secrets...${NC}"
kubectl apply -f configmap.yaml

# Create Docker registry secret
echo -e "${YELLOW}⚠️  Creating Docker registry secret...${NC}"
echo "Please enter your DockerHub credentials:"
read -p "DockerHub username: " DOCKER_USERNAME
read -sp "DockerHub password/token: " DOCKER_PASSWORD
echo ""
read -p "DockerHub email: " DOCKER_EMAIL

kubectl create secret docker-registry docker-registry-secret \
  --docker-server=https://index.docker.io/v1/ \
  --docker-username="$DOCKER_USERNAME" \
  --docker-password="$DOCKER_PASSWORD" \
  --docker-email="$DOCKER_EMAIL" \
  -n microservices \
  --dry-run=client -o yaml | kubectl apply -f -

# Apply other secrets
kubectl apply -f secrets.yaml
echo ""

# Step 3: Deploy MongoDB instances
echo -e "${BLUE}3️⃣  Deploying MongoDB instances...${NC}"
kubectl apply -f mongodb.yaml
echo "Waiting for MongoDB pods to be ready..."
kubectl wait --for=condition=ready pod -l app=user-db -n microservices --timeout=120s
kubectl wait --for=condition=ready pod -l app=product-db -n microservices --timeout=120s
kubectl wait --for=condition=ready pod -l app=order-db -n microservices --timeout=120s
echo -e "${GREEN}✅ MongoDB instances ready${NC}"
echo ""

# Step 4: Deploy Microservices
echo -e "${BLUE}4️⃣  Deploying microservices...${NC}"
kubectl apply -f user-service.yaml
kubectl apply -f product-service.yaml
kubectl apply -f order-service.yaml

echo "Waiting for services to be ready..."
sleep 10
kubectl wait --for=condition=ready pod -l app=user-service -n microservices --timeout=120s
kubectl wait --for=condition=ready pod -l app=product-service -n microservices --timeout=120s
kubectl wait --for=condition=ready pod -l app=order-service -n microservices --timeout=120s
echo -e "${GREEN}✅ Microservices deployed${NC}"
echo ""

# Step 5: Apply Network Policies
echo -e "${BLUE}5️⃣  Applying network policies...${NC}"
kubectl apply -f network-policy.yaml
echo -e "${GREEN}✅ Network policies applied${NC}"
echo ""

# Step 6: Deploy Ingress
echo -e "${BLUE}6️⃣  Deploying Ingress...${NC}"
kubectl apply -f ingress.yaml
echo -e "${GREEN}✅ Ingress configured${NC}"
echo ""

# Display deployment status
echo -e "${GREEN}🎉 Deployment Complete!${NC}"
echo ""
echo -e "${BLUE}📊 Deployment Status:${NC}"
kubectl get all -n microservices
echo ""

echo -e "${BLUE}🌐 Access Information:${NC}"
if command -v minikube &> /dev/null && minikube status &> /dev/null; then
    MINIKUBE_IP=$(minikube ip)
    echo "Minikube IP: $MINIKUBE_IP"
    echo "Add to /etc/hosts: $MINIKUBE_IP microservices.local"
    echo ""
    echo "Access services at:"
    echo "  http://microservices.local/api/users"
    echo "  http://microservices.local/api/products"
    echo "  http://microservices.local/api/orders"
else
    echo "Get external IP with: kubectl get ingress -n microservices"
fi

echo ""
echo -e "${YELLOW}📝 Useful commands:${NC}"
echo "  kubectl get pods -n microservices"
echo "  kubectl logs -f <pod-name> -n microservices"
echo "  kubectl describe pod <pod-name> -n microservices"
echo "  kubectl port-forward -n microservices svc/user-service 3001:3001"
echo ""
