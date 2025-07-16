# ⌚️ WatchHub – Premium Watch Shopping App

**WatchHub** is a luxurious, cross-platform shopping app for premium watches, built using **Flutter** and **Firebase**. With an elegant UI, real-time Firestore backend, and full e-commerce functionality, WatchHub offers a complete solution—from product browsing to order management and invoicing. It's responsive, scalable, and crafted with premium design elements to reflect the sophistication of top global watch brands.

---

## 🚀 Features

### ✅ Fully Completed & Production Ready

#### 🔐 Authentication
- Email/Password sign up & login
- Google Sign-In (OAuth)
- Password recovery via email
- Dynamic auth-aware AppHeader with login/profile controls
- Creates Firestore user profile under `usersProfile/{uid}` on sign up

#### 🏠 Home & UI Layout
- 100% responsive layout (Web, Tablet, Mobile)
- Shared components: `AppHeader`, `NavDrawer`, `FooterWidget`
- Carousel banners, promo sections, looping brand scroller
- Search bar with live suggestions powered by Firestore

#### 🛍️ Product Catalog
- Real-time catalog from Firestore (`products`, `categories`)
- Grid/List view toggles
- Sorting by: Price (asc/desc), Rating, Newest
- Filters: Brand, Type, Price Range (using RangeSlider)
- Pagination with infinite scroll
- Skeleton loaders with shimmer during data load

#### 📄 Product Detail Page
- Dynamic routing with GoRouter: `/product/:id`
- Firestore-based fetch with loading shimmer
- Multi-image gallery with thumbnails
- Pricing UI:
  - Final price
  - Strikethrough original price (if discounted)
  - Discount badge (% off)
- Detailed specs, average rating, FAQs, reviews
- Related products (smart match by category/brand)
- Interactive:
  - Add to Cart (stock-aware)
  - Add to Wishlist (requires login)

#### 🛒 Cart System
- Real-time, Firestore-based cart (`usersProfile/{uid}/cart/{productId}`)
- Quantity selector with instant sync
- Auto-removal of out-of-stock items
- Responsive cart layout:
  - Product thumbnails, details, controls
  - Summary with subtotal, 15% tax, fixed $25 shipping
- Shimmer loader while fetching cart
- 'Proceed to Checkout' button

#### ❤️ Wishlist
- Per-user wishlist under `usersProfile/{uid}/wishlist`
- Toggle favorite icon in all product cards
- Displays using `ProductListItem` layout
- Accessible via Profile → Wishlist tab
- Syncs with Firestore in real-time

#### 💳 Checkout
- Pre-filled from saved Firestore addresses
- Address form with validation
- Payment method selector (COD only)
- Promo code integration (`promoCode` collection):
  - Validates usage limit
  - Applies discount instantly
  - Increments `usedTimes` after successful order
- Order summary with full breakdown
- Order saved under `usersProfile/{uid}/orders/{orderId}`

#### ✅ Order Success Screen
- Displayed after successful checkout via `/order-success/:orderId`
- Shows summary: total amount, items, address, order ID
- Premium design with success animation & CTA

#### 👤 Profile Tabs (Modular)
- **Profile**:
  - Editable fields: fullName, phone, avatar (live updates)
- **Addresses**:
  - CRUD for saved addresses (`usersProfile/{uid}/addresses`)
- **Wishlist**:
  - View/remove products, wishlist sync
- **Orders**:
  - Live feed of orders from Firestore
  - Status indicators: Pending, Processing, Shipped
  - Cancel if status is pending
  - Order detail modal with invoice preview
  - Real-time order filtering by ID

#### 🧾 PDF Invoice
- Generated after each order using Syncfusion PDF
- Includes:
  - Buyer info
  - Product list with pricing, tax, shipping
  - Total payable
- Downloadable from orders tab (Web/Desktop supported)
- Saved to `Downloads/` directory or shown inline

#### 🔔 Notifications
- Notifications screen powered by Firestore
- Supports various types: order, promo, system
- Shimmer loading & `isRead` state handling

#### 🎨 Custom Theming & Design System
- Fully centralized `ThemeProvider`
  - `.primary`, `.secondary`, `.background`, etc. using extensions
  - Auto-switching between dark/light without manual `if` checks
- Fonts: `PlayfairDisplay` (headings), `Lato` (body)
- Color scheme: Emerald, Golden, Onyx (luxury look)
- Custom widgets:
  - `ProductGridItem`, `ProductListItem`, `WatchTile`, `AddToCartButton`, `AddToWishlistButton`, `CartItemTile`, etc.

---

## 🔧 Tech Stack

| Tech                  | Purpose                                              |
|-----------------------|------------------------------------------------------|
| **Flutter**           | Cross-platform app UI                                |
| **Firebase Auth**     | Email/Google Sign-In                                 |
| **Cloud Firestore**   | Real-time database for all app data                  |
| **GoRouter**          | Declarative routing with dynamic `/product/:id`      |
| **Provider**          | Lightweight state management                         |
| **Syncfusion PDF**    | In-app invoice generation                            |
| **Shimmer**           | Skeleton loading animations                          |
| **Google Fonts**      | Typography integration                               |
| **Flutter Native Splash** | Branded splash screen                             |

---

## 📁 Firestore Structure

```txt
products/
  {productId} → title, price, stock, discountPercentage, images[], specs, brandName, averageRating, totalRatings

categories/
  {categoryId} → name, type, iconUrl

promoCode/
  {code} → discountPercentage, usedTimes, limit

usersProfile/
  {uid}/
    cart/
      {productId} → productRef, quantity, addedAt
    wishlist/
      {wishlistDocId} → productRef
    addresses/
      {addressId} → name, street, city, zip, country, phone
    orders/
      {orderId} → items[], total, status, createdAt, paymentMethod, shippingInfo
    notifications/
      {notificationId} → title, message, type, isRead, createdAt
testimonials/
  {testimonialId} → message, rating, userRef
```

---

## 🛠️ How to Run Locally

> Requires Flutter 3.7.0 or higher

```bash
# Clone the project
git clone https://github.com/Khurram-Devs/Watch-Hub-FlutterFire.git
cd Watch-Hub-FlutterFire

# Install dependencies
flutter pub get

# Run the app
flutter run
```

---

## 🔐 Firebase Setup

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create project and enable:
   * Firestore Database
   * Authentication → Email/Password
   * Authentication → Google
3. Download configuration files:
   * Android: `google-services.json` → `android/app/`
   * iOS: `GoogleService-Info.plist` → `ios/Runner/`
4. (Optional) Add Firestore security rules to restrict unauthorized access.

---

## 📦 Coming Soon

* 💳 Stripe Integration (test/live mode)
* 🧑‍💼 Admin Dashboard (order management, product CRUD, analytics)
* 📲 APK / IPA release via GitHub or Codemagic CI/CD
* 🌐 Optimized image hosting via Cloudflare or imgbb
* 🖼️ Zoomable gallery & fullscreen lightbox
* 🔔 Push Notifications via FCM for order updates & promos

---

## 📄 License

This project is **currently unlicensed**. You are welcome to explore and contribute, but commercial use is not allowed without permission.

---

## 🌟 Show Your Support

If you found **WatchHub** helpful or inspiring:

* ⭐ Star the repo on [GitHub](https://github.com/Khurram-Devs/Watch-Hub-FlutterFire)
* 🛠️ Suggest features or improvements
* 🤝 Contributions are always welcome!

---

> *This README was enhanced and curated with developer best practices and AI support.*