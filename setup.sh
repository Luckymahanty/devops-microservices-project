#!/bin/bash

echo "🚀 Setting up DevOps Microservices Project..."

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js first."
    exit 1
fi

echo "✅ Node.js version: $(node --version)"

# Check if MongoDB is installed
if ! command -v mongod &> /dev/null; then
    echo "⚠️  MongoDB is not installed. Installing MongoDB..."
    # Install MongoDB on WSL Ubuntu
    wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | sudo apt-key add -
    echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list
    sudo apt-get update
    sudo apt-get install -y mongodb-org
fi

# Start MongoDB
echo "🔧 Starting MongoDB..."
sudo service mongodb start

# Install dependencies for each service
services=("user-service" "product-service" "order-service")

for service in "${services[@]}"; do
    echo "📦 Installing dependencies for $service..."
    cd "services/$service"
    npm install
    cd ../..
done

echo ""
echo "✅ Setup complete!"
echo ""
echo "To start the services:"
echo "  Terminal 1: cd services/user-service && npm start"
echo "  Terminal 2: cd services/product-service && npm start"
echo "  Terminal 3: cd services/order-service && npm start"
echo ""
echo "Or use: ./start-all.sh"
