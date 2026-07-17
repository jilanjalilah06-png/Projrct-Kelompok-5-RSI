import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/services/api_service.dart';
import 'presentation/controllers/auth_controller.dart';
import 'presentation/controllers/cart_controller.dart';
import 'presentation/controllers/admin_controller.dart';
import 'presentation/controllers/order_controller.dart';
import 'presentation/controllers/product_controller.dart';
import 'presentation/controllers/seller_controller.dart';
import 'core/theme/app_theme.dart';
import 'presentation/pages/shared/landing_page.dart';
import 'presentation/pages/shared/user_login_screen.dart';
import 'presentation/pages/admin/admin_main_layout.dart';
import 'presentation/pages/shared/responsive_user_layout.dart';
import 'presentation/pages/petani/petani_main_layout.dart';
import 'presentation/controllers/theme_controller.dart';
import 'presentation/controllers/language_controller.dart';
import 'presentation/controllers/planting_schedule_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final apiService = ApiService();
  
  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>.value(value: apiService),
        ChangeNotifierProvider<AuthController>(
          create: (_) => AuthController(apiService),
        ),
        ChangeNotifierProvider<OrderController>(
          create: (_) => OrderController(apiService),
        ),
        ChangeNotifierProvider(
          create: (context) => CartController(context.read<ApiService>()),
        ),
        ChangeNotifierProvider<ProductController>(
          create: (_) => ProductController(apiService),
        ),
        ChangeNotifierProvider<SellerController>(
          create: (_) => SellerController(apiService),
        ),
        ChangeNotifierProvider<AdminController>(
          create: (_) => AdminController(apiService),
        ),
        ChangeNotifierProvider<ThemeController>(
          create: (_) => ThemeController(prefs),
        ),
        ChangeNotifierProvider<LanguageController>(
          create: (_) => LanguageController(prefs),
        ),
        ChangeNotifierProvider<PlantingScheduleController>(
          create: (_) => PlantingScheduleController(apiService),
        ),
      ],
      child: const AgriConnectApp(),
    ),
  );
}

class AgriConnectApp extends StatelessWidget {
  const AgriConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeController>(
      builder: (context, themeCtrl, _) {
        return MaterialApp(
          title: 'AgriConnect Platform',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeCtrl.themeMode,
          home: Consumer<AuthController>(
            builder: (context, auth, _) {
              if (!auth.isLoggedIn) {
                return const LandingPage();
              }

              Widget dashboardWidget;
              switch (auth.currentRole) {
                case 'Admin':
                  dashboardWidget = const AdminMainLayout();
                  break;
                case 'Petani':
                  dashboardWidget = const PetaniMainLayout();
                  break;
                case 'Pembeli':
                  dashboardWidget = const ResponsiveUserLayout();
                  break;
                default:
                  dashboardWidget = const UserLoginScreen();
              }

              return Scaffold(body: dashboardWidget);
            },
          ),
        );
      },
    );
  }
}
