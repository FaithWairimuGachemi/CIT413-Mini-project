# CIT413-Mini-project
This is a cross-platform application mini project to aid accomplish all unit requirements before final unit exam. 


A Flutter app where students register and log in with their admission number and a password, and can add or change a profile picture. The admission number is the primary key for every account.

# Features
1. Registration with first name, optional middle name, last name, admission number and password (with confirmation)
Admission number as primary key. A duplicate registration is rejected with a clear message
2. Login with admission number and password. Admission numbers are trimmed and uppercased, so sc211/0001/2020 and SC211/0001/2020 match
3. Profile picture that can be added at registration and changed later from the profile screen (gallery on all platforms, camera on Android and iOS)
4. Persistent session. Returning users go straight to their profile until they log out
5. Passwords stored as salted SHA-256 hashes, never as plain text
6. Form validation, loading states and error messages on every screen

# Tech stack
Purpose	Package
Framework	Flutter (Dart)
Local database (mobile)	sqflite
Local database (desktop)	sqflite_common_ffi
Image selection	image_picker
File storage paths	path_provider, path
Session storage	shared_preferences
Password hashing	crypto

# Project structure
lib/
├── main.dart                     # App entry point, desktop DB setup, login gate
├── models/
│   └── app_user.dart             # User model (admission number is the primary key)
├── services/
│   └── auth_service.dart         # Database, registration, login, session, image saving
└── screens/
    ├── login_screen.dart
    ├── register_screen.dart
    └── profile_screen.dart
    
# How data is stored?
Everything is stored locally on the device for now.

Account details: a SQLite database (students.db) with a users table. admission_number is the PRIMARY KEY.
Profile pictures: image files copied into the app's own storage folder. The database keeps only the file path.
Session: the logged-in admission number is kept in shared_preferences.

Because the data lives on one device, an account created on one device does not exist on another.

# Getting started
# Prerequisites
Flutter SDK (run flutter doctor to confirm your setup)
For Android: Android Studio with the SDK and command-line tools installed, and licenses accepted (flutter doctor --android-licenses)
For Linux desktop: sudo apt install clang cmake ninja-build pkg-config libgtk-3-dev libsqlite3-dev, plus zenity for the image file chooser

# Run the app
bash 
git clone https://github.com/FaithWairimuGachemi/CIT413-Mini-project.git
cd CIT413-Mini-project
flutter pub get
flutter devices
flutter run -d <device-id>

Examples:

bash
flutter run -d linux      # Linux desktop
flutter run -d android    # a connected Android phone or emulator

Note: sqflite does not run in the browser, so Chrome/web is not supported.

# Camera permissions (optional)

Only needed if you want the "Take a photo" option on a phone.

Android: add <uses-permission android:name="android.permission.CAMERA"/> to android/app/src/main/AndroidManifest.xml
iOS: add NSPhotoLibraryUsageDescription and NSCameraUsageDescription to ios/Runner/Info.plist

# Using the app
Open the app and tap First time here? Create an account.
Enter your admission number, names and a password of at least 6 characters. Optionally add a picture.
After registering, you land on your profile showing your name, admission number and picture.
Tap the avatar to change your picture. Use the logout icon to sign out.
Log back in with the same admission number and password.

# Current limitations
Data is stored locally only, with no cloud sync and no shared records between devices
No password reset or "forgot password" flow
No profile editing beyond the picture
Hashing happens inside the app. A production system should hash passwords on a server with bcrypt or Argon2
# Roadmap
Move storage to a hosted backend (Supabase or Firebase) so accounts work across devices
Add password reset and profile editing
Add an admin view for managing student records
Add unit and widget tests



# Author

Faith Wairimu Gachemi (@FaithWairimuGachemi) Course project: CIT413
