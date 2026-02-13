# API Documentation

Complete API reference for the NGO Donation Platform backend.

## Base URL

```
Development: http://localhost:5000/api
Production: https://your-domain.com/api
```

## Authentication

Most endpoints require authentication using JWT tokens.

### Headers

```
Authorization: Bearer <your_jwt_token>
Content-Type: application/json
```

---

## Authentication Endpoints

### Register User

Create a new user account.

**Endpoint:** `POST /api/auth/register`

**Request Body:**
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "securePassword123",
  "phone": "+919876543210",
  "role": "donor"
}
```

**Response:** `201 Created`
```json
{
  "success": true,
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "_id": "60d5ec49f1b2c72b8c8e4f1a",
    "name": "John Doe",
    "email": "john@example.com",
    "role": "donor"
  }
}
```

---

### Login

Authenticate user and receive JWT token.

**Endpoint:** `POST /api/auth/login`

**Request Body:**
```json
{
  "email": "john@example.com",
  "password": "securePassword123"
}
```

**Response:** `200 OK`
```json
{
  "success": true,
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "_id": "60d5ec49f1b2c72b8c8e4f1a",
    "name": "John Doe",
    "email": "john@example.com",
    "role": "donor"
  }
}
```

---

### Get Current User

Get authenticated user's profile.

**Endpoint:** `GET /api/auth/me`

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`
```json
{
  "success": true,
  "data": {
    "_id": "60d5ec49f1b2c72b8c8e4f1a",
    "name": "John Doe",
    "email": "john@example.com",
    "phone": "+919876543210",
    "role": "donor",
    "createdAt": "2024-01-15T10:30:00.000Z"
  }
}
```

---

## Campaign Endpoints

### Get All Campaigns

Retrieve all active campaigns.

**Endpoint:** `GET /api/campaigns`

**Query Parameters:**
- `page` (optional): Page number (default: 1)
- `limit` (optional): Items per page (default: 10)
- `status` (optional): Filter by status (active, completed, cancelled)
- `category` (optional): Filter by category

**Response:** `200 OK`
```json
{
  "success": true,
  "count": 25,
  "pagination": {
    "page": 1,
    "limit": 10,
    "total": 25
  },
  "data": [
    {
      "_id": "60d5ec49f1b2c72b8c8e4f1b",
      "title": "Education for Underprivileged Children",
      "description": "Help provide quality education...",
      "targetAmount": 100000,
      "raisedAmount": 45000,
      "status": "active",
      "category": "education",
      "images": ["https://example.com/image1.jpg"],
      "location": {
        "type": "Point",
        "coordinates": [77.5946, 12.9716],
        "address": "Bangalore, Karnataka"
      },
      "ngo": {
        "_id": "60d5ec49f1b2c72b8c8e4f1c",
        "name": "Education For All NGO"
      },
      "createdAt": "2024-01-15T10:30:00.000Z",
      "endDate": "2024-06-30T23:59:59.000Z"
    }
  ]
}
```

---

### Get Campaign by ID

Get detailed information about a specific campaign.

**Endpoint:** `GET /api/campaigns/:id`

**Response:** `200 OK`
```json
{
  "success": true,
  "data": {
    "_id": "60d5ec49f1b2c72b8c8e4f1b",
    "title": "Education for Underprivileged Children",
    "description": "Detailed description...",
    "targetAmount": 100000,
    "raisedAmount": 45000,
    "donorCount": 150,
    "status": "active",
    "category": "education",
    "images": ["https://example.com/image1.jpg"],
    "location": {
      "type": "Point",
      "coordinates": [77.5946, 12.9716],
      "address": "Bangalore, Karnataka"
    },
    "ngo": {
      "_id": "60d5ec49f1b2c72b8c8e4f1c",
      "name": "Education For All NGO",
      "description": "NGO description...",
      "contact": "+919876543210"
    },
    "recentDonations": [
      {
        "user": "Anonymous",
        "amount": 1000,
        "createdAt": "2024-01-20T15:30:00.000Z"
      }
    ]
  }
}
```

---

### Get Nearby Campaigns

Get campaigns near a specific location.

**Endpoint:** `GET /api/campaigns/nearby`

**Query Parameters:**
- `latitude` (required): Latitude coordinate
- `longitude` (required): Longitude coordinate
- `maxDistance` (optional): Maximum distance in meters (default: 10000)

**Example:** `GET /api/campaigns/nearby?latitude=12.9716&longitude=77.5946&maxDistance=5000`

**Response:** `200 OK`
```json
{
  "success": true,
  "data": [
    {
      "_id": "60d5ec49f1b2c72b8c8e4f1b",
      "title": "Local Food Drive",
      "distance": 1250,
      "location": {
        "address": "Indiranagar, Bangalore"
      }
    }
  ]
}
```

---

### Create Campaign (Admin Only)

Create a new campaign.

**Endpoint:** `POST /api/campaigns`

**Headers:** `Authorization: Bearer <admin_token>`

**Request Body:**
```json
{
  "title": "Clean Water Initiative",
  "description": "Provide clean drinking water...",
  "targetAmount": 200000,
  "category": "health",
  "ngo": "60d5ec49f1b2c72b8c8e4f1c",
  "location": {
    "coordinates": [77.5946, 12.9716],
    "address": "Bangalore, Karnataka"
  },
  "endDate": "2024-12-31T23:59:59.000Z",
  "images": ["image1.jpg", "image2.jpg"]
}
```

**Response:** `201 Created`
```json
{
  "success": true,
  "data": {
    "_id": "60d5ec49f1b2c72b8c8e4f1d",
    "title": "Clean Water Initiative",
    "status": "active",
    "raisedAmount": 0
  }
}
```

---

## Donation Endpoints

### Create Donation

Initiate a new donation.

**Endpoint:** `POST /api/donations`

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "campaign": "60d5ec49f1b2c72b8c8e4f1b",
  "amount": 5000,
  "isAnonymous": false,
  "message": "Happy to contribute!"
}
```

**Response:** `201 Created`
```json
{
  "success": true,
  "data": {
    "orderId": "order_JZ8kP9xQy5z6Kl",
    "amount": 5000,
    "currency": "INR",
    "razorpayKeyId": "rzp_test_xxxxx"
  }
}
```

---

### Verify Payment

Verify Razorpay payment signature.

**Endpoint:** `POST /api/donations/verify`

**Request Body:**
```json
{
  "orderId": "order_JZ8kP9xQy5z6Kl",
  "paymentId": "pay_JZ8kQB3xQy5z6Km",
  "signature": "9c0e8a7f8d6b5c4a3b2c1d0e9f8a7b6c5d4e3f2a1b0c9d8e7f6a5b4c3d2e1f0"
}
```

**Response:** `200 OK`
```json
{
  "success": true,
  "message": "Payment verified successfully",
  "data": {
    "_id": "60d5ec49f1b2c72b8c8e4f1e",
    "receiptUrl": "https://example.com/receipts/receipt_123.pdf",
    "receiptNumber": "RCP-2024-001234"
  }
}
```

---

### Get User Donations

Get all donations made by a user.

**Endpoint:** `GET /api/donations/user/:userId`

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`
```json
{
  "success": true,
  "data": [
    {
      "_id": "60d5ec49f1b2c72b8c8e4f1e",
      "campaign": {
        "_id": "60d5ec49f1b2c72b8c8e4f1b",
        "title": "Education for All"
      },
      "amount": 5000,
      "status": "completed",
      "receiptNumber": "RCP-2024-001234",
      "createdAt": "2024-01-20T15:30:00.000Z"
    }
  ]
}
```

---

### Download Receipt

Download PDF receipt for a donation.

**Endpoint:** `GET /api/donations/:id/receipt`

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK` (PDF file)

---

## Volunteer Endpoints

### Register as Volunteer

Register user as a volunteer.

**Endpoint:** `POST /api/volunteer/register`

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "skills": ["teaching", "event_management"],
  "availability": ["weekends", "evenings"],
  "interests": ["education", "environment"]
}
```

**Response:** `201 Created`
```json
{
  "success": true,
  "message": "Registered as volunteer successfully"
}
```

---

### Get Volunteer Progress

Get volunteer's progress and badges.

**Endpoint:** `GET /api/volunteer/progress/:userId`

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`
```json
{
  "success": true,
  "data": {
    "totalHours": 45,
    "badges": [
      {
        "name": "First Step",
        "description": "Completed first volunteer activity",
        "icon": "🌟",
        "earnedAt": "2024-01-10T10:00:00.000Z"
      },
      {
        "name": "Time Keeper",
        "description": "Logged 25+ hours",
        "icon": "⏰",
        "earnedAt": "2024-02-01T14:30:00.000Z"
      }
    ],
    "activities": [
      {
        "title": "Teaching Session",
        "hours": 3,
        "date": "2024-02-10T10:00:00.000Z"
      }
    ]
  }
}
```

---

### Log Volunteer Hours

Log hours for a volunteer activity.

**Endpoint:** `POST /api/volunteer/log-hours`

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "activity": "Teaching Math to 5th graders",
  "hours": 3,
  "date": "2024-02-10",
  "campaign": "60d5ec49f1b2c72b8c8e4f1b"
}
```

**Response:** `201 Created`
```json
{
  "success": true,
  "message": "Hours logged successfully",
  "data": {
    "totalHours": 48,
    "newBadges": []
  }
}
```

---

## Admin Endpoints

### Get Platform Statistics

Get overall platform statistics (Admin only).

**Endpoint:** `GET /api/admin/stats`

**Headers:** `Authorization: Bearer <admin_token>`

**Response:** `200 OK`
```json
{
  "success": true,
  "data": {
    "totalDonations": 2500000,
    "totalDonors": 5000,
    "totalCampaigns": 150,
    "activeCampaigns": 45,
    "totalVolunteers": 1200,
    "volunteerHours": 15000,
    "recentActivity": [
      {
        "type": "donation",
        "amount": 5000,
        "campaign": "Education for All",
        "timestamp": "2024-02-13T10:30:00.000Z"
      }
    ]
  }
}
```

---

## Error Responses

All endpoints may return the following error responses:

### 400 Bad Request
```json
{
  "success": false,
  "message": "Validation error",
  "errors": [
    {
      "field": "email",
      "message": "Invalid email format"
    }
  ]
}
```

### 401 Unauthorized
```json
{
  "success": false,
  "message": "Not authorized to access this route"
}
```

### 404 Not Found
```json
{
  "success": false,
  "message": "Resource not found"
}
```

### 500 Internal Server Error
```json
{
  "success": false,
  "message": "Server error"
}
```

---

## Rate Limiting

API requests are rate-limited to prevent abuse:
- **Limit:** 100 requests per 15 minutes per IP
- **Header:** `X-RateLimit-Remaining` shows remaining requests

---

## Pagination

List endpoints support pagination:

**Query Parameters:**
- `page`: Page number (default: 1)
- `limit`: Items per page (default: 10, max: 100)

**Response includes:**
```json
{
  "pagination": {
    "page": 1,
    "limit": 10,
    "total": 150,
    "pages": 15
  }
}
```

---

## Postman Collection

Import the Postman collection for easy API testing:
[Download Collection](./postman_collection.json)

---

**Last Updated:** February 2024
