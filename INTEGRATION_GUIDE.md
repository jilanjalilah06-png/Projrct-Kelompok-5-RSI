# Frontend-Backend Integration Guide

## Overview
Frontend telah diselaraskan dengan backend Laravel dengan menambahkan:
- **Models** lengkap untuk semua entitas (Product, Order, Category, Review, Seller)
- **Repositories** untuk akses data ke API
- **Controllers** untuk manajemen state dan business logic
- **Enhanced ApiService** dengan support untuk PUT, PATCH, DELETE

---

## 1. Architecture

```
Data Layer (data/)
├── models/              # Data models matching backend
├── repositories/        # API access layer
└── services/           # HTTP client (ApiService)

Presentation Layer (presentation/)
├── controllers/        # State management (ChangeNotifier)
└── pages/             # UI pages
```

---

## 2. Quick Start: Using Controllers in Pages

### Setup in main.dart
```dart
MultiProvider(
  providers: [
    Provider<ApiService>.value(value: apiService),
    ChangeNotifierProvider<AuthController>(
      create: (_) => AuthController(apiService),
    ),
    // Add these controllers
    ChangeNotifierProvider<ProductController>(
      create: (_) => ProductController(apiService),
    ),
    ChangeNotifierProvider<OrderController>(
      create: (_) => OrderController(apiService),
    ),
    ChangeNotifierProvider<SellerController>(
      create: (_) => SellerController(apiService),
    ),
  ],
  child: const AgriConnectApp(),
)
```

---

## 3. Controllers & Their Usage

### ProductController
Manages products and categories.

**Load Products:**
```dart
final productCtrl = Provider.of<ProductController>(context, listen: false);

// Load all products
await productCtrl.loadProducts();

// Load with filters
await productCtrl.loadProducts(
  categoryId: 2,
  search: "beras",
  limit: 20,
);

// Load products by seller
await productCtrl.loadSellerProducts(sellerId: 1);

// Load single product
await productCtrl.loadProductById(productId: 5);
```

**Create/Update/Delete Products:**
```dart
// Create
bool success = await productCtrl.createProduct(
  categoryId: 1,
  name: "Beras Merah",
  description: "Beras merah organik premium",
  price: 25000,
  stock: 100,
  unit: "kg",
);

// Update
bool success = await productCtrl.updateProduct(
  productId,
  name: "New Name",
  price: 30000,
  stock: 50,
);

// Delete
bool success = await productCtrl.deleteProduct(productId);

// Toggle status
bool success = await productCtrl.toggleProductStatus(productId, false);
```

**Load Categories:**
```dart
await productCtrl.loadCategories();
List<CategoryModel> categories = productCtrl.categories;

// Create category (Admin only)
await productCtrl.createCategory(name: "Buah-buahan");

// Update category
await productCtrl.updateCategory(categoryId, name: "Sayuran Segar");

// Delete category
await productCtrl.deleteCategory(categoryId);
```

**Usage in UI:**
```dart
Consumer<ProductController>(
  builder: (context, productCtrl, _) {
    if (productCtrl.isLoading) {
      return const CircularProgressIndicator();
    }
    
    if (productCtrl.lastError != null) {
      return Text('Error: ${productCtrl.lastError}');
    }

    return ListView.builder(
      itemCount: productCtrl.products.length,
      itemBuilder: (context, index) {
        final product = productCtrl.products[index];
        return ListTile(
          title: Text(product.name),
          subtitle: Text('Rp${product.price}'),
        );
      },
    );
  },
)
```

---

### OrderController
Manages orders and reviews.

**Load Orders:**
```dart
final orderCtrl = Provider.of<OrderController>(context, listen: false);

// Load all orders
await orderCtrl.loadOrders();

// Load with filters
await orderCtrl.loadOrders(
  status: OrderModel.statusPending,
  page: 1,
  limit: 10,
);

// Load pending orders
await orderCtrl.loadPendingOrders();

// Load completed orders
await orderCtrl.loadCompletedOrders();

// Load single order
await orderCtrl.loadOrderById(orderId: 3);
```

**Create/Manage Orders:**
```dart
// Create order
bool success = await orderCtrl.createOrder(
  items: [
    {'product_id': 1, 'quantity': 2},
    {'product_id': 3, 'quantity': 5},
  ],
  shippingAddress: 'Jl. Raya No. 123, Jakarta',
  notes: 'Kirim hati-hati',
);

// Update status (Admin/Seller only)
await orderCtrl.updateOrderStatus(
  orderId,
  OrderModel.statusShipped,
);

// Cancel order
await orderCtrl.cancelOrder(orderId);
```

**Reviews:**
```dart
// Load reviews for a product
await orderCtrl.loadProductReviews(productId: 5);

// Load product rating/statistics
await orderCtrl.loadProductRating(productId: 5);
ProductRatingModel? rating = orderCtrl.productRating;

// Submit review
bool success = await orderCtrl.submitReview(
  productId: 5,
  rating: 4,
  comment: "Produk bagus, pengiriman cepat!",
);

// Update review
await orderCtrl.updateReview(
  reviewId: 10,
  rating: 5,
  comment: "Sangat merekomendasikan!",
);

// Delete review
await orderCtrl.deleteReview(reviewId: 10);
```

---

### SellerController
Manages seller profile and statistics.

**Load Seller Data:**
```dart
final sellerCtrl = Provider.of<SellerController>(context, listen: false);

// Load all sellers (Admin/Pembeli)
await sellerCtrl.loadSellers();

// Load specific seller
await sellerCtrl.loadSellerById(sellerId: 2);

// Load current seller's profile (Petani/Seller only)
await sellerCtrl.loadProfile();

// Load seller statistics
await sellerCtrl.loadStatistics();

// Load all data at once
await sellerCtrl.loadAllData();
```

**Update Profile:**
```dart
bool success = await sellerCtrl.updateProfile(
  name: "Petani Subur",
  phone: "08123456789",
  address: "Desa Subur, Jawa Barat",
  shopName: "Toko Hasil Panen",
  shopDescription: "Hasil panen segar langsung dari kebun",
);
```

---

## 4. Data Models

### ProductModel
```dart
ProductModel(
  id: 1,
  sellerId: 5,
  categoryId: 2,
  name: "Beras Premium",
  description: "Beras pilihan...",
  price: 25000,
  stock: 100,
  unit: "kg",
  isActive: true,
)
```

### OrderModel
```dart
OrderModel(
  id: 1,
  buyerId: 3,
  orderNumber: "ORD-2024-001",
  totalPrice: 75000,
  status: "pending", // pending, confirmed, shipped, delivered, cancelled
  shippingAddress: "Jl. Raya No. 123",
  notes: "Tolong hati-hati",
  items: [/* OrderItemModel */],
)
```

### SellerModel
```dart
SellerModel(
  id: 5,
  name: "Petani Jaya",
  shopName: "Toko Panen",
  shopDescription: "...",
  isVerified: true,
  statistics: SellerStatisticsModel(
    totalProducts: 25,
    totalOrders: 150,
    totalRevenue: 5000000,
    averageRating: 4.5,
    totalReviews: 45,
  ),
)
```

---

## 5. Error Handling

Semua controller memiliki `lastError` getter:

```dart
Consumer<ProductController>(
  builder: (context, productCtrl, _) {
    if (productCtrl.lastError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(productCtrl.lastError!)),
      );
    }
    
    return SizedBox(); // UI
  },
)
```

---

## 6. API Endpoints Reference

| Operation | Endpoint | Method |
|-----------|----------|--------|
| Get All Products | `/api/products` | GET |
| Get Product | `/api/products/{id}` | GET |
| Create Product | `/api/products` | POST |
| Update Product | `/api/products/{id}` | PUT |
| Delete Product | `/api/products/{id}` | DELETE |
| Get Seller Products | `/api/sellers/{sellerId}/products` | GET |
| Get All Orders | `/api/orders` | GET |
| Create Order | `/api/orders` | POST |
| Update Order Status | `/api/orders/{id}/status` | PATCH |
| Cancel Order | `/api/orders/{id}/cancel` | POST |
| Get All Reviews | `/api/reviews` | GET |
| Create Review | `/api/reviews` | POST |
| Get Product Rating | `/api/reviews/products/{id}/rating` | GET |
| Get All Categories | `/api/categories` | GET |
| Get All Sellers | `/api/sellers` | GET |
| Get Seller Profile | `/api/sellers/profile` | GET |
| Update Seller Profile | `/api/sellers/profile` | PUT |
| Get Seller Stats | `/api/sellers/statistics` | GET |

---

## 7. Integration Checklist

### Pembeli (Buyer) Pages
- [ ] **Marketplace** - Use `ProductController.loadProducts()` + `loadCategories()`
- [ ] **Product Detail** - Use `ProductController.loadProductById()` + `OrderController.loadProductRating()`
- [ ] **Cart** - Maintain local cart list, create items array for `OrderController.createOrder()`
- [ ] **Checkout** - Use `OrderController.createOrder()`
- [ ] **Order History** - Use `OrderController.loadCompletedOrders()`
- [ ] **Order Tracking** - Use `OrderController.loadOrderById()` + listen for status updates
- [ ] **Review Page** - Use `OrderController.submitReview()`

### Petani (Farmer) Pages
- [ ] **Product Management** - Use `ProductController.loadSellerProducts()` + CRUD methods
- [ ] **Stock Management** - Use `ProductController.updateProduct()` for stock updates
- [ ] **Order Management** - Use `OrderController.loadOrders()` + status updates
- [ ] **Profile** - Use `SellerController.loadProfile()` + `updateProfile()`
- [ ] **Dashboard** - Use `SellerController.loadStatistics()`

### Admin Pages
- [ ] **Users Management** - Need `UserRepository` (planned)
- [ ] **Products Management** - Use `ProductController` + CRUD
- [ ] **Orders Management** - Use `OrderController.loadOrders()`
- [ ] **Categories Management** - Use `ProductController` category methods
- [ ] **Reports** - Use aggregated data from stats endpoints
- [ ] **Activity Logs** - Need `LogsRepository` (planned)

---

## 8. Common Patterns

### Infinite Scroll / Pagination
```dart
int currentPage = 1;

Future<void> loadMore() async {
  currentPage++;
  final moreProducts = await productCtrl.loadProducts(
    page: currentPage,
    limit: 20,
  );
  // Append to existing list
}
```

### Search
```dart
TextFormField(
  onChanged: (query) {
    productCtrl.loadProducts(search: query);
  },
)
```

### Filter by Category
```dart
DropdownButton(
  onChanged: (categoryId) {
    productCtrl.loadProducts(categoryId: categoryId);
  },
)
```

---

## 9. Next Steps

1. **Import controllers in main.dart** with MultiProvider setup
2. **Update pages** to use controllers instead of hardcoded data
3. **Add file upload support** for product images
4. **Create remaining repositories** (UserRepository, LogsRepository)
5. **Test API integration** with actual backend
6. **Handle connectivity** and offline mode
7. **Add caching** for frequently accessed data

---

## 10. Troubleshooting

**Error: "Gagal memuat produk"**
- Check API endpoint is correct in `ApiConstants`
- Verify token is valid (check `_token` in ApiService)
- Check backend is running on `http://127.0.0.1:8000`

**Reviews/Orders not showing**
- Ensure user is logged in (`AuthController.isLoggedIn`)
- Check permission level matches endpoint requirements

**Slow loading**
- Use pagination with `limit` parameter
- Load categories once and cache in controller
- Consider implementing local caching

---

*Last Updated: 2024*
