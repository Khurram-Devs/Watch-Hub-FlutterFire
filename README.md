# ⌚️ WatchHub – Premium Watch Shopping App

**WatchHub** is a modern, luxurious shopping app built using **Flutter** and **Firebase**, offering a responsive and elegant interface for browsing and purchasing premium watches from top global brands. Designed with scalability and customization in mind, it includes real-time Firestore data, a rich product catalog, user authentication, and a complete profile system.

---

## 🚀 Features

### ✅ Completed

#### 🔐 Authentication
- Email/Password sign up and login
- Google Sign-In
- Forgot password with email recovery
- Auth-aware header with dynamic login/profile dropdown

#### 🏠 Home & Layout
- Responsive design (Web + Mobile)
- `AppHeader`, `NavDrawer`, `FooterWidget` used across all screens
- Carousel banners and promotional sections

#### 🛍️ Product Catalog
- Data from Firestore `products` & `categories`
- Grid/List toggle views
- Sort by: Price, Rating, Newest
- Filter by Brand, Type, Price Range
- Pagination / infinite scroll

#### 📄 Product Detail Page
- Route-based navigation (`/product/:id`) with dynamic fetch
- Product images gallery
- Specifications, pricing (with discount badge), and stock level
- Related products
- Customer FAQs and reviews
- Add to Cart / Wishlist buttons (stock-aware)

#### 🛒 Cart
- Firestore-based cart per user: `usersProfile/{uid}/cart/{productId}`
- Real-time quantity updates
- Quantity selector respects product stock
- Out-of-stock items are removed automatically
- Cart summary with subtotal, tax (15%), flat shipping ($25)
- 'Proceed to Checkout' button (placeholder)

#### ❤️ Wishlist
- Stored in `usersProfile/{uid}/wishlist`
- Uses `ProductListItem` layout for display
- Add/remove logic with dynamic favorite icons
- Wishlist accessible via profile tab

#### 👤 Profile Page
- Tab-based layout: `Profile`, `Address Book`, `Wishlist`, `Order History`
- Real-time user info with avatar, name, email, phone
- Address book: Add/remove addresses (`usersProfile/{uid}/addresses`)
- Wishlist: Move to cart placeholder
- Orders: Search, cancel, download invoice (PDF placeholder)

#### 🎨 Theming & Design
- Custom design system using `PlayfairDisplay` & `Lato`
- Luxury-themed color palette (emerald, golden, dark)
- `ThemeProvider` for light/dark mode toggle
- Layout uses modular widgets and responsive constraints

---

## 🔧 Tech Stack

| Tech                   | Description                                       |
|------------------------|---------------------------------------------------|
| Flutter                | Cross-platform UI toolkit                         |
| Firebase Auth          | Email/Password + Google Sign-In                   |
| Cloud Firestore        | Products, Users, Cart, Wishlist, Orders, etc.     |
| GoRouter               | Declarative routing with dynamic paths            |
| Provider               | Lightweight state management                      |
| Google Fonts           | Elegant typography (PlayfairDisplay, Lato)        |
| Flutter Native Splash  | Custom splash screen                              |
| Syncfusion PDF         | (Planned) For downloading invoices                |

---

## 📁 Firestore Structure

```
products/
  {productId} → title, price, stock, images, discountPercentage, specs, brandId

usersProfile/
  {uid}/
    wishlist/
      {productId} → productRef
    cart/
      {productId} → productRef, quantity, addedAt
    addresses/
      {addressId} → name, address, city, zip, etc.
    orders/
      {orderId} → total, status, paymentMethod, items, etc.
```

---

## 🛠️ How to Run Locally

> Requires Flutter 3.7.0+

```bash
# Clone the repository
git clone https://github.com/Khurram-Devs/Watch-Hub-FlutterFire.git
cd Watch-Hub-FlutterFire

# Install dependencies
flutter pub get

# Run
flutter run
```

---

## 🔐 Firebase Setup

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Enable:
   - Authentication → Email/Password
   - Authentication → Google
   - Firestore Database
3. Download Firebase config:
   - Android: `google-services.json` → `android/app/`
   - iOS: `GoogleService-Info.plist` → `ios/Runner/`
4. (Optional) Set Firestore rules to allow authenticated access.

---

## 📦 Coming Soon

- 🧾 Checkout & Payment integration
- 📱 Order confirmation page
- 🧑‍💼 Admin dashboard (orders, product upload)
- 🌐 Image hosting via **imgbb** (replacing Firebase Storage)
- 📲 APK Release (will be uploaded to GitHub)
- 🖼️ Product image zoom/lightbox (web)

---

## 📄 License

This project is **currently unlicensed**. You may view or contribute, but commercial use is not permitted.

---

## 🌟 Show Your Support

If you find WatchHub helpful or inspiring, give the repo a ⭐ on GitHub and share your feedback. Contributions, suggestions, or improvements are always welcome!