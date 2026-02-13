# NGO Donation Platform - Backend API

Node.js/Express backend for the NGO Donation Platform with MongoDB, JWT authentication, and Razorpay payment integration.

## 🚀 Quick Start

### Prerequisites

- Node.js (v16 or higher)
- MongoDB (v5 or higher)
- npm or yarn

### Installation

```bash
# Install dependencies
npm install

# Configure environment variables
cp .env.example .env
# Edit .env with your configuration

# Start development server
npm run dev

# Start production server
npm start
```

## 📁 Project Structure

```
backend/
├── config/              # Configuration files
│   └── db.js           # MongoDB connection
├── controllers/         # Request handlers
│   ├── authController.js
│   ├── campaignController.js
│   ├── donationController.js
│   ├── volunteerController.js
│   ├── ngoController.js
│   └── adminController.js
├── models/             # MongoDB schemas
│   ├── User.js
│   ├── Campaign.js
│   ├── Donation.js
│   ├── NGO.js
│   ├── VolunteerProgress.js
│   └── Pickup.js
├── routes/             # API routes
│   ├── authRoutes.js
│   ├── campaignRoutes.js
│   ├── donationRoutes.js
│   ├── volunteerRoutes.js
│   ├── ngoRoutes.js
│   └── adminRoutes.js
├── middleware/         # Custom middleware
│   ├── auth.js        # JWT authentication
│   └── upload.js      # File upload handling
├── services/          # Business logic
├── utils/             # Helper functions
├── uploads/           # File storage
├── .env.example       # Environment variables template
├── server.js          # Express server setup
└── package.json       # Dependencies
```

## 🔌 API Endpoints

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - User login
- `GET /api/auth/me` - Get current user profile
- `PUT /api/auth/update` - Update user profile

### Campaigns
- `GET /api/campaigns` - Get all campaigns
- `GET /api/campaigns/:id` - Get campaign by ID
- `GET /api/campaigns/nearby` - Get nearby campaigns (location-based)
- `POST /api/campaigns` - Create campaign (Admin only)
- `PUT /api/campaigns/:id` - Update campaign (Admin only)
- `DELETE /api/campaigns/:id` - Delete campaign (Admin only)

### Donations
- `POST /api/donations` - Create donation
- `POST /api/donations/verify` - Verify Razorpay payment
- `GET /api/donations/user/:userId` - Get user's donations
- `GET /api/donations/campaign/:campaignId` - Get campaign donations
- `GET /api/donations/:id/receipt` - Download donation receipt (PDF)

### Volunteers
- `POST /api/volunteer/register` - Register as volunteer
- `GET /api/volunteer/progress/:userId` - Get volunteer progress
- `POST /api/volunteer/log-hours` - Log volunteer hours
- `GET /api/volunteer/badges/:userId` - Get volunteer badges

### NGOs
- `GET /api/ngo` - Get all NGOs
- `GET /api/ngo/:id` - Get NGO by ID
- `POST /api/ngo` - Create NGO (Admin only)
- `PUT /api/ngo/:id` - Update NGO (Admin only)

### Admin
- `GET /api/admin/stats` - Get platform statistics
- `GET /api/admin/users` - Get all users
- `GET /api/admin/donations` - Get all donations
- `GET /api/admin/campaigns` - Get all campaigns with stats

## 🔐 Authentication

The API uses JWT (JSON Web Tokens) for authentication. Include the token in the Authorization header:

```
Authorization: Bearer <your_jwt_token>
```

## 💳 Payment Integration

Razorpay is integrated for payment processing:

1. Create order on backend
2. Frontend initiates Razorpay checkout
3. Verify payment signature on backend
4. Generate receipt

## 📧 Email Notifications

Nodemailer is configured for sending:
- Welcome emails
- Donation receipts
- Campaign updates
- Volunteer badges

## 🗄️ Database Models

### User
- Basic info (name, email, phone)
- Authentication (password hash)
- Role (donor, volunteer, admin)
- Location

### Campaign
- Title, description, images
- Target amount, raised amount
- Location (coordinates)
- Status (active, completed, cancelled)
- NGO reference

### Donation
- Amount, payment details
- User and campaign references
- Receipt generation
- Tax exemption info

### VolunteerProgress
- Hours logged
- Badges earned
- Activities completed

## 🛠️ Development

```bash
# Run in development mode with auto-reload
npm run dev

# Run tests
npm test

# Seed database with sample data
npm run seed
```

## 🚀 Deployment

### Environment Variables
Ensure all required environment variables are set in production.

### MongoDB
Use MongoDB Atlas or your preferred MongoDB hosting service.

### File Storage
Consider using cloud storage (AWS S3, Google Cloud Storage) for production file uploads.

### Process Manager
Use PM2 or similar for production:

```bash
npm install -g pm2
pm2 start server.js --name ngo-backend
```

## 📝 License

MIT License - see LICENSE file for details
