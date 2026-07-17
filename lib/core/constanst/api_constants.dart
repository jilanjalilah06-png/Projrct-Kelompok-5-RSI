import 'package:flutter/foundation.dart';

class ApiConstants {
  // -------------------------------------------------------
  // PENTING: Ganti sesuai environment Anda:
  //
  // OPSI 1 - DESKTOP/WEB (Windows, macOS, Linux):
  //   static const String _host = 'http://127.0.0.1:8000';
  //
  // OPSI 2 - ANDROID EMULATOR:
  //   static const String _host = 'http://10.0.2.2:8000';
  //
  // OPSI 3 - iOS SIMULATOR:
  //   static const String _host = 'http://127.0.0.1:8000';
  //
  // OPSI 4 - PHYSICAL DEVICE (Ganti <PC-IP-ANDA> dengan IP PC):
  //   static const String _host = 'http://<PC-IP-ANDA>:8000';
  //   Contoh: 'http://192.168.1.5:8000'
  //
  // OPSI 5 - FLUTTER WEB:
  //   static const String _host = 'http://127.0.0.1:8000';
  //
  // OPSI 6 - NGROK TUNNELING UNTUK MOBILE:
  //   flutter run --dart-define=API_HOST=https://domain-ngrok-anda.ngrok-free.dev
  // -------------------------------------------------------
  static const String _configuredHost = String.fromEnvironment('API_HOST');
  static const String _mobileNgrokHost =
      'https://eliminate-ominous-bronco.ngrok-free.dev';

  static String _normalizeHost(String host) {
    return host.trim().replaceAll(RegExp(r'/+$'), '');
  }

  static String get _defaultHost {
    if (kIsWeb) return 'http://127.0.0.1:8000';

    return switch (defaultTargetPlatform) {
      TargetPlatform.android => _mobileNgrokHost,
      _ => 'http://127.0.0.1:8000',
    };
  }

  static String get _host {
    if (_configuredHost.isNotEmpty) {
      final isAndroid =
          !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
      final pointsToDeviceItself =
          _configuredHost.contains('127.0.0.1') ||
          _configuredHost.contains('localhost');
      if (isAndroid && pointsToDeviceItself) return _defaultHost;

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
