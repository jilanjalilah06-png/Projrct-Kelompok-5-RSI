import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:fe/data/services/api_service.dart';
import 'package:fe/presentation/controllers/auth_controller.dart';
import 'package:fe/presentation/pages/shared/role_selection_screen.dart';

void main() {
  testWidgets('AgriConnect shows RoleSelectionScreen on launch', (
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
        child: const MaterialApp(home: RoleSelectionScreen()),
      ),
    );

    // Verifikasi teks selamat datang muncul
    expect(find.text('Selamat Datang di AgriConnect'), findsOneWidget);
    // Verifikasi dua pilihan role muncul
    expect(find.text('Portal Petani & Pembeli'), findsOneWidget);
    expect(find.text('Console Dekstop Admin'), findsOneWidget);
  });
}
