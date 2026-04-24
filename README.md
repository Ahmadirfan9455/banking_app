# Premium Banking App

A professional, high-fidelity banking application built with Flutter, featuring a modern glassmorphism aesthetic. This application provides a seamless and secure experience for both users and administrators.

## 🌟 Features

* **Modern Glassmorphism UI**: A visually stunning interface with a premium glass-like aesthetic, offering a clean and responsive user experience.
* **Secure Authentication**: Robust login system with 6-digit email OTP (One-Time Password) verification powered by SMTP.
* **Role-Based Access**: Distinct and seamless navigation between User and Admin dashboards.
* **Real-time Data Sync**: Transitioned from mocked data to real-time operations using Firebase Firestore.
* **Financial Transactions**: Manage transactions, view balances, and handle account operations securely.
* **System Telemetry**: Real-time tracking and monitoring for admin insights.

## 📸 Screenshots

| User Dashboard | Admin Dashboard | OTP Verification |
| :---: | :---: | :---: |
| *(Add screenshot here)* | *(Add screenshot here)* | *(Add screenshot here)* |

## 🛠️ Technology Stack

* **Frontend**: Flutter, Dart
* **Backend/Database**: Firebase Firestore
* **Authentication**: Email OTP via SMTP
* **State Management**: *(Add your preferred state management, e.g., Provider/Riverpod/GetX/Bloc)*

## 🚀 Getting Started

### Prerequisites

* [Flutter SDK](https://docs.flutter.dev/get-started/install)
* [Dart SDK](https://dart.dev/get-dart)
* Android Studio / VS Code
* A Firebase Project configured for Android/iOS

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Ahmadirfan9455/banking_app.git
   cd banking_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   * Create a project in the Firebase Console.
   * Add Android/iOS apps and download the `google-services.json` / `GoogleService-Info.plist` files.
   * Place them in the respective platform directories.

4. **Run the app**
   ```bash
   flutter run
   ```

## 📂 Project Structure

```text
banking_app/
├── lib/
│   ├── main.dart           # Application entry point
│   ├── screens/            # UI Screens (User/Admin dashboards, Auth, etc.)
│   ├── widgets/            # Reusable UI components (Glassmorphism cards, etc.)
│   ├── services/           # API, Firebase, and SMTP services
│   ├── models/             # Data models
│   └── utils/              # Helper functions and constants
├── test/                   # Unit and widget tests
└── pubspec.yaml            # Project dependencies
```

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!
Feel free to check [issues page](https://github.com/Ahmadirfan9455/banking_app/issues).

## 👨‍💻 Author

**Ahmad Irfan**
* GitHub: [@Ahmadirfan9455](https://github.com/Ahmadirfan9455)
* Email: irfanmuzammil143@gmail.com
