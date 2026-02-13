# NGO Donation App - Flutter Frontend

A beautiful, feature-rich Flutter mobile application for the NGO Donation Platform with location-based campaigns, volunteer tracking, and integrated payments.

## 🚀 Quick Start

### Prerequisites

- Flutter SDK (v3.0 or higher)
- Dart SDK (v3.0 or higher)
- Android Studio / Xcode (for mobile development)
- VS Code with Flutter extension (recommended)

### Installation

```bash
# Install dependencies
flutter pub get

# Run on connected device/emulator
flutter run

# Run in release mode
flutter run --release
```

## 📁 Project Structure

```
frontend/
├── lib/
│   ├── config/              # App configuration
│   │   └── api_config.dart  # API endpoints
│   ├── models/              # Data models
│   │   ├── user.dart
│   │   ├── campaign.dart
│   │   ├── donation.dart
│   │   └── volunteer.dart
│   ├── screens/             # UI screens
│   │   ├── auth/           # Login, register
│   │   ├── home/           # Home screen
│   │   ├── campaigns/      # Campaign list & details
│   │   ├── donations/      # Donation flow
│   │   ├── volunteer/      # Volunteer screens
│   │   ├── profile/        # User profile
│   │   └── admin/          # Admin dashboard
│   ├── services/            # API & local services
│   │   ├── api_service.dart
│   │   ├── auth_service.dart
│   │   ├── location_service.dart
│   │   ├── payment_service.dart
│   │   └── storage_service.dart
│   ├── widgets/             # Reusable components
│   │   ├── campaign_card.dart
│   │   ├── donation_card.dart
│   │   ├── custom_button.dart
│   │   └── loading_widget.dart
│   ├── theme/               # App theming
│   │   ├── app_theme.dart
│   │   ├── colors.dart
│   │   └── text_styles.dart
│   ├── utils/               # Utilities
│   │   ├── constants.dart
│   │   ├── validators.dart
│   │   └── helpers.dart
│   └── main.dart            # App entry point
├── assets/                  # Static assets
│   ├── images/
│   └── icons/
├── android/                 # Android platform files
├── ios/                     # iOS platform files
├── web/                     # Web platform files
└── pubspec.yaml            # Dependencies
```

## ✨ Features

### Core Features
- 🔐 **Authentication** - Secure login/register with JWT
- 📍 **Location-Based Discovery** - Find campaigns near you
- 🗺️ **Google Maps Integration** - View campaigns on map
- 💳 **Razorpay Payment** - Secure payment processing
- 📄 **Instant Receipts** - PDF receipt generation
- 🎖️ **Volunteer Badges** - Gamified volunteer tracking
- 🔔 **Push Notifications** - Real-time updates
- 📱 **Multi-Platform** - Android, iOS, and Web support

### UI/UX Features
- 🎨 Beautiful, modern design with animations
- 🌙 Dark mode support (optional)
- 📱 Responsive layouts
- ⚡ Smooth transitions and micro-interactions
- 🖼️ Cached images for better performance
- 📊 Interactive charts and statistics

## 🔧 Configuration

### API Configuration

Update `lib/config/api_config.dart`:

```dart
class ApiConfig {
  // Backend API URL
  static const String baseUrl = 'http://your-backend-url.com/api';
  
  // For local development
  // Android Emulator: http://10.0.2.2:5000/api
  // iOS Simulator: http://localhost:5000/api
  // Physical Device: http://your-local-ip:5000/api
  
  // Razorpay Key
  static const String razorpayKey = 'your_razorpay_key_id';
  
  // Google Maps API Key
  static const String googleMapsApiKey = 'your_google_maps_api_key';
}
```

### Android Configuration

1. **Google Maps API Key** - Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_API_KEY"/>
```

2. **Permissions** - Already configured in AndroidManifest.xml:
   - Internet
   - Location (Fine & Coarse)
   - Camera (for profile pictures)

### iOS Configuration

1. **Google Maps API Key** - Add to `ios/Runner/AppDelegate.swift`
2. **Permissions** - Add to `ios/Runner/Info.plist`:
   - Location When In Use
   - Camera
   - Photo Library

## 📦 Dependencies

### UI & Design
- `google_fonts` - Beautiful typography
- `flutter_animate` - Smooth animations
- `cached_network_image` - Image caching
- `shimmer` - Loading skeletons

### State Management
- `provider` - Simple and powerful state management

### Networking
- `http` - HTTP requests
- `dio` - Advanced HTTP client

### Location & Maps
- `geolocator` - Location services
- `google_maps_flutter` - Google Maps
- `geocoding` - Address conversion

### Storage
- `shared_preferences` - Local storage
- `flutter_secure_storage` - Secure storage for tokens

### Payment
- `razorpay_flutter` - Razorpay integration

### PDF & Receipts
- `pdf` - PDF generation
- `printing` - PDF viewing and sharing

### Notifications
- `flutter_local_notifications` - Local notifications
- `firebase_messaging` - Push notifications

## 🏗️ Build & Deploy

### Android

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# App Bundle (for Play Store)
flutter build appbundle --release
```

### iOS

```bash
# Debug
flutter build ios --debug

# Release
flutter build ios --release
```

### Web

```bash
# Build for web
flutter build web --release

# Serve locally
flutter run -d chrome
```

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/widget_test.dart
```

## 🎨 Theming

The app uses a custom theme defined in `lib/theme/app_theme.dart`. Colors and text styles are centralized for easy customization.

### Primary Colors
- Primary: Blue gradient
- Secondary: Purple
- Accent: Orange
- Success: Green
- Error: Red

## 📱 Screens Overview

1. **Splash Screen** - App initialization
2. **Onboarding** - First-time user experience
3. **Auth Screens** - Login, Register, Forgot Password
4. **Home** - Dashboard with featured campaigns
5. **Campaigns** - Browse and search campaigns
6. **Campaign Details** - Full campaign information
7. **Donation Flow** - Amount selection, payment, receipt
8. **Volunteer** - Register, log hours, view badges
9. **Profile** - User settings and donation history
10. **Admin Dashboard** - Platform analytics (admin only)

## 🔐 Security

- JWT tokens stored in secure storage
- API requests authenticated with Bearer tokens
- Input validation on all forms
- Secure payment processing via Razorpay

## 🚀 Performance Optimization

- Image caching with `cached_network_image`
- Lazy loading for lists
- Optimized build methods
- Debounced search
- Pagination for large datasets

## 📝 License

MIT License - see LICENSE file for details

## 🤝 Contributing

Contributions are welcome! Please follow the Flutter style guide and ensure all tests pass.

## 📞 Support

For issues and questions, please create an issue in the repository.

---

**Made with ❤️ using Flutter**
