# EduChain Lite 🎓🔐
> **Secure Student Digital Profile & Certificate Verification System**  
> Developed as a Semester Final Project for *Android and Web Application Development (PROG 212)* at the University of Frontier Technology, Bangladesh.

---

## 📌 Project Overview
**EduChain Lite** is a cross-platform mobile application built using **Flutter (Dart)** and a **PHP/MySQL (XAMPP)** backend. It is designed to mitigate academic credential fraud (fake certificates) in Bangladesh using client-side cryptographic hashing (**SHA-256**) and dynamic **QR Code** generation.

The system acts as a **Digital Wallet** for students to manage their academic profiles and allows employers to instantly verify certificates in real-time using their smartphone cameras—bypassing lengthy traditional university verification pipelines.

---

## 🚀 Key Features

### 👤 For Students (Digital Wallet Mode)
- **Secure Authentication:** Secure account creation & session management using Local Storage (`SharedPreferences`).
- **Dynamic Profile Management:** Students can update their profile information, academic records (CGPA, Department, Session), and skills.
- **Local SHA-256 Hashing:** App computes a 64-character hexadecimal fingerprint (hash) of chosen PDF/Image certificates locally on the device prior to upload.
- **Dynamic QR Code Generation:** On-the-fly generation of unique QR codes containing both Student IDs and Certificate signatures.
- **My Profile QR:** Instantly generates a unique digital academic ID QR code representing the student's entire profile.

### 💼 For Employers (Fast Verification Mode)
- **No Login Required:** Recruiters can access the camera scanner instantly from the login screen.
- **Dual-Mode Scanner:** 
  - Scan **Certificate QR** $\rightarrow$ Instantly validates the hash against the University Central Database and displays degree/student info if genuine.
  - Scan **Profile QR** $\rightarrow$ Instantly displays the verified student resume directly from the server.
- **Double-Pop Protection:** Built-in scanner lock flag to prevent application crashes during continuous camera detection.
- **Zero-Trust Validation:** Instant detection of fake or modified certificates (even changing one pixel of a certificate image completely alters its SHA-256 hash).

---

## 🛠️ Technology Stack

- **Frontend:** Flutter SDK (Dart), Material 3 UI.
- **Core Packages:** `mobile_scanner` (QR scanning), `qr_flutter` (QR generation), `crypto` (SHA-256), `file_picker`, `shared_preferences`.
- **Backend API:** PHP (RESTful APIs with PDO drivers).
- **Database Server:** MySQL, Apache hosted locally on XAMPP Local Server.

---

## 📂 System File Directory
```directory
lib/
├── main.dart                 # Splash decider and session entry point
├── models/
│   ├── student.dart          # Blueprint for Student profiles
│   └── certificate.dart      # Blueprint for Certificate records
├── screens/
│   ├── login_screen.dart     # Sign In with Employer fast-bypass route
│   ├── signup_screen.dart    # Student registration 
│   ├── dashboard_screen.dart # Tab navigation hub (Material 3)
│   ├── home_tab.dart         # Dashboard widgets & Personal QR card
│   ├── profile_screen.dart   # Profile viewer and profile editor
│   ├── certificates_screen.dart # Certificates portfolio list
│   └── verify_screen.dart    # Live camera scanner & Verification cards
└── services/
    └── api_service.dart      # REST API client calling backend scripts
```
🔧 Installation & Local Setup
1. Database Configuration
Start Apache and MySQL inside XAMPP.
Open localhost/phpmyadmin in your web browser.
Create a database named educhain_db.
Import the schema tables into your database.
2. Backend API Setup
Create a folder named educhain_api inside C:\xampp\htdocs\ (on Windows) or /Applications/XAMPP/xamppfiles/htdocs/ (on macOS).
Inside educhain_api/, create the folder uploads/ for file storage.
Paste your PHP backend script files (db_connect.php, login.php, signup.php, get_profile.php, update_profile.php, add_certificate.php, get_certificates.php, verify_certificate.php) into this directory.
3. Flutter Client Configuration
Open the project inside Android Studio or VS Code.
In lib/services/api_service.dart, update the _baseUrl to match your PC/Macbook's local IPv4 Address:
code
Dart
static const String _baseUrl = 'http://192.168.0.XXX/educhain_api';
Run the following command in terminal to fetch dependencies:
code
Bash
flutter pub get
Run the project on an Emulator or a physical device:
code
Bash
flutter run
🎯 Verification Logic (How Tamper Detection Works)
Each certificate file is cryptographically unique. When a file is uploaded, the app generates its SHA-256 fingerprint (e.g. c81f91f5f5...). If a fraudster modifies even one pixel on a certificate (e.g. changing CGPA from 3.00 to 3.90), the SHA-256 algorithm will yield an entirely different hash. When scanned, the app queries the central university registry, sees that the modified hash is not registered, and flags the certificate instantly as ❌ TAMPERED / INVALID.
👤 Developer Profile
Md. Shafinur Rahman - ID: 2303023
Department of Software Engineering, University of Frontier Technology, Bangladesh.
Supervised by: Md. Ahsan Habib (Lecturer, Department of Software Engineering).
