# Deployment Guide

This guide covers deploying the NGO Donation Platform to production.

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Backend Deployment](#backend-deployment)
3. [Frontend Deployment](#frontend-deployment)
4. [Database Setup](#database-setup)
5. [Environment Configuration](#environment-configuration)
6. [CI/CD Setup](#cicd-setup)

---

## Prerequisites

- Domain name
- SSL certificate (Let's Encrypt recommended)
- Cloud hosting account (AWS, DigitalOcean, Heroku, etc.)
- MongoDB Atlas account (or self-hosted MongoDB)
- Razorpay production keys
- Google Maps API key
- Firebase account (for push notifications)

---

## Backend Deployment

### Option 1: Heroku

#### 1. Install Heroku CLI
```bash
npm install -g heroku
heroku login
```

#### 2. Create Heroku App
```bash
cd backend
heroku create ngo-donation-api
```

#### 3. Set Environment Variables
```bash
heroku config:set NODE_ENV=production
heroku config:set MONGODB_URI=your_mongodb_atlas_uri
heroku config:set JWT_SECRET=your_jwt_secret
heroku config:set RAZORPAY_KEY_ID=your_razorpay_key
heroku config:set RAZORPAY_KEY_SECRET=your_razorpay_secret
# ... set all other environment variables
```

#### 4. Deploy
```bash
git push heroku main
```

#### 5. Scale Dynos
```bash
heroku ps:scale web=1
```

---

### Option 2: DigitalOcean / AWS / VPS

#### 1. Server Setup

```bash
# SSH into your server
ssh root@your_server_ip

# Update system
apt update && apt upgrade -y

# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt install -y nodejs

# Install PM2 (Process Manager)
npm install -g pm2

# Install Nginx
apt install -y nginx

# Install Certbot (for SSL)
apt install -y certbot python3-certbot-nginx
```

#### 2. Deploy Application

```bash
# Clone repository
cd /var/www
git clone https://github.com/yourusername/ngo-donation-platform.git
cd ngo-donation-platform/backend

# Install dependencies
npm install --production

# Create .env file
nano .env
# Add all production environment variables

# Start with PM2
pm2 start server.js --name ngo-backend
pm2 save
pm2 startup
```

#### 3. Configure Nginx

```bash
nano /etc/nginx/sites-available/ngo-api
```

Add configuration:
```nginx
server {
    listen 80;
    server_name api.yourdomain.com;

    location / {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

Enable site:
```bash
ln -s /etc/nginx/sites-available/ngo-api /etc/nginx/sites-enabled/
nginx -t
systemctl restart nginx
```

#### 4. Setup SSL

```bash
certbot --nginx -d api.yourdomain.com
```

#### 5. Setup Firewall

```bash
ufw allow 'Nginx Full'
ufw allow OpenSSH
ufw enable
```

---

### Option 3: Docker Deployment

#### 1. Create Dockerfile (backend)

```dockerfile
# backend/Dockerfile
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install --production

COPY . .

EXPOSE 5000

CMD ["node", "server.js"]
```

#### 2. Create docker-compose.yml (root)

```yaml
version: '3.8'

services:
  backend:
    build: ./backend
    ports:
      - "5000:5000"
    environment:
      - NODE_ENV=production
      - MONGODB_URI=${MONGODB_URI}
      - JWT_SECRET=${JWT_SECRET}
    depends_on:
      - mongodb
    restart: unless-stopped

  mongodb:
    image: mongo:5
    ports:
      - "27017:27017"
    volumes:
      - mongodb_data:/data/db
    restart: unless-stopped

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/nginx/ssl
    depends_on:
      - backend
    restart: unless-stopped

volumes:
  mongodb_data:
```

#### 3. Deploy

```bash
docker-compose up -d
```

---

## Frontend Deployment

### Android (Google Play Store)

#### 1. Prepare Release Build

```bash
cd frontend

# Update version in pubspec.yaml
# version: 1.0.0+1

# Create keystore (first time only)
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

#### 2. Configure Signing

Create `android/key.properties`:
```properties
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=upload
storeFile=/path/to/upload-keystore.jks
```

Update `android/app/build.gradle`:
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    ...
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

#### 3. Build Release APK/AAB

```bash
# Build App Bundle (recommended for Play Store)
flutter build appbundle --release

# Or build APK
flutter build apk --release --split-per-abi
```

#### 4. Upload to Play Store

1. Go to [Google Play Console](https://play.google.com/console)
2. Create new application
3. Upload AAB file
4. Fill in store listing details
5. Submit for review

---

### iOS (App Store)

#### 1. Configure Xcode

```bash
cd frontend
flutter build ios --release
open ios/Runner.xcworkspace
```

In Xcode:
- Set Team and Bundle Identifier
- Configure signing certificates
- Update version and build number

#### 2. Archive and Upload

1. Product → Archive
2. Distribute App → App Store Connect
3. Upload to App Store

#### 3. App Store Connect

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Create new app
3. Fill in app information
4. Submit for review

---

### Web Deployment

#### Option 1: Firebase Hosting

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Initialize
cd frontend
firebase init hosting

# Build
flutter build web --release

# Deploy
firebase deploy --only hosting
```

#### Option 2: Netlify

```bash
# Build
flutter build web --release

# Deploy via Netlify CLI
npm install -g netlify-cli
netlify deploy --prod --dir=build/web
```

#### Option 3: GitHub Pages

```bash
# Build
flutter build web --release --base-href "/ngo-donation-app/"

# Deploy
cd build/web
git init
git add .
git commit -m "Deploy"
git remote add origin https://github.com/yourusername/ngo-donation-app.git
git push -f origin main:gh-pages
```

---

## Database Setup

### MongoDB Atlas (Recommended)

#### 1. Create Cluster

1. Go to [MongoDB Atlas](https://www.mongodb.com/cloud/atlas)
2. Create account and cluster
3. Choose region close to your server
4. Select M0 (free tier) or appropriate tier

#### 2. Configure Network Access

1. Add IP addresses (or 0.0.0.0/0 for all - not recommended for production)
2. Create database user

#### 3. Get Connection String

```
mongodb+srv://username:password@cluster.mongodb.net/ngo_donation?retryWrites=true&w=majority
```

#### 4. Backup Strategy

- Enable automated backups in Atlas
- Schedule regular exports
- Test restore procedures

---

## Environment Configuration

### Production Environment Variables

Create `.env` file with production values:

```bash
# Backend (.env)
NODE_ENV=production
PORT=5000
MONGODB_URI=mongodb+srv://...
JWT_SECRET=strong_random_secret_key
JWT_EXPIRE=30d

RAZORPAY_KEY_ID=rzp_live_xxxxx
RAZORPAY_KEY_SECRET=live_secret_key

EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USER=your_production_email@gmail.com
EMAIL_PASS=app_specific_password

FRONTEND_URL=https://yourdomain.com
ALLOWED_ORIGINS=https://yourdomain.com,https://www.yourdomain.com

# Add all other production variables
```

### Frontend Configuration

Update `lib/config/api_config.dart`:

```dart
class ApiConfig {
  static const String baseUrl = 'https://api.yourdomain.com/api';
  static const String razorpayKey = 'rzp_live_xxxxx';
  static const String googleMapsApiKey = 'your_production_api_key';
}
```

---

## CI/CD Setup

### GitHub Actions

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy

on:
  push:
    branches: [ main ]

jobs:
  deploy-backend:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Deploy to Heroku
        uses: akhileshns/heroku-deploy@v3.12.12
        with:
          heroku_api_key: ${{secrets.HEROKU_API_KEY}}
          heroku_app_name: "ngo-donation-api"
          heroku_email: "your_email@example.com"
          appdir: "backend"

  deploy-frontend-web:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      
      - name: Build Web
        run: |
          cd frontend
          flutter pub get
          flutter build web --release
      
      - name: Deploy to Firebase
        uses: FirebaseExtended/action-hosting-deploy@v0
        with:
          repoToken: '${{ secrets.GITHUB_TOKEN }}'
          firebaseServiceAccount: '${{ secrets.FIREBASE_SERVICE_ACCOUNT }}'
          channelId: live
          projectId: your-firebase-project
```

---

## Post-Deployment Checklist

- [ ] Verify all environment variables are set
- [ ] Test all API endpoints
- [ ] Test payment flow with real transactions
- [ ] Verify email notifications work
- [ ] Test file uploads
- [ ] Check SSL certificate
- [ ] Setup monitoring (e.g., New Relic, Datadog)
- [ ] Setup error tracking (e.g., Sentry)
- [ ] Configure backup strategy
- [ ] Setup analytics (e.g., Google Analytics)
- [ ] Test mobile apps on real devices
- [ ] Verify push notifications
- [ ] Load testing
- [ ] Security audit
- [ ] Update documentation with production URLs

---

## Monitoring & Maintenance

### Application Monitoring

```bash
# PM2 monitoring
pm2 monit

# View logs
pm2 logs ngo-backend

# Restart application
pm2 restart ngo-backend
```

### Database Monitoring

- Monitor MongoDB Atlas dashboard
- Set up alerts for high CPU/memory usage
- Regular backup verification

### Error Tracking

Use Sentry or similar:

```javascript
// backend/server.js
const Sentry = require("@sentry/node");

Sentry.init({
  dsn: process.env.SENTRY_DSN,
  environment: process.env.NODE_ENV,
});
```

---

## Rollback Procedure

### Backend Rollback

```bash
# Using PM2
pm2 stop ngo-backend
cd /var/www/ngo-donation-platform/backend
git checkout previous_working_commit
npm install
pm2 restart ngo-backend

# Using Heroku
heroku releases
heroku rollback v123
```

### Frontend Rollback

```bash
# Rebuild and redeploy previous version
git checkout previous_version
flutter build appbundle --release
# Upload to respective stores
```

---

## Support & Troubleshooting

- Check application logs
- Monitor error tracking dashboard
- Review server metrics
- Check database connection
- Verify environment variables
- Test API endpoints manually

---

**Last Updated:** February 2024
