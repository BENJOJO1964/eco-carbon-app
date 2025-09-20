import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/carbon_provider.dart';
import 'services/auto_detection_manager.dart';
import 'services/invoice_carrier_service.dart';
import 'services/payment_binding_service.dart';
import 'services/camera_scanning_service.dart';
import 'services/smart_auto_detection_service.dart';
import 'services/permission_service.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(const EcoApp());
}

class EcoApp extends StatelessWidget {
  const EcoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => CarbonProvider()),
          ChangeNotifierProvider(create: (_) => AutoDetectionManager()),
          ChangeNotifierProvider(create: (_) => InvoiceCarrierService()),
          ChangeNotifierProvider(create: (_) => PaymentBindingService()),
          ChangeNotifierProvider(create: (_) => CameraScanningService()),
          ChangeNotifierProvider(create: (_) => SmartAutoDetectionService()),
          ChangeNotifierProvider(create: (_) => PermissionService()),
        ],
      child: MaterialApp(
        title: 'Eco - 碳足跡追蹤',
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('zh', 'TW'), // 繁體中文
          Locale('zh', 'CN'), // 簡體中文
          Locale('en'),       // 英文
        ],
        locale: const Locale('zh', 'TW'), // 預設繁體中文
        theme: ThemeData(
          primarySwatch: Colors.green,
          primaryColor: Colors.green,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.green, width: 2),
            ),
          ),
        ),
        home: const AuthWrapper(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // 初始化认证状态
        if (authProvider.user == null && !authProvider.isLoading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            authProvider.initialize();
          });
        }

        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.eco,
                    size: 80,
                    color: Colors.green,
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Eco',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  SizedBox(height: 16),
                  CircularProgressIndicator(color: Colors.green),
                  SizedBox(height: 16),
                  Text(
                    '正在加载...',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (authProvider.user != null) {
          return const HomeScreen();
        } else {
          return const AuthScreen();
        }
      },
    );
  }
}