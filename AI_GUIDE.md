# AI Guide for Dreamventz

This document serves as a guide for any AI assistant or new developer to understand the Dreamventz project structure, features, and how to make changes effectively.

## 📌 Project Overview
Dreamventz is a Flutter-based mobile application designed for event management, package booking, and vendor coordination.
It relies heavily on **Supabase** for Backend-as-a-Service (BaaS), handling Authentication, Database, and Storage.

## 🛠️ Tech Stack & Key Packages
- **Framework**: Flutter (Dart)
- **Backend**: Supabase (`supabase_flutter`)
- **Environment**: `flutter_dotenv` (Loads `.env` variables)
- **Local Storage**: `shared_preferences` (For caching data)
- **UI & Assets**: `google_fonts`, `carousel_slider`, `cached_network_image`

## 📁 Folder Structure (`lib/`)
The project follows a standard feature/layer-based structure:

* `components/`: Contains reusable UI widgets (cards, tiles, search bars, etc.). E.g., `carasol.dart`, `searchbar.dart`, various tiles.
* `config/`: Contains app configuration, specifically the correct `supabase_config.dart` which uses `dotenv` to load credentials.
* `models/`: Data classes representing entities like `user_model.dart`, `vendor_card.dart`, `venue_models.dart`.
* `screens/`: UI Views grouped by feature directories:
  * `auth/`: Login, signup, password reset.
  * `home/`: Main dashboard (`home_page.dart`).
  * `vendors/`, `venues/`, `packages/`, `services/`: Specific domain screens.
  * `profile/`, `history/`, `bookings/`: User-specific data views.
* `services/`: Backend interaction layer. Contains wrappers around Supabase client calls (e.g., `auth_service.dart`, `venue_service.dart`).
* `utils/`: Helpers like `constants.dart` (colors, strings, routes) and `validators.dart` (form validation).

## 🚀 How Changes Should Be Made

When you (the AI) are asked to modify or add features, follow these guidelines:

1. **Routing and Navigation**
   - The app uses `MaterialApp` routes defined in `lib/main.dart` for simple navigation, but also relies on `MaterialPageRoute` for passing complex objects (like venue/vendor details).
   - If adding a new fundamental screen, register the route in `main.dart` and add it to `AppConstants`.
   
2. **State Management**
   - The project currently relies heavily on `StatefulWidget` and `setState` for state management, including asynchronous API calls (seen extensively in `home_page.dart`).
   - Try to isolate state into smaller, individual widgets rather than bloating parent pages.

3. **Backend Integration (Supabase)**
   - **Never hardcode credentials.** Always assume `SupabaseConfig.client` is initialized globally.
   - For any database query (insert, select, update) or auth event, create or use a method inside the `lib/services/` directory rather than calling Supabase directly from the UI code.
   
4. **UI Conventions**
   - Use `GoogleFonts.urbanist` (or as dictated by `constants.dart`) for typography.
   - Fetch reusable strings, colors, and static data from `lib/utils/constants.dart`.
   - Prefer breaking down large UI trees into separate private or public widget classes in `lib/components/`.

5. **Beware of Monoliths**
   - Files like `home_page.dart` are very large. When instructed to add a feature to the Home Page, prioritize creating a separate component in `lib/components/` and injecting it into the page, rather than writing the entire widget tree inline.

## 🛑 Security Notice
- Rely on the `.env` file for API keys. Do not duplicate them in code.
- Authentication hashes passwords automatically via Supabase, so simple email/password auth flows via `auth_service.dart` are secure.

---
## 📈 Changes & Performance Reports
- **Performance Reporting**: At the end of every successful working session where positive changes/features/refactors were made, you MUST document them in `PerformanceReport.txt`. Create a dated header (e.g. `## March 27, 2026`) and list concise, technical points about the improvements. Do not document bug fixes!

**Happy Coding! 🚀**
