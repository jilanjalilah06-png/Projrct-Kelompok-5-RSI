import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/services/api_service.dart';
import 'presentation/controllers/auth_controller.dart';
import 'presentation/controllers/order_controller.dart';
import 'core/theme/app_theme.dart';
import 'presentation/pages/shared/landing_page.dart';
import 'presentation/pages/shared/role_selection_screen.dart';
import 'presentation/pages/admin/admin_main_layout.dart';
import 'presentation/pages/shared/responsive_user_layout.dart';
import 'presentation/pages/petani/petani_main_layout.dart';
import 'presentation/pages/shared/virtual_assistant_page.dart';
import 'presentation/widgets/agri_asisten_bot_widget.dart';

void main() {
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
      ],
      child: const AgriConnectApp(),
    ),
  );
}

class AgriConnectApp extends StatelessWidget {
  const AgriConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgriConnect Platform',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
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
              dashboardWidget = const RoleSelectionScreen();
          }

          return Scaffold(
            body: Stack(
              children: [
                dashboardWidget,
                Positioned(
                  bottom: 92,
                  right: 24,
                  child: AgriAsistenBotWidget(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            VirtualAssistantPage(roleContext: auth.currentRole),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
