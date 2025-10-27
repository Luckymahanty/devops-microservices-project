# 🚀 DevOps Microservices E-Commerce Platform
by-Lucky

A production-ready microservices architecture demonstrating modern DevOps practices with complete CI/CD pipeline, containerization, and orchestration.

## 📋 Table of Contents
- [Architecture](#architecture)
- [Technologies](#technologies)
- [Services](#services)
- [Getting Started](#getting-started)
- [API Documentation](#api-documentation)
- [Testing](#testing)
- [Roadmap](#roadmap)

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    API Gateway (Future)                  │
└─────────────────────────────────────────────────────────┘
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
┌───────▼────────┐  ┌──────▼───────┐  ┌───────▼────────┐
│  User Service  │  │Product Service│  │ Order Service  │
│   (Port 3001)  │  │  (Port 3002)  │  │  (Port 3003)   │
└───────┬────────┘  └──────┬────────┘  └───────┬────────┘
        │                   │                   │
┌───────▼────────┐  ┌──────▼────────┐  ┌───────▼────────┐
│   MongoDB      │  │   MongoDB     │  │   MongoDB      │
│   (userdb)     │  │  (productdb)  │  │   (orderdb)    │
└────────────────┘  └───────────────┘  └────────────────┘
```

## 🛠️ Technologies

### Backend
- **Runtime**: Node.js 18+
- **Framework**: Express.js
- **Database**: MongoDB
- **Authentication**: JWT (JSON Web Tokens)
- **Inter-service Communication**: REST APIs with Axios

### DevOps Tools (Phases 2-8)
- **Containerization**: Docker, Docker Compose
- **Orchestration**: Kubernetes (Minikube/EKS)
- **CI/CD**: GitHub Actions / Jenkins
- **IaC**: Terraform, Ansible
- **Monitoring**: Prometheus, Grafana
- **Logging**: ELK Stack
- **GitOps**: ArgoCD
- **Security**: SonarQube, Trivy, OWASP ZAP

## 📦 Services

### 1. User Service (Port 3001)
Handles user authentication and management.

**Endpoints:**
- `POST /api/users/register` - Register new user
- `POST /api/users/login` - User login with JWT
- `GET /api/users/:id` - Get user by ID
- `GET /api/users` - Get all users
- `GET /health` - Health check

### 2. Product Service (Port 3002)
Manages product catalog and inventory.

**Endpoints:**
- `POST /api/products` - Create product
- `GET /api/products` - Get all products (with filters)
- `GET /api/products/:id` - Get product by ID
- `PUT /api/products/:id` - Update product
- `DELETE /api/products/:id` - Delete product
- `PATCH /api/products/:id/stock` - Update stock
- `GET /health` - Health check

### 3. Order Service (Port 3003)
Manages orders with inter-service communication.

**Endpoints:**
- `POST /api/orders` - Create order
- `GET /api/orders` - Get all orders
- `GET /api/orders/:id` - Get order by ID
- `GET /api/orders/user/:userId` - Get orders by user
- `PATCH /api/orders/:id/status` - Update order status
- `DELETE /api/orders/:id` - Cancel order
- `GET /health` - Health check

## 🚀 Getting Started

### Prerequisites
- Node.js 18+ installed
- MongoDB installed and running
- WSL2 (for Windows users)
- Git

### Installation

1. **Clone the repository**
```bash
git clone <your-repo-url>
cd devops-microservices-project
```

2. **Run setup script**
```bash
chmod +x setup.sh
./setup.sh
```

3. **Create environment files**
```bash
# Copy .env.example to each service
cp .env.example services/user-service/.env
cp .env.example services/product-service/.env
cp .env.example services/order-service/.env
```

4. **Start all services**
```bash
chmod +x start-all.sh
./start-all.sh
```

**OR start services individually:**

```bash
# Terminal 1 - User Service
cd services/user-service
npm install
npm start

# Terminal 2 - Product Service
cd services/product-service
npm install
npm start

# Terminal 3 - Order Service
cd services/order-service
npm install
npm start
```

### Verify Installation

```bash
# Check if all services are running
curl http://localhost:3001/health
curl http://localhost:3002/health
curl http://localhost:3003/health
```

Expected response:
```json
{
  "status": "healthy",
  "service": "user-service",
  "timestamp": "2024-10-10T10:30:00.000Z"
}
```

## 🧪 Testing

### Automated Testing
```bash
chmod +x test-api.sh
./test-api.sh
```

### Manual Testing with cURL

**1. Register a user:**
```bash
curl -X POST http://localhost:3001/api/users/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "johndoe",
    "email": "john@example.com",
    "password": "securepass123"
  }'
```

**2. Create a product:**
```bash
curl -X POST http://localhost:3002/api/products \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Laptop",
    "description": "High-performance laptop",
    "price": 999.99,
    "stock": 50,
    "category": "Electronics"
  }'
```

**3. Create an order:**
```bash
curl -X POST http://localhost:3003/api/orders \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "<USER_ID_FROM_STEP_1>",
    "items": [
      {
        "productId": "<PRODUCT_ID_FROM_STEP_2>",
        "quantity": 2
      }
    ]
  }'
```

### Postman Collection
Import `Microservices.postman_collection.json` into Postman for complete API testing.

## 📊 API Documentation

### User Service API

| Method | Endpoint | Description | Request Body |
|--------|----------|-------------|--------------|
| POST | /api/users/register | Register user | `{username, email, password}` |
| POST | /api/users/login | Login user | `{email, password}` |
| GET | /api/users/:id | Get user | - |
| GET | /api/users | Get all users | - |

### Product Service API

| Method | Endpoint | Description | Request Body |
|--------|----------|-------------|--------------|
| POST | /api/products | Create product | `{name, description, price, stock, category}` |
| GET | /api/products | Get products | Query: `?category=Electronics&minPrice=100` |
| GET | /api/products/:id | Get product | - |
| PUT | /api/products/:id | Update product | `{name, price, stock, ...}` |
| DELETE | /api/products/:id | Delete product | - |

### Order Service API

| Method | Endpoint | Description | Request Body |
|--------|----------|-------------|--------------|
| POST | /api/orders | Create order | `{userId, items: [{productId, quantity}]}` |
| GET | /api/orders | Get all orders | - |
| GET | /api/orders/:id | Get order | - |
| PATCH | /api/orders/:id/status | Update status | `{status: "confirmed"}` |

## 🗺️ Roadmap

- [x] **Phase 1**: Microservices Development (COMPLETED)
  - User Service with JWT authentication
  - Product Service with inventory management
  - Order Service with inter-service communication
  - MongoDB databases for each service
  - REST API endpoints

- [ ] **Phase 2**: Containerization
  - Dockerfile for each service
  - Docker Compose for local orchestration
  - Multi-stage builds optimization
  - Container registry setup

- [ ] **Phase 3**: CI/CD Pipeline
  - GitHub Actions workflows
  - Automated testing
  - Code quality checks (SonarQube)
  - Security scanning (Trivy)
  - Automated deployments

- [ ] **Phase 4**: Kubernetes Deployment
  - K8s manifests (Deployments, Services, ConfigMaps)
  - Helm charts
  - Ingress configuration
  - Auto-scaling (HPA)

- [ ] **Phase 5**: Infrastructure as Code
  - Terraform for AWS resources
  - Ansible for configuration management
  - Multi-environment setup

- [ ] **Phase 6**: Monitoring & Logging
  - Prometheus + Grafana
  - ELK Stack
  - Custom dashboards
  - Alerting rules

- [ ] **Phase 7**: GitOps with ArgoCD
  - ArgoCD setup
  - Automated sync from Git
  - Progressive delivery

- [ ] **Phase 8**: Security & Best Practices
  - Secrets management (Vault)
  - RBAC implementation
  - Network policies
  - SSL/TLS certificates

## 🤝 Contributing

This is a learning project. Feel free to fork and improve!

## 📝 License

MIT License

## 👤 Author

**Laxmi Kanta Mahanty**
- GitHub: [@Luckymahanty](https://github.com/Luckymahanty)
- LinkedIn: [LaxmiKanta Mahanty](http://www.linkedin.com/in/laxmi-kanta-mahanty-8abb88203)

---

⭐ **Star this repo if you find it helpful!**
