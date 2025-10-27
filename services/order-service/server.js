// services/order-service/server.js
const express = require('express');
const mongoose = require('mongoose');
const axios = require('axios');
const cors = require('cors');

const app = express();
app.use(express.json());
app.use(cors());

// Service URLs (will be environment variables in production)
const USER_SERVICE_URL = process.env.USER_SERVICE_URL || 'http://localhost:3001';
const PRODUCT_SERVICE_URL = process.env.PRODUCT_SERVICE_URL || 'http://localhost:3002';

// MongoDB connection
const MONGO_URI = process.env.MONGO_URI || 'mongodb://localhost:27017/orderdb';
mongoose.connect(MONGO_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
}).then(() => console.log('✅ Connected to MongoDB'))
  .catch(err => console.error('❌ MongoDB connection error:', err));

// Order Schema
const orderSchema = new mongoose.Schema({
  userId: { type: String, required: true },
  items: [{
    productId: { type: String, required: true },
    productName: { type: String, required: true },
    quantity: { type: Number, required: true },
    price: { type: Number, required: true }
  }],
  totalAmount: { type: Number, required: true },
  status: { 
    type: String, 
    enum: ['pending', 'confirmed', 'shipped', 'delivered', 'cancelled'],
    default: 'pending'
  },
  createdAt: { type: Date, default: Date.now }
});

const Order = mongoose.model('Order', orderSchema);

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ 
    status: 'healthy', 
    service: 'order-service',
    timestamp: new Date().toISOString()
  });
});

// Create order (with inter-service communication)
app.post('/api/orders', async (req, res) => {
  try {
    const { userId, items } = req.body;

    // Validate input
    if (!userId || !items || items.length === 0) {
      return res.status(400).json({ error: 'Invalid order data' });
    }

    // Verify user exists
    try {
      await axios.get(`${USER_SERVICE_URL}/api/users/${userId}`);
    } catch (error) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Verify products and calculate total
    let totalAmount = 0;
    const orderItems = [];

    for (const item of items) {
      try {
        // Get product details
        const productResponse = await axios.get(
          `${PRODUCT_SERVICE_URL}/api/products/${item.productId}`
        );
        const product = productResponse.data;

        // Check stock availability
        if (product.stock < item.quantity) {
          return res.status(400).json({ 
            error: `Insufficient stock for product: ${product.name}` 
          });
        }

        // Update stock
        await axios.patch(
          `${PRODUCT_SERVICE_URL}/api/products/${item.productId}/stock`,
          { quantity: item.quantity }
        );

        orderItems.push({
          productId: product._id,
          productName: product.name,
          quantity: item.quantity,
          price: product.price
        });

        totalAmount += product.price * item.quantity;
      } catch (error) {
        return res.status(404).json({ 
          error: `Product not found: ${item.productId}` 
        });
      }
    }

    // Create order
    const order = new Order({
      userId,
      items: orderItems,
      totalAmount,
      status: 'pending'
    });

    await order.save();

    res.status(201).json({
      message: 'Order created successfully',
      order
    });
  } catch (error) {
    console.error('Create order error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// Get all orders
app.get('/api/orders', async (req, res) => {
  try {
    const orders = await Order.find();
    res.json(orders);
  } catch (error) {
    console.error('Get orders error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// Get order by ID
app.get('/api/orders/:id', async (req, res) => {
  try {
    const order = await Order.findById(req.params.id);
    if (!order) {
      return res.status(404).json({ error: 'Order not found' });
    }
    res.json(order);
  } catch (error) {
    console.error('Get order error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// Get orders by user ID
app.get('/api/orders/user/:userId', async (req, res) => {
  try {
    const orders = await Order.find({ userId: req.params.userId });
    res.json(orders);
  } catch (error) {
    console.error('Get user orders error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// Update order status
app.patch('/api/orders/:id/status', async (req, res) => {
  try {
    const { status } = req.body;
    
    const validStatuses = ['pending', 'confirmed', 'shipped', 'delivered', 'cancelled'];
    if (!validStatuses.includes(status)) {
      return res.status(400).json({ error: 'Invalid status' });
    }

    const order = await Order.findByIdAndUpdate(
      req.params.id,
      { status },
      { new: true }
    );

    if (!order) {
      return res.status(404).json({ error: 'Order not found' });
    }

    res.json({
      message: 'Order status updated successfully',
      order
    });
  } catch (error) {
    console.error('Update order status error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// Delete order (cancel)
app.delete('/api/orders/:id', async (req, res) => {
  try {
    const order = await Order.findByIdAndDelete(req.params.id);
    if (!order) {
      return res.status(404).json({ error: 'Order not found' });
    }
    res.json({ message: 'Order cancelled successfully' });
  } catch (error) {
    console.error('Delete order error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

const PORT = process.env.PORT || 3003;
app.listen(PORT, () => {
  console.log(`🚀 Order Service running on port ${PORT}`);
});
