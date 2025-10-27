#!/bin/bash

echo "🧪 Testing Microservices API..."
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Test User Service
echo "=== Testing User Service ==="
echo "1. Health Check..."
curl -s http://localhost:3001/health | jq
echo ""

echo "2. Register User..."
USER_RESPONSE=$(curl -s -X POST http://localhost:3001/api/users/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "test@example.com",
    "password": "password123"
  }')
echo $USER_RESPONSE | jq
USER_ID=$(echo $USER_RESPONSE | jq -r '.userId')
echo ""

echo "3. Login User..."
LOGIN_RESPONSE=$(curl -s -X POST http://localhost:3001/api/users/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }')
echo $LOGIN_RESPONSE | jq
TOKEN=$(echo $LOGIN_RESPONSE | jq -r '.token')
echo ""

# Test Product Service
echo "=== Testing Product Service ==="
echo "1. Health Check..."
curl -s http://localhost:3002/health | jq
echo ""

echo "2. Create Product..."
PRODUCT_RESPONSE=$(curl -s -X POST http://localhost:3002/api/products \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Laptop",
    "description": "High-performance laptop",
    "price": 999.99,
    "stock": 50,
    "category": "Electronics",
    "imageUrl": "https://example.com/laptop.jpg"
  }')
echo $PRODUCT_RESPONSE | jq
PRODUCT_ID=$(echo $PRODUCT_RESPONSE | jq -r '.product._id')
echo ""

echo "3. Get All Products..."
curl -s http://localhost:3002/api/products | jq
echo ""

# Test Order Service
echo "=== Testing Order Service ==="
echo "1. Health Check..."
curl -s http://localhost:3003/health | jq
echo ""

echo "2. Create Order..."
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
echo $ORDER_RESPONSE | jq
ORDER_ID=$(echo $ORDER_RESPONSE | jq -r '.order._id')
echo ""

echo "3. Get Order by ID..."
curl -s http://localhost:3003/api/orders/$ORDER_ID | jq
echo ""

echo "4. Update Order Status..."
curl -s -X PATCH http://localhost:3003/api/orders/$ORDER_ID/status \
  -H "Content-Type: application/json" \
  -d '{"status": "confirmed"}' | jq
echo ""

echo "${GREEN}✅ All tests completed!${NC}"
echo ""
echo "Summary:"
echo "  User ID: $USER_ID"
echo "  Product ID: $PRODUCT_ID"
echo "  Order ID: $ORDER_ID"
echo "  JWT Token: ${TOKEN:0:20}..."
