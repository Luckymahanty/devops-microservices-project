#!/bin/bash

# Docker Test Script - Test containerized microservices

echo "🧪 Testing Dockerized Microservices..."
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Wait for services to be healthy
echo -e "${BLUE}⏳ Waiting for services to be ready...${NC}"
sleep 10

# Function to test endpoint
test_endpoint() {
    local service=$1
    local url=$2
    local expected_status=$3
    
    echo -e "${BLUE}Testing ${service}...${NC}"
    response=$(curl -s -o /dev/null -w "%{http_code}" "$url")
    
    if [ "$response" -eq "$expected_status" ]; then
        echo -e "${GREEN}✅ ${service} is healthy (HTTP $response)${NC}"
        return 0
    else
        echo -e "${RED}❌ ${service} failed (HTTP $response)${NC}"
        return 1
    fi
}

# Test health endpoints
echo "=== Health Checks ==="
test_endpoint "User Service" "http://localhost:3001/health" 200
test_endpoint "Product Service" "http://localhost:3002/health" 200
test_endpoint "Order Service" "http://localhost:3003/health" 200
echo ""

# Test User Service
echo "=== Testing User Service ==="
echo "Registering user..."
USER_RESPONSE=$(curl -s -X POST http://localhost:3001/api/users/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "dockeruser",
    "email": "docker@example.com",
    "password": "dockerpass123"
  }')

if echo "$USER_RESPONSE" | grep -q "userId"; then
    echo -e "${GREEN}✅ User registration successful${NC}"
    USER_ID=$(echo "$USER_RESPONSE" | grep -o '"userId":"[^"]*"' | cut -d'"' -f4)
    echo "User ID: $USER_ID"
else
    echo -e "${RED}❌ User registration failed${NC}"
    echo "$USER_RESPONSE"
fi
echo ""

# Test Product Service
echo "=== Testing Product Service ==="
echo "Creating product..."
PRODUCT_RESPONSE=$(curl -s -X POST http://localhost:3002/api/products \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Docker Laptop",
    "description": "Laptop tested in Docker",
    "price": 1299.99,
    "stock": 100,
    "category": "Electronics"
  }')

if echo "$PRODUCT_RESPONSE" | grep -q "product"; then
    echo -e "${GREEN}✅ Product creation successful${NC}"
    PRODUCT_ID=$(echo "$PRODUCT_RESPONSE" | grep -o '"_id":"[^"]*"' | head -1 | cut -d'"' -f4)
    echo "Product ID: $PRODUCT_ID"
else
    echo -e "${RED}❌ Product creation failed${NC}"
    echo "$PRODUCT_RESPONSE"
fi
echo ""

# Test Order Service
echo "=== Testing Order Service ==="
if [ -n "$USER_ID" ] && [ -n "$PRODUCT_ID" ]; then
    echo "Creating order..."
    ORDER_RESPONSE=$(curl -s -X POST http://localhost:3003/api/orders \
      -H "Content-Type: application/json" \
      -d "{
        \"userId\": \"$USER_ID\",
        \"items\": [
          {
            \"productId\": \"$PRODUCT_ID\",
            \"quantity\": 2
          }
        ]
      }")

    if echo "$ORDER_RESPONSE" | grep -q "order"; then
        echo -e "${GREEN}✅ Order creation successful${NC}"
        ORDER_ID=$(echo "$ORDER_RESPONSE" | grep -o '"_id":"[^"]*"' | head -1 | cut -d'"' -f4)
        echo "Order ID: $ORDER_ID"
    else
        echo -e "${RED}❌ Order creation failed${NC}"
        echo "$ORDER_RESPONSE"
    fi
else
    echo -e "${RED}❌ Cannot test orders - missing user or product ID${NC}"
fi
echo ""

# Check container stats
echo "=== Container Status ==="
docker compose ps
echo ""

echo -e "${GREEN}🎉 Docker tests completed!${NC}"
echo ""
echo "To view logs:"
echo "  docker compose logs -f user-service"
echo "  docker compose logs -f product-service"
echo "  docker compose logs -f order-service"
echo ""
echo "To stop all containers:"
echo "  docker compose down"

