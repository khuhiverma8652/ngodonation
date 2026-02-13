const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const dotenv = require('dotenv');

// Load env variables
dotenv.config();

const app = express();

/* ======================
   MIDDLEWARE
====================== */

// CORS (Flutter friendly)
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));

// Body parser
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Request logger (VERY IMPORTANT FOR DEBUGGING)
app.use((req, res, next) => {
  console.log(`\n[${new Date().toISOString()}] ${req.method} ${req.originalUrl}`);
  if (req.method !== 'GET') {
    console.log('Body:', req.body);
  }
  next();
});

/* ======================
   DATABASE CONNECTION
====================== */

mongoose.connect(
  process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017/ngo_donation',
  {
    useNewUrlParser: true,
    useUnifiedTopology: true,
  }
)
.then(() => console.log('✓ MongoDB connected successfully'))
.catch((err) => {
  console.error('✗ MongoDB connection error:', err);
  process.exit(1);
});

/* ======================
   ROUTES IMPORT
====================== */

const authRoutes = require('./routes/authRoutes');
const campaignRoutes = require('./routes/campaignRoutes');
const donationRoutes = require('./routes/donationRoutes');
const ngoRoutes = require('./routes/ngoRoutes');
const volunteerRoutes = require('./routes/volunteerRoutes');
const adminRoutes = require('./routes/adminRoutes');
const paymentRoutes = require("./routes/paymentRoutes");


/* ======================
   ROUTES USE
====================== */

app.use('/api/auth', authRoutes);
app.use('/api/campaigns', campaignRoutes);
app.use('/api/donations', donationRoutes);
app.use('/api/ngo', ngoRoutes);
app.use('/api/volunteer', volunteerRoutes);
app.use('/api/admin', adminRoutes);
app.use("/api/payments", paymentRoutes);
/* ======================
   HEALTH CHECK
====================== */

app.get('/api/health', (req, res) => {
  res.json({
    success: true,
    message: 'NGO Donation API is running',
    time: new Date().toISOString(),
  });
});

/* ======================
   ROOT ROUTE
====================== */

app.get('/', (req, res) => {
  res.json({
    success: true,
    message: 'Welcome to NGO Donation Platform API',
    version: '1.0.0',
    endpoints: {
      auth: '/api/auth',
      campaigns: '/api/campaigns',
      donations: '/api/donations',
      ngo: '/api/ngo',
      volunteer: '/api/volunteer',
      admin: '/api/admin',
    },
  });
});

/* ======================
   404 HANDLER
====================== */

app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: 'Route not found',
  });
});

/* ======================
   ERROR HANDLER
====================== */

app.use((err, req, res, next) => {
  console.error('ERROR:', err.stack);
  res.status(err.status || 500).json({
    success: false,
    message: err.message || 'Internal Server Error',
  });
});

/* ======================
   START SERVER
====================== */

const PORT = process.env.PORT || 5000;

app.listen(PORT, '0.0.0.0', () => {
  console.log(`\n🚀 Server running on http://0.0.0.0:${PORT}`);
});

/* ======================
   UNHANDLED PROMISES
====================== */

process.on('unhandledRejection', (err) => {
  console.error('Unhandled Rejection:', err);
  process.exit(1);
});

module.exports = app;
