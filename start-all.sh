#!/bin/bash

echo "🚀 Starting all microservices..."

# Start MongoDB
sudo service mongodb start

# Function to start a service in the background
start_service() {
    local service=$1
    local port=$2
    echo "Starting $service on port $port..."
    cd "services/$service"
    PORT=$port npm start &
    cd ../..
}

# Start all services
start_service "user-service" 3001
sleep 2
start_service "product-service" 3002
sleep 2
start_service "order-service" 3003

echo ""
echo "✅ All services started!"
echo ""
echo "Service URLs:"
echo "  User Service:    http://localhost:3001"
echo "  Product Service: http://localhost:3002"
echo "  Order Service:   http://localhost:3003"
echo ""
echo "Health checks:"
echo "  curl http://localhost:3001/health"
echo "  curl http://localhost:3002/health"
echo "  curl http://localhost:3003/health"
echo ""
echo "To stop all services: ./stop-all.sh"

# Keep script running
wait
