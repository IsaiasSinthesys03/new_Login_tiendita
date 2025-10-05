import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/app_routes.dart';
import 'core/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/products_provider.dart';
import 'providers/sales_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TienditaApp());
}

class TienditaApp extends StatelessWidget {
  const TienditaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // CORRECCIÓN: Ya no se llama a .loadSessionIfAny().
        // Esto obliga al usuario a iniciar sesión cada vez que la app inicia.
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductsProvider()),
        ChangeNotifierProvider(create: (_) => SalesProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'TienditaMejorada',
        theme: buildAppTheme(),
        initialRoute: AppRoutes.splash,
        routes: {
          AppRoutes.splash: (c) => const _AuthGate(),
          AppRoutes.login: (c) => const LoginScreen(),
          AppRoutes.register: (c) => const RegisterScreen(),
          AppRoutes.home: (c) => const HomeScreen(),
        },
      ),
    );
  }
}

/// Decide la pantalla inicial según sesión en SharedPreferences
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (auth.current == null) {
      return const LoginScreen();
    } else {
      return const HomeScreen();
    }
  }
}