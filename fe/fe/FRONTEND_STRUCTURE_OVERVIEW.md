# AgriConnect Frontend - Comprehensive Structure Overview

## Executive Summary
**AgriConnect** is a multi-role agricultural platform connecting **Petani (Farmers)**, **Pembeli (Buyers)**, and **Admin** users. The Flutter frontend manages marketplace transactions, harvest tracking, inventory management, and administrative oversight.

---

## 1. PAGES STRUCTURE

### 1.1 SHARED PAGES (Authentication & Landing)
**Location:** `/lib/presentation/pages/shared/`

| Page | Purpose | Data Needed | Key Navigation |
|------|---------|-------------|-----------------|
| `landing_page.dart` | Landing page with hero, features, FAQ | None | → Role Selection |
| `role_selection_screen.dart` | Select role (Petani/Pembeli/Admin) | None | → Login by role |
| `user_login_screen.dart` | Login for Petani & Pembeli | Email, Password, Role | → Role-specific Dashboard |
| `admin_login_screen.dart` | Admin-specific login | Email, Password | → Admin Dashboard |
| `register_role_screen.dart` | Role selection during registration | None | → Registration form |
| `register_info_screen.dart` | Registration form (email, password, details) | Email, Password, Name, Phone, Location | → Dashboard |
| `responsive_user_layout.dart` | Main layout wrapper for Pembeli | AuthContext, Pages list | Pembeli Marketplace |
| `virtual_assistant_page.dart` | AI assistant chat for Pembeli | None (placeholder) | Pembeli dashboard |

**Data Flow:**
```
Landing Page → Role Selection → Login (email/password) 
→ API: /auth/login → Receive: {token, role, user}
→ AuthController stores token & role
→ Navigate to role-specific main layout
```

---

### 1.2 ADMIN PAGES
**Location:** `/lib/presentation/pages/admin/`

| Page | Purpose | Data Model | Key Features |
|------|---------|------------|--------------|
| `admin_main_layout.dart` | Main navigation hub for admin | None | Sidebar navigation (7 sections) |
| `admin_dashboard_screen.dart` | Overview with stats & charts | Dashboard stats (hardcoded) | 4 stat cards, 6-month chart, activity log |
| `admin_login_screen.dart` | Admin login page | Email, Password | Role-specific login |
| `manage_users_screen.dart` | List/search/filter users | `UserModel`: id, name, email, role, lokasi | Search, filter by role, edit/delete |
| `manage_commodities_screen.dart` | CRUD commodities | `CommodityModel`: id, name, cycle, currentPrice | Grid view, add/edit/delete commodities |
| `reference_prices_screen.dart` | View & update commodity prices | Price history, commodity data | Current prices table + history table |
| `monitor_orders_screen.dart` | Track all orders | Order objects | Filter by status, view order details |
| `aggregate_reports_screen.dart` | View system reports (stub) | Report data | Analytics & aggregation |
| `activity_logs_screen.dart` | View system activity logs | Activity log entries | Filter by type, view details |

**Admin Navigation (7 items):**
1. Dashboard
2. Kelola User (Manage Users)
3. Komoditas (Manage Commodities)
4. Harga Ref. (Reference Prices)
5. Order (Monitor Orders)
6. Laporan (Reports)
7. Log (Activity Logs)

**Key Data Structures:**
```dart
// Orders
{
  'id': '#ORD-001',
  'pembeli': 'Siti Aminah',
  'produk': 'Padi Organik',
  'jumlah': '10 kg',
  'total': 'Rp 52rb',
  'status': 'Pending|Dikonfirmasi|Selesai'
}

// Commodity Reference
{
  'icon': '🌾',
  'name': 'Padi',
  'harga': 'Rp 5.200/kg',
  'tgl': '05 Jun 2026',
  'oleh': 'Admin'
}
```

---

### 1.3 PETANI (FARMER) PAGES
**Location:** `/lib/presentation/pages/petani/`

| Page | Purpose | Data Model | Key Features |
|------|---------|------------|--------------|
| `petani_main_layout.dart` | Main navigation hub (5 tabs) | None | Bottom nav to P1-P6 pages |
| `p1_beranda_screen.dart` | Dashboard/home for farmer | Stats, charts | 4 stat cards, 6-month chart, upcoming tasks |
| `p2_daftar_panen_screen.dart` | List all harvests | Harvest records | Card list, add button → P2a form |
| `p2a_form_catat_panen_screen.dart` | Record new harvest | Form fields | Komoditas, tanggal, berat, grade, catatan, upload foto |
| `p3_jadwal_tanam_screen.dart` | Planting schedule | Schedule objects | Add/view schedules, link to P3a |
| `p3a_biaya_produksi_screen.dart` | Production costs for schedule | Cost breakdown | Detail view for specific schedule |
| `p4_stok_jual_screen.dart` | Sell stock inventory | Stock items | View/add/edit stock, toggle status (Public/Draft) |
| `p6_profil_screen.dart` | Farmer profile & settings | User profile, preferences | Edit button, notifications, account settings |
| `p6a_verifikasi_screen.dart` | Account verification flow | Verification status | Pending/verified state |
| `commodity_prices_page.dart` | Price trend graph (stub) | Commodity price history | Fluktuasi tren harga (placeholder) |
| `petani_dashboard.dart` | Alternative dashboard (deprecated) | Redirects to P1 | Stub - exports to p1_beranda_screen |
| `petani_report_page.dart` | Report generation (stub) | Report data | Placeholder |
| `planting_schedule_page.dart` | Alternative schedule view | Redirects to P3 | Placeholder |
| `production_costs_page.dart` | Alternative costs view | Redirects to P3a | Placeholder |
| `stock_publish_page.dart` | Alternative stock view | Redirects to P4 | Placeholder |
| `harvest_form_page.dart` | Alternative harvest form | Redirects to P2a | Placeholder |

**Petani Bottom Navigation (5 tabs):**
1. **Beranda** (P1) - Dashboard/Home
2. **Panen** (P2) - Harvest Management
3. **Jadwal** (P3) - Planting Schedule
4. **Stok** (P4) - Stock/Inventory
5. **Profil** (P6) - Profile & Settings

**Key Petani Data Structures:**

```dart
// Harvest Record (P2)
{
  'komoditas': 'Padi Organik',
  'date': '15 Mar 2026',
  'berat': '120 kg',
  'grade': 'Grade A',
  'status': 'Selesai|Dijual|Proses'
}

// Planting Schedule (P3)
{
  'komoditas': 'Padi',
  'lahan': 'Sawah A',
  'tanam': '15 Mar 2026',
  'panen': '15 Jun 2026',
  'status': 'H-7|Aktif|Selesai',
  'notif': 'Notifikasi H-7 aktif'
}

// Stock Item (P4)
{
  'nama': 'Padi Organik',
  'stok': 80,
  'harga': 5500,
  'satuan': 'kg',
  'tanggal': '15 Mar',
  'status': 'Publik|Draft'
}

// Harvest Form (P2a) - Form submission
{
  'komoditas': String,
  'tanggal': String (DD/MM/YYYY),
  'berat': double,
  'grade': 'A|B|C',
  'catatan': String,
  'foto': File (placeholder)
}
```

---

### 1.4 PEMBELI (BUYER) PAGES
**Location:** `/lib/presentation/pages/pembeli/`

| Page | Purpose | Data Model | Key Features |
|------|---------|------------|--------------|
| `pembeli_main_layout.dart` | (UNUSED - see responsive_user_layout) | None | Deprecated main layout |
| `pembeli_dashboard.dart` | Dashboard welcome & categories | Category data | Welcome banner, category grid |
| `pembeli_marketplace.dart` | Product marketplace grid | Product list | 4 dummy products, grid layout |
| `product_detail_page.dart` | Single product detail view | Product data | Description, price, seller info, "Add to Cart" button |
| `cart_page.dart` | Shopping cart | Cart items | Item list, total, checkout button |
| `checkout_page.dart` | Payment confirmation | Order summary | Order summary, payment method (Midtrans), "Pay Now" button |
| `order_tracking_page.dart` | Track order progress | Order status | 4-step progress (Confirmed, Processing, Shipping, Received) |
| `transaction_history_page.dart` | View past purchases | Transaction list | List of past transactions with status |

**Pembeli Navigation (2 items - via responsive_user_layout):**
1. **Pasar** (Marketplace) - Browse & buy products
2. **Asisten AI** (Virtual Assistant) - Chat support

**Key Pembeli Data Structures:**

```dart
// Product (Marketplace)
{
  'name': 'Beras Premium Cianjur',
  'price': 'Rp 14.000 / kg',
  'petani': 'Pak Budi – Cianjur',
  'icon': Icons.grain
}

// Cart Item
{
  'name': String,
  'price': String,
  'quantity': int
}

// Order
{
  'id': '#AGR-20240101',
  'items': [
    {'nama': 'Beras Premium Cianjur', 'qty': 2, 'price': 'Rp 28.000'},
    {'nama': 'Cabai Merah Keriting', 'qty': 1, 'price': 'Rp 38.000'}
  ],
  'total': 'Rp 66.000',
  'status': 'Pesanan Dikonfirmasi|Diproses Petani|Dalam Pengiriman|Diterima Pembeli'
}
```

---

## 2. CONTROLLERS

### 2.1 AuthController
**Location:** `/lib/presentation/controllers/auth_controller.dart`

**Purpose:** Manages authentication state, login/logout, role validation, and session timeout

**Key Properties:**
```dart
bool isLoggedIn              // Has valid token
String? currentRole          // Petani|Pembeli|Admin (capitalized)
bool isLoading              // Request in progress
String? lastError           // Last error message
```

**Key Methods:**
```dart
Future<bool> executeLogin(String email, String password, String intendedRole)
  // Returns true if login successful + role matches intendedRole
  // API: POST /auth/login
  // Response: {token, role}
  
Future<void> executeLogout()
  // Clears token and role
  // API: POST /auth/logout
```

**Session Management:**
- Auto-logout after 2 hours of inactivity
- Token refresh on every request
- `onSessionExpired` callback to handle expiration

---

## 3. DATA MODELS

### 3.1 UserModel
**Location:** `/lib/data/models/user_model.dart`

```dart
class UserModel {
  final int id;
  final String name;
  final String email;
  final String role;  // 'admin'|'petani'|'pembeli'

  factory UserModel.fromJson(Map<String, dynamic> json)
}
```

### 3.2 CommodityModel
**Location:** `/lib/data/models/commodity_model.dart`

```dart
class CommodityModel {
  final int id;
  final String name;
  final String cycle;        // Planting cycle duration
  final double currentPrice;

  factory CommodityModel.fromJson(Map<String, dynamic> json)
}
```

**Note:** Most pages use hardcoded/local data. Models are minimal. Backend likely has richer models.

---

## 4. SERVICES & REPOSITORIES

### 4.1 ApiService
**Location:** `/lib/data/services/api_service.dart`

**Purpose:** HTTP client with token management and timeout handling

**Key Methods:**
```dart
Future<http.Response> getRequest(String endpoint)
  // GET request with auth headers
  // Timeout: 3 seconds

Future<http.Response> postRequest(String endpoint, Map<String, dynamic> body)
  // POST request with JSON body + auth headers
  // Timeout: 3 seconds
```

**Features:**
- Automatic token injection in Authorization header
- Session timeout (2 hours inactivity)
- Consistent error handling

### 4.2 AuthRepository
**Location:** `/lib/data/repositories/auth_repository.dart`

**Purpose:** Authentication business logic

**Key Methods:**
```dart
Future<Map<String, dynamic>> login(String email, String password)
  // API: POST /api/auth/login
  // Returns: {token, role}
  
Future<void> logout()
  // API: POST /api/auth/logout
```

---

## 5. API ENDPOINTS

### 5.1 API Constants
**Location:** `/lib/core/constanst/api_constants.dart`

```dart
class ApiConstants {
  // Base URL (configurable per environment)
  static const String _host = 'http://127.0.0.1:8000';
  static const String baseUrl = '$_host/api';

  // Auth Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String logoutEndpoint = '/auth/logout';
  static const String profileEndpoint = '/auth/profile';

  // Data Endpoints
  static const String commoditiesEndpoint = '/commodities';
  static const String logsEndpoint = '/activity-logs';
}
```

### 5.2 API Endpoints Summary

| Method | Endpoint | Purpose | Request Body | Response |
|--------|----------|---------|--------------|----------|
| POST | `/api/auth/login` | User login | `{email, password}` | `{token, role, user}` |
| POST | `/api/auth/register` | User registration | `{email, password, name, ...}` | `{token, role}` |
| POST | `/api/auth/logout` | User logout | `{}` | `{success}` |
| GET | `/api/auth/profile` | Get current user | None | `{user: {id, name, email, role}}` |
| GET | `/api/commodities` | List all commodities | None | `[{id, name, cycle, current_price}]` |
| GET | `/api/activity-logs` | Get activity logs | None | `[{id, action, user, timestamp}]` |

**Note:** Frontend currently uses mostly hardcoded data. These endpoints are defined but not actively called in most pages. Backend integration is planned.

---

## 6. DATA FLOW DIAGRAMS

### 6.1 Authentication Flow

```
┌─────────────────────────────────────────────────────────┐
│ Landing Page / Role Selection                           │
└──────────────────────┬──────────────────────────────────┘
                       │
                       ↓
┌─────────────────────────────────────────────────────────┐
│ Login Screen (User/Admin specific)                      │
│ Input: email, password, role                            │
└──────────────────────┬──────────────────────────────────┘
                       │
                       ↓
┌─────────────────────────────────────────────────────────┐
│ AuthController.executeLogin()                           │
│ Validate: role matches server role                      │
└──────────────────────┬──────────────────────────────────┘
                       │
                       ↓
┌─────────────────────────────────────────────────────────┐
│ AuthRepository.login()                                  │
│ POST /api/auth/login → receive {token, role, user}     │
└──────────────────────┬──────────────────────────────────┘
                       │
                       ↓
┌─────────────────────────────────────────────────────────┐
│ ApiService.updateToken(token)                           │
│ Start 2-hour auto-logout timer                          │
└──────────────────────┬──────────────────────────────────┘
                       │
                       ↓
┌─────────────────────────────────────────────────────────┐
│ Navigate to Role-Specific Main Layout                   │
│ Petani → PetaniMainLayout                               │
│ Pembeli → ResponsiveUserLayout                          │
│ Admin → AdminMainLayout                                 │
└─────────────────────────────────────────────────────────┘
```

### 6.2 Petani Workflow (Farmer)

```
Petani Dashboard (P1)
├── View: 4 stat cards (Panen, Jadwal, Harga, Stok)
├── View: 6-month harvest trend chart
└── View: Upcoming tasks

         ↓
      ┌──────────────────┐
      │ User selects tab │
      └────────┬─────────┘
               │
    ┌──────────┼──────────┬────────────┬──────────┐
    ↓          ↓          ↓            ↓          ↓
   P1         P2         P3           P4         P6
  Home     Harvests   Planting    Stock      Profile
           (P2)      Schedule    Items
                      (P3)       (P4)
             │          │         │
             ↓          ↓         ↓
          P2a        P3a        Edit/Add
        (Form:    (Costs      Stock
       komoditas, detail)    - nama
       tanggal,            - stok
       berat,              - harga
       grade,              - status
       catatan,            (Publik/Draft)
       foto)
```

### 6.3 Pembeli Workflow (Buyer)

```
ResponsiveUserLayout (Main wrapper)
│
├── Pasar (Marketplace)
│   ├── PembeliMarketplace
│   │   └── Product Grid (4 dummy products)
│   │       └── Click product
│   │           ↓
│   │           ProductDetailPage
│   │           ├── Product image
│   │           ├── Price, description
│   │           ├── Seller info
│   │           └── "Add to Cart" button
│   │               ↓
│   │               CartPage
│   │               ├── List cart items
│   │               ├── Total price
│   │               └── "Checkout" button
│   │                   ↓
│   │                   CheckoutPage
│   │                   ├── Order summary
│   │                   ├── Payment method (Midtrans)
│   │                   └── "Pay Now" button
│   │                       ↓
│   │                       OrderTrackingPage
│   │                       ├── Step 1: Pesanan Dikonfirmasi ✓
│   │                       ├── Step 2: Diproses Petani
│   │                       ├── Step 3: Dalam Pengiriman
│   │                       └── Step 4: Diterima Pembeli
│   │
│   └── TransactionHistoryPage
│       └── List past purchases
│
└── Asisten AI (Virtual Assistant)
    └── VirtualAssistantPage (placeholder)
```

### 6.4 Admin Workflow

```
AdminMainLayout (Sidebar navigation)
│
├─ Dashboard (Stats, charts, activity)
├─ Kelola User (Search, filter, edit, delete users)
├─ Komoditas (Grid view, add/edit/delete commodities)
├─ Harga Ref. (View current prices, update, view history)
├─ Monitor Order (Filter by status, view order details)
├─ Laporan (Aggregate reports - stub)
└─ Log (Activity logs - stub)
```

---

## 7. DATA STRUCTURES & REQUIRED FIELDS

### 7.1 Form Submissions

**P2a - Record Harvest (Catat Panen)**
```json
{
  "komoditas": "string (required)",
  "tanggal": "DD/MM/YYYY (required)",
  "berat": "number (required)",
  "grade": "A|B|C (required)",
  "catatan": "string (optional)",
  "foto": "file (optional)"
}
```

**User Registration**
```json
{
  "name": "string",
  "email": "string",
  "password": "string",
  "role": "petani|pembeli|admin",
  "phone": "string (optional)",
  "location": "string (optional)"
}
```

### 7.2 Response Structures

**Login Response**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": {
      "id": 1,
      "name": "Budi Santoso",
      "email": "budi@mail.com",
      "role": "petani|pembeli|admin"
    },
    "token": "eyJ0eXAiOiJKV1QiLCJhbGc..."
  }
}
```

**Commodities List Response**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "Padi",
      "cycle": "120 days",
      "current_price": 5200
    },
    ...
  ]
}
```

---

## 8. WIDGETS & UI COMPONENTS

**Location:** `/lib/presentation/widgets/`

| Widget | Purpose |
|--------|---------|
| `custom_input_field.dart` | Reusable text input with validation |
| `primary_button.dart` | Primary action button (green theme) |

**Color Constants:** `/lib/core/constanst/agri_colors.dart`
- `primaryDark`: #1B5E20 (Dark green)
- `primary`: #2E7D32 (Green)
- `primaryLight`: #4CAF50 (Light green)
- `accent`: #74C69D (Accent green)
- `background`: #F0F7F0 (Light background)
- `success`: #4CAF50
- `warning`: #FFA726
- `danger`: #E53935

---

## 9. CURRENT STATUS & NOTES

### ✅ Implemented Features
1. **Authentication System** - Login/logout with role validation
2. **Role-based Navigation** - Separate layouts for Petani, Pembeli, Admin
3. **Petani Dashboard** - Multi-tab interface (5 sections)
4. **Pembeli Marketplace** - Product browsing and cart
5. **Admin Dashboard** - Overview with stats and charts
6. **UI/UX** - Color-coded interfaces per role

### ⚠️ In Development / Stubs
1. **Most data is hardcoded** - No live API integration yet
2. **Virtual Assistant** - Placeholder only
3. **Reports/Logs** - Stub pages exist
4. **File uploads** - Foto upload in P2a is placeholder
5. **Real-time updates** - No WebSocket/streaming

### 🔌 API Integration Ready
- Endpoints defined but not called by most pages
- AuthRepository is the only active API consumer
- Models exist but not fully utilized
- Ready for backend integration

---

## 10. SUMMARY TABLE: Pages → Data Models → API Endpoints

| Role | Page | Data Model | API Endpoint | Status |
|------|------|-----------|--------------|--------|
| Shared | UserLoginScreen | UserModel | `/auth/login` | ✅ Active |
| Shared | AdminLoginScreen | UserModel | `/auth/login` | ✅ Active |
| Admin | ManageUsersScreen | UserModel | `/auth/profile` (future) | 📋 Hardcoded |
| Admin | ManageCommoditiesScreen | CommodityModel | `/commodities` (future) | 📋 Hardcoded |
| Admin | ReferencepricesScreen | CommodityModel | `/commodities` (future) | 📋 Hardcoded |
| Admin | MonitorOrdersScreen | OrderModel | `/orders` (not yet defined) | 📋 Hardcoded |
| Petani | P1BerandaScreen | Dashboard stats | `/dashboard` (not defined) | 📋 Hardcoded |
| Petani | P2DaftarPanenScreen | HarvestModel | `/harvests` (not defined) | 📋 Hardcoded |
| Petani | P2aFormCatatPanenScreen | HarvestModel | `/harvests` (POST) | 📋 Stub form |
| Petani | P3JadwalTanamScreen | ScheduleModel | `/planting-schedules` (not defined) | 📋 Hardcoded |
| Petani | P4StokJualScreen | StockModel | `/stock` (not defined) | 📋 Hardcoded |
| Petani | P6ProfilScreen | UserModel | `/auth/profile` (future) | 📋 Hardcoded |
| Pembeli | PembeliMarketplace | ProductModel | `/products` (not defined) | 📋 Hardcoded |
| Pembeli | ProductDetailPage | ProductModel | `/products/{id}` (not defined) | 📋 Hardcoded |
| Pembeli | CartPage | CartModel | None (local state) | 📋 Local only |
| Pembeli | CheckoutPage | OrderModel | `/orders` (POST) | 📋 Stub |
| Pembeli | OrderTrackingPage | OrderModel | `/orders/{id}` (not defined) | 📋 Hardcoded |
| Pembeli | TransactionHistoryPage | TransactionModel | `/transactions` (not defined) | 📋 Hardcoded |

**Legend:**
- ✅ Active - Real API integration
- 📋 Hardcoded - Uses mock/static data
- (not defined) - Endpoint mentioned but not in ApiConstants
- (future) - Endpoint defined but not called yet

---

## 11. QUICK REFERENCE: File Organization

```
lib/
├── main.dart                          [App entry point]
├── presentation/
│   ├── pages/
│   │   ├── admin/                    [9 admin pages]
│   │   ├── petani/                   [15 petani pages]
│   │   ├── pembeli/                  [7 pembeli pages]
│   │   └── shared/                   [8 shared pages]
│   ├── controllers/
│   │   └── auth_controller.dart      [Auth state management]
│   └── widgets/
│       ├── custom_input_field.dart
│       └── primary_button.dart
├── data/
│   ├── models/
│   │   ├── user_model.dart
│   │   └── commodity_model.dart
│   ├── services/
│   │   └── api_service.dart          [HTTP client]
│   └── repositories/
│       └── auth_repository.dart      [Auth API calls]
└── core/
    └── constanst/
        ├── api_constants.dart        [API endpoints]
        ├── agri_colors.dart          [Theme colors]
        └── [other constants]
```

---

## CONCLUSION

**AgriConnect Frontend** is a well-structured Flutter app with:
- ✅ Clear separation of concerns (Pages, Controllers, Models, Services)
- ✅ Three distinct user roles with dedicated interfaces
- ✅ Professional UI/UX with consistent branding
- ✅ Ready for backend API integration
- ⚠️ Currently using hardcoded/mock data (except authentication)
- 🔌 API layer established but underutilized

**Next Steps for Complete Integration:**
1. Connect remaining pages to API endpoints
2. Implement real data fetching in all pages
3. Add error handling and loading states
4. Implement local caching/offline support
5. Add real-time updates where needed
