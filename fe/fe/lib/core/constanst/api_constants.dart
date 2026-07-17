

class ApiConstants {
  // -------------------------------------------------------
  // KONFIGURASI HOST BACKEND
  //
  // DEFAULT: Railway Cloud (berlaku untuk semua platform)
  //   https://agriconnect-production-7011.up.railway.app
  //
  // Override via --dart-define jika perlu dev lokal:
  //   flutter run --dart-define=API_HOST=http://10.0.2.2:8000  (emulator)
  //   flutter run --dart-define=API_HOST=http://192.168.x.x:8000  (device fisik)
  // -------------------------------------------------------

  // URL Railway production — dipakai di semua platform secara default
  static const String _railwayHost =
      'https://agriconnect-production-7011.up.railway.app';

  // Bisa di-override via --dart-define=API_HOST=...
  static const String _configuredHost = String.fromEnvironment('API_HOST');

  static String _normalizeHost(String host) {
    return host.trim().replaceAll(RegExp(r'/+$'), '');
  }

  // Selalu Railway kecuali ada override eksplisit
  static String get _defaultHost => _railwayHost;

  static String get _host {
    if (_configuredHost.isNotEmpty) {
      return _normalizeHost(_configuredHost);
    }
    return _normalizeHost(_defaultHost);
  }

  static String get baseUrl => '$_host/api';
  static String get storageUrl => '$_host/api/file';

  // Auth Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String logoutEndpoint = '/auth/logout';
  static const String refreshEndpoint = '/auth/refresh';
  static const String meEndpoint = '/auth/me';
  static const String profileEndpoint = '/auth/profile';

  // Products Endpoints
  static const String productsEndpoint = '/products';
  static const String sellerProductsEndpoint = '/sellers';

  // Categories Endpoints
  static const String categoriesEndpoint = '/categories';

  // Orders Endpoints
  static const String ordersEndpoint = '/orders';

  // Planting Activities Endpoints
  static const String plantingActivitiesEndpoint = '/planting-activities';
  static const String plantingActivitiesSyncEndpoint =
      '/planting-activities/sync';

  // Farmer Lands Endpoints
  static const String farmerLandsEndpoint = '/farmer-lands';

  // Planting Schedules Endpoints
  static const String plantingSchedulesEndpoint = '/planting-schedules';

  // Cart Endpoints
  static const String cartEndpoint = '/cart';
  static const String cartItemsEndpoint = '/cart/items';

  // Reviews Endpoints
  static const String reviewsEndpoint = '/reviews';

  // Sellers Endpoints
  static const String sellersEndpoint = '/sellers';
  static const String sellerProfileEndpoint = '/sellers/profile';
  static const String sellerStatisticsEndpoint = '/sellers/statistics';

  // Admin Endpoints
  static const String adminStatisticsEndpoint = '/admin/statistics';
  static const String adminUsersEndpoint = '/admin/users';
  static const String adminReferencePricesEndpoint = '/admin/reference-prices';
  static const String adminUpdateReferencePriceEndpoint = '/admin/reference-prices/update';

  // Legacy/Deprecated
  static const String commoditiesEndpoint = '/commodities';
  static const String logsEndpoint = '/activity-logs';
  static const String chatbotMessageEndpoint = '/chatbot/message';
}
