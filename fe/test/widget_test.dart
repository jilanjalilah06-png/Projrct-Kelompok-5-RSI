import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:fe/data/services/api_service.dart';
import 'package:fe/presentation/controllers/auth_controller.dart';
import 'package:fe/presentation/pages/shared/user_login_screen.dart';

void main() {
  testWidgets('AgriConnect shows UserLoginScreen on launch', (
    WidgetTester tester,
  ) async {
    final apiService = ApiService();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<ApiService>.value(value: apiService),
          ChangeNotifierProvider<AuthController>(
            create: (_) => AuthController(apiService),
          ),
        ],
        child: const MaterialApp(home: UserLoginScreen()),
      ),
    );

    // Verifikasi teks selamat datang muncul
    expect(find.text('Agriconnect'), findsOneWidget);
    expect(find.text('Terhubung untuk Pertanian yang Lebih Baik'), findsOneWidget);
  });
}
