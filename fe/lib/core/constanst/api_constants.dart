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
  // -------------------------------------------------------
  static const String _configuredHost = String.fromEnvironment('API_HOST');

  static String get _host {
    if (_configuredHost.isNotEmpty) {
      return _configuredHost;
    }

    if (kIsWeb) {
      final uri = Uri.base;
      if (uri.host.isNotEmpty &&
          uri.host != 'localhost' &&
          uri.host != '127.0.0.1') {
        return '${uri.scheme}://${uri.host}:8000';
      }
      return 'http://localhost:8000';
    }

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    }

    return 'http://localhost:8000';
  }

  static String get baseUrl => '$_host/api';
  static String get storageUrl => '$_host/storage';

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

  // Reviews Endpoints
  static const String reviewsEndpoint = '/reviews';

  // Sellers Endpoints
  static const String sellersEndpoint = '/sellers';
  static const String sellerProfileEndpoint = '/sellers/profile';
  static const String sellerStatisticsEndpoint = '/sellers/statistics';

  // Legacy/Deprecated
  static const String commoditiesEndpoint = '/commodities';
  static const String logsEndpoint = '/activity-logs';
  static const String chatbotMessageEndpoint = '/chatbot/message';
}
