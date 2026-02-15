# NGO Donation Platform

A comprehensive NGO donation platform with location-based campaigns, volunteer management, and integrated payment processing.

## 📁 Project Structure

```
NGO/
├── backend/              # Node.js/Express API Server
│   ├── config/          # Database and service configurations
│   ├── controllers/     # Request handlers
│   ├── models/          # MongoDB schemas
│   ├── routes/          # API endpoints
│   ├── middleware/      # Authentication & validation
│   ├── services/        # Business logic
│   ├── utils/           # Helper functions
│   └── uploads/         # File storage
│
├── frontend/            # Flutter Mobile Application
│   ├── lib/
│   │   ├── config/      # App configuration
│   │   ├── models/      # Data models
│   │   ├── screens/     # UI screens
│   │   ├── services/    # API & local services
│   │   ├── widgets/     # Reusable components
│   │   ├── theme/       # App theming
│   │   └── utils/       # Utilities
│   ├── assets/          # Images, icons, fonts
│   ├── android/         # Android platform files
│   ├── ios/             # iOS platform files
│   └── web/             # Web platform files
│
├── docs/                # Documentation
└── scripts/             # Development & deployment scripts
```

## 🚀 Quick Start

### Prerequisites

- **Backend:**
  - Node.js (v16 or higher)
  - MongoDB (v5 or higher)
  - npm or yarn

- **Frontend:**
  - Flutter SDK (v3.0 or higher)
  - Android Studio / Xcode (for mobile development)
  - VS Code with Flutter extension (recommended)

### Backend Setup

```bash
# Navigate to backend directory
cd backend

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

The backend server will run on `http://localhost:5000`

### Frontend Setup

```bash
# Navigate to frontend directory
cd frontend

# Install dependencies
flutter pub get

# Run on connected device/emulator
flutter run

# Build for production
flutter build apk        # Android
flutter build ios        # iOS
flutter build web        # Web
```

## 🔧 Configuration

### Backend Environment Variables

Create a `.env` file in the `backend/` directory:

```env
PORT=5000
MONGODB_URI=mongodb://localhost:27017/ngo_donation
JWT_SECRET=your_jwt_secret_key
JWT_EXPIRE=30d

# Razorpay Configuration
RAZORPAY_KEY_ID=your_razorpay_key_id
RAZORPAY_KEY_SECRET=your_razorpay_key_secret

# Email Configuration
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USER=your_email@gmail.com
EMAIL_PASS=your_email_password

# File Upload
MAX_FILE_SIZE=5242880
UPLOAD_PATH=./uploads
```

### Frontend Configuration

Update `frontend/lib/config/api_config.dart`:

```dart
class ApiConfig {
  static const String baseUrl = 'http://localhost:5000/api';
  static const String razorpayKey = 'your_razorpay_key_id';
}
```

## 📚 API Documentation

### Authentication Endpoints
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - User login
- `GET /api/auth/me` - Get current user

### Campaign Endpoints
- `GET /api/campaigns` - Get all campaigns
- `GET /api/campaigns/:id` - Get campaign by ID
- `POST /api/campaigns` - Create campaign (Admin)
- `PUT /api/campaigns/:id` - Update campaign (Admin)
- `DELETE /api/campaigns/:id` - Delete campaign (Admin)

### Donation Endpoints
- `POST /api/donations` - Create donation
- `GET /api/donations/user/:userId` - Get user donations
- `POST /api/donations/verify` - Verify payment

### Volunteer Endpoints
- `POST /api/volunteer/register` - Register as volunteer
- `GET /api/volunteer/progress/:userId` - Get volunteer progress
- `POST /api/volunteer/log-hours` - Log volunteer hours

### Admin Endpoints
- `GET /api/admin/stats` - Get platform statistics
- `GET /api/admin/users` - Get all users
- `GET /api/admin/donations` - Get all donations

## 🎨 Features

### Backend Features
- ✅ User authentication with JWT
- ✅ Campaign management
- ✅ Donation processing with Razorpay
- ✅ Volunteer tracking with badges
- ✅ PDF receipt generation
- ✅ Email notifications
- ✅ Admin dashboard analytics
- ✅ File upload handling
- ✅ Location-based campaigns

### Frontend Features
- ✅ Beautiful, modern UI with animations
- ✅ Location-based campaign discovery
- ✅ Google Maps integration
- ✅ Secure payment processing
- ✅ Instant PDF receipts
- ✅ Volunteer badge system
- ✅ Real-time notifications
- ✅ Offline support
- ✅ Multi-platform (Android, iOS, Web)

## 🛠️ Technology Stack

### Backend
- **Runtime:** Node.js
- **Framework:** Express.js
- **Database:** MongoDB with Mongoose
- **Authentication:** JWT (jsonwebtoken)
- **Payment:** Razorpay
- **File Upload:** Multer
- **PDF Generation:** PDFKit
- **Email:** Nodemailer

### Frontend
- **Framework:** Flutter
- **State Management:** Provider
- **Networking:** Dio, HTTP
- **Maps:** Google Maps Flutter
- **Location:** Geolocator
- **Storage:** Shared Preferences, Secure Storage
- **Payment:** Razorpay Flutter
- **PDF:** PDF & Printing packages
- **Notifications:** Firebase Cloud Messaging

## 📱 Screenshots

*(Add screenshots of your app here)*

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👥 Authors

- **Your Name** - *Initial work*

## 🙏 Acknowledgments

- Thanks to all NGOs making a difference
- Flutter and Node.js communities
- All contributors and supporters

## 📞 Support

For support, email varmakhushi151@gmail.com or create an issue in the repository.

---

**Made with ❤️ for a better world**
