# DreamVentz - Event Management Platform

A beautiful Flutter application with secure authentication powered by Supabase.

## ✨ Features

- 🔐 **Secure Authentication** - Bcrypt password hashing, email verification
- 📧 **Password Reset** - Email-based password recovery
- 💾 **Offline Support** - Cached user data for offline access
- 🎨 **Beautiful UI** - Modern dark theme with amber accents
- 📱 **Responsive Design** - Works on all screen sizes
- 🔄 **Session Management** - Auto-refresh tokens, persistent sessions
- ✅ **Form Validation** - Real-time validation with helpful error messages

## 🚀 Quick Start

### Prerequisites

- Flutter SDK (3.10.4 or higher)
- Dart SDK
- Supabase account ([Sign up free](https://supabase.com))

### Installation

1. **Clone the repository** (or navigate to project directory)
   ```bash
   cd c:\Projects\Flutter\internship\Dreamventz\dreamventz
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Setup Supabase**
   - Create a project at [https://supabase.com](https://supabase.com)
   - Copy your project URL and anon key
   - Update `.env` file with your credentials:
     ```env
     SUPABASE_URL=your_project_url
     SUPABASE_ANON_KEY=your_anon_key
     ```

4. **Create database tables**
   - Go to Supabase SQL Editor
   - Run the script from `database_schema.md` artifact
   - Verify tables in Table Editor

5. **Add your logo**
   - Place your logo at `assets/icons/DV.png`

6. **Run the app**
   ```bash
   flutter run
   ```

## 📖 Documentation

- **[Setup Guide](file:///C:/Users/Harshal/.gemini/antigravity/brain/c99d613f-8754-4c54-987b-957b01373a5e/setup_guide.md)** - Complete step-by-step setup instructions
- **[Database Schema](file:///C:/Users/Harshal/.gemini/antigravity/brain/c99d613f-8754-4c54-987b-957b01373a5e/database_schema.md)** - Supabase database structure and SQL scripts
- **[Implementation Plan](file:///C:/Users/Harshal/.gemini/antigravity/brain/c99d613f-8754-4c54-987b-957b01373a5e/implementation_plan.md)** - Technical architecture overview
- **[Walkthrough](file:///C:/Users/Harshal/.gemini/antigravity/brain/c99d613f-8754-4c54-987b-957b01373a5e/walkthrough.md)** - What was implemented and testing results

## 🏗️ Project Structure

```
lib/
├── config/              # App configuration
│   └── supabase_config.dart
├── models/              # Data models
│   └── user_model.dart
├── screens/             # UI screens
│   ├── auth/
│   │   ├── login_screen.dart
│   │   ├── signup_screen.dart
│   │   └── forgot_password_screen.dart
│   └── home/
│       └── home_screen.dart
├── services/            # Business logic
│   ├── auth_service.dart
│   └── user_service.dart
├── utils/               # Utilities
│   ├── constants.dart
│   └── validators.dart
└── main.dart            # Entry point
```

## 🔒 Security

- ✅ Passwords hashed with bcrypt (handled by Supabase)
- ✅ HTTPS encryption for all API calls
- ✅ Row Level Security (RLS) policies
- ✅ Secure session token management
- ✅ PKCE auth flow
- ✅ Environment variables not committed

## 🛠️ Tech Stack

- **Frontend**: Flutter 3.10.4
- **Backend**: Supabase (PostgreSQL, Auth, Storage)
- **State Management**: StatefulWidget
- **Local Storage**: SharedPreferences
- **Authentication**: Supabase Auth (Email/Password)

## 📚 Key Packages

- `supabase_flutter: ^2.8.0` - Supabase client
- `flutter_dotenv: ^5.1.0` - Environment variables
- `shared_preferences: ^2.3.3` - Local storage
- `url_launcher: ^6.3.1` - Deep linking

## 🧪 Testing

### Manual Testing Checklist

- [ ] **Signup Flow**
  - [ ] Create account with valid data
  - [ ] Verify user in Supabase dashboard
  - [ ] Check profile created in `profiles` table

- [ ] **Login Flow**
  - [ ] Login with created account
  - [ ] Test "Remember Me" functionality
  - [ ] Verify redirection to home screen

- [ ] **Password Reset**
  - [ ] Request password reset
  - [ ] Check email received
  - [ ] Reset password via link
  - [ ] Login with new password

- [ ] **Offline Mode**
  - [ ] Login while online
  - [ ] Turn off internet
  - [ ] Verify cached data displays
  - [ ] Check offline indicator shows

## 🐛 Troubleshooting

### Common Issues

**"Supabase credentials not found"**
- Verify `.env` file exists in project root
- Check credentials are correct
- Restart the app

**"Invalid login credentials"**
- Ensure account exists (signup first)
- Check for typos
- Password is case-sensitive

**"Logo not showing"**
- Verify `assets/icons/DV.png` exists
- Run `flutter pub get`
- Hot restart (not just reload)

See [Setup Guide](file:///C:/Users/Harshal/.gemini/antigravity/brain/c99d613f-8754-4c54-987b-957b01373a5e/setup_guide.md) for more troubleshooting.

## 📱 Future Features

- [ ] Event creation and management
- [ ] Event bookings
- [ ] User profile editing
- [ ] Push notifications
- [ ] Social login (Google, Facebook, Apple)
- [ ] Event search and filtering
- [ ] QR code tickets
- [ ] In-app messaging

## 👨‍💻 Development

### Running in Debug Mode
```bash
flutter run
```

### Building for Production
```bash
flutter build apk  # Android
flutter build ios  # iOS
```

### Code Generation
```bash
flutter pub run build_runner build
```

## 📄 License

This project is proprietary and confidential.

## 🤝 Contributing

This is a private project. For any issues or suggestions, please contact the development team.

## 📞 Support

For setup help or technical support:
1. Check the [Setup Guide](file:///C:/Users/Harshal/.gemini/antigravity/brain/c99d613f-8754-4c54-987b-957b01373a5e/setup_guide.md)
2. Review the [Walkthrough](file:///C:/Users/Harshal/.gemini/antigravity/brain/c99d613f-8754-4c54-987b-957b01373a5e/walkthrough.md)
3. Contact the project maintainer

---

**Built with ❤️ using Flutter and Supabase**
