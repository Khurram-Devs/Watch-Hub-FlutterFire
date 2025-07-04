
# ⌚️ WatchHub – Premium Watch Shopping App

WatchHub is a modern, responsive Flutter + Firebase app built for users who want to explore and purchase premium watches from top global brands. With rich UI, dynamic search, filtering, product detail views, and authentication (Email + Google), WatchHub brings a luxurious e-commerce experience right to your phone or browser.

---

## 🚀 Features

### ✅ Completed
- 🔐 **Authentication**
  - Email/Password sign up and login
  - Google Sign-In support
  - Forgot Password recovery
- 🏠 **Home Screen**
  - Themed with brand colors (emerald, gold, dark)
  - Banner carousel and promotional content
- 🛍️ **Product Catalog**
  - Grid/List toggle view
  - Sort by: Price, Rating, Newest
  - Filter by Brand, Price Range, Type
  - Infinite scroll / pagination
- 📄 **Product Detail**
  - Image gallery
  - Product specifications
  - Price with discount badge
  - Related products
  - Customer FAQs
  - Customer reviews
- 🎨 **WatchHub Theme**
  - Custom fonts: `PlayfairDisplay` & `Lato`
  - Consistent layout using `AppHeader`, `NavDrawer`, and `FooterWidget`
  - Responsive across mobile and web
- 📦 **Firebase Integration**
  - Firebase Authentication
  - Cloud Firestore for product & category data

---

## 🔧 Tech Stack

| Tech                  | Description                                      |
|-----------------------|--------------------------------------------------|
| Flutter               | Frontend UI toolkit (responsive, cross-platform) |
| Firebase Auth         | Email/Password + Google Sign-In                  |
| Firestore             | NoSQL backend database (products, brands, etc.)  |
| Google Fonts          | Elegant typography (PlayfairDisplay, Lato)       |
| Provider              | Lightweight state management                     |
| Video Player          | Embedded promo/teaser support (in future)        |
| Flutter Native Splash | Custom splash screen support                     |

---

## 🔐 Firebase Setup

To run this app:

1. Create a Firebase project on [Firebase Console](https://console.firebase.google.com/)
2. Enable:
   - **Authentication → Email/Password**
   - **Authentication → Google Sign-In**
   - **Firestore Database**
3. Add your Android/iOS/Web apps to Firebase.
4. Download:
   - `google-services.json` (for Android) → place in `android/app/`
   - `GoogleService-Info.plist` (for iOS) → place in `ios/Runner/`

---

## 💻 Run Locally

> Make sure you have Flutter ≥ 3.7.0 installed

```bash
# Clone the repo
git clone https://github.com/Khurram-Devs/Watch-Hub-FlutterFire.git
cd Watch-Hub-FlutterFire

# Install dependencies
flutter pub get

# Run the app
flutter run
```

---

## 🛠️ In Progress / Coming Soon

- 🛒 Cart & Wishlist
- 👤 User profile & order history
- 🧑‍💼 Admin Dashboard
- 🧾 Checkout & payment flow
- 🌐 Image hosting via imgbb (instead of Firebase Storage)
- 📦 APK Release on GitHub

---

## 📄 License

This project is currently unlicensed.

---

## 🌟 Show Your Support

If you found this project helpful, feel free to ⭐ star the repo or contribute!
