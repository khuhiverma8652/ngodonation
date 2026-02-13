# Development Guide

This guide will help you set up and develop the NGO Donation Platform.

## Table of Contents
1. [Initial Setup](#initial-setup)
2. [Development Workflow](#development-workflow)
3. [Code Standards](#code-standards)
4. [Testing](#testing)
5. [Deployment](#deployment)

## Initial Setup

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/ngo-donation-platform.git
cd ngo-donation-platform
```

### 2. Backend Setup

```bash
# Navigate to backend
cd backend

# Install dependencies
npm install

# Create environment file
cp .env.example .env

# Edit .env with your configuration
# Required: MONGODB_URI, JWT_SECRET, RAZORPAY keys

# Start MongoDB (if running locally)
mongod

# Start development server
npm run dev
```

The backend will run on `http://localhost:5000`

### 3. Frontend Setup

```bash
# Navigate to frontend (from root)
cd frontend

# Install dependencies
flutter pub get

# Update API configuration
# Edit lib/config/api_config.dart with your backend URL

# Run on device/emulator
flutter run
```

### 4. Database Setup

#### Option A: Local MongoDB

```bash
# Install MongoDB Community Edition
# https://www.mongodb.com/try/download/community

# Start MongoDB
mongod

# (Optional) Seed database with sample data
cd backend
npm run seed
```

#### Option B: MongoDB Atlas (Cloud)

1. Create account at https://www.mongodb.com/cloud/atlas
2. Create a cluster
3. Get connection string
4. Update `MONGODB_URI` in backend/.env

## Development Workflow

### Backend Development

```bash
cd backend

# Start with auto-reload
npm run dev

# The server will restart automatically on file changes
```

#### Adding a New API Endpoint

1. **Create/Update Model** (if needed) - `models/YourModel.js`
2. **Create Controller** - `controllers/yourController.js`
3. **Create Route** - `routes/yourRoutes.js`
4. **Register Route** - Add to `server.js`

Example:

```javascript
// models/Event.js
const mongoose = require('mongoose');

const eventSchema = new mongoose.Schema({
  title: { type: String, required: true },
  date: { type: Date, required: true },
  // ... other fields
});

module.exports = mongoose.model('Event', eventSchema);

// controllers/eventController.js
const Event = require('../models/Event');

exports.getEvents = async (req, res) => {
  try {
    const events = await Event.find();
    res.json({ success: true, data: events });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// routes/eventRoutes.js
const express = require('express');
const router = express.Router();
const { getEvents } = require('../controllers/eventController');

router.get('/', getEvents);

module.exports = router;

// server.js - Register route
const eventRoutes = require('./routes/eventRoutes');
app.use('/api/events', eventRoutes);
```

### Frontend Development

```bash
cd frontend

# Run in debug mode
flutter run

# Run with hot reload enabled (default)
# Press 'r' to hot reload
# Press 'R' to hot restart
```

#### Adding a New Screen

1. **Create Screen File** - `lib/screens/your_feature/your_screen.dart`
2. **Create Service** (if needed) - `lib/services/your_service.dart`
3. **Create Model** (if needed) - `lib/models/your_model.dart`
4. **Add Route** - Update navigation in `main.dart` or router

Example:

```dart
// lib/screens/events/events_screen.dart
import 'package:flutter/material.dart';
import '../../services/event_service.dart';

class EventsScreen extends StatefulWidget {
  @override
  _EventsScreenState createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final EventService _eventService = EventService();
  List<Event> events = [];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final data = await _eventService.getEvents();
    setState(() => events = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Events')),
      body: ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          return ListTile(title: Text(events[index].title));
        },
      ),
    );
  }
}
```

## Code Standards

### Backend (Node.js)

- Use ES6+ features
- Follow Airbnb JavaScript Style Guide
- Use async/await for asynchronous operations
- Always handle errors properly
- Use meaningful variable names
- Add comments for complex logic

```javascript
// Good
const getUserDonations = async (userId) => {
  try {
    const donations = await Donation.find({ user: userId })
      .populate('campaign')
      .sort({ createdAt: -1 });
    return donations;
  } catch (error) {
    throw new Error(`Failed to fetch donations: ${error.message}`);
  }
};

// Bad
const getD = async (u) => {
  const d = await Donation.find({ user: u });
  return d;
};
```

### Frontend (Flutter/Dart)

- Follow Effective Dart style guide
- Use meaningful widget names
- Extract reusable widgets
- Use const constructors where possible
- Implement proper error handling
- Add comments for complex UI logic

```dart
// Good
class DonationCard extends StatelessWidget {
  final Donation donation;
  final VoidCallback onTap;

  const DonationCard({
    Key? key,
    required this.donation,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(donation.campaignName),
        subtitle: Text('₹${donation.amount}'),
        onTap: onTap,
      ),
    );
  }
}

// Bad
class DC extends StatelessWidget {
  var d;
  DC(this.d);
  
  Widget build(c) {
    return Card(child: Text(d.toString()));
  }
}
```

## Testing

### Backend Testing

```bash
cd backend

# Run tests
npm test

# Run tests with coverage
npm run test:coverage
```

Example test:

```javascript
// tests/auth.test.js
const request = require('supertest');
const app = require('../server');

describe('Auth Endpoints', () => {
  it('should register a new user', async () => {
    const res = await request(app)
      .post('/api/auth/register')
      .send({
        name: 'Test User',
        email: 'test@example.com',
        password: 'password123',
      });
    
    expect(res.statusCode).toBe(201);
    expect(res.body.success).toBe(true);
  });
});
```

### Frontend Testing

```bash
cd frontend

# Run all tests
flutter test

# Run specific test
flutter test test/widget_test.dart

# Run with coverage
flutter test --coverage
```

Example test:

```dart
// test/widgets/donation_card_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:ngo_donation_app/widgets/donation_card.dart';

void main() {
  testWidgets('DonationCard displays donation info', (tester) async {
    final donation = Donation(
      campaignName: 'Test Campaign',
      amount: 1000,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: DonationCard(
          donation: donation,
          onTap: () {},
        ),
      ),
    );

    expect(find.text('Test Campaign'), findsOneWidget);
    expect(find.text('₹1000'), findsOneWidget);
  });
}
```

## Debugging

### Backend Debugging

```bash
# Enable detailed logging
DEBUG=* npm run dev

# Use Node.js debugger
node --inspect index.js
```

### Frontend Debugging

```bash
# Run with verbose logging
flutter run -v

# Use DevTools
flutter pub global activate devtools
flutter pub global run devtools
```

## Common Issues

### Backend

**Issue: MongoDB connection failed**
- Ensure MongoDB is running
- Check MONGODB_URI in .env
- Verify network connectivity

**Issue: JWT token invalid**
- Check JWT_SECRET is set
- Verify token expiration
- Ensure proper token format in headers

### Frontend

**Issue: API connection failed**
- Check backend is running
- Verify API URL in api_config.dart
- For Android emulator, use 10.0.2.2 instead of localhost
- Check CORS settings in backend

**Issue: Google Maps not showing**
- Verify API key is added
- Enable Maps SDK in Google Cloud Console
- Check permissions in AndroidManifest.xml/Info.plist

## Deployment

See [DEPLOYMENT.md](./DEPLOYMENT.md) for detailed deployment instructions.

## Additional Resources

- [Node.js Best Practices](https://github.com/goldbergyoni/nodebestpractices)
- [Flutter Documentation](https://docs.flutter.dev/)
- [MongoDB Manual](https://docs.mongodb.com/manual/)
- [Express.js Guide](https://expressjs.com/en/guide/routing.html)

## Getting Help

- Check existing issues in the repository
- Read the documentation
- Ask in team chat/Slack
- Create a new issue with detailed description
