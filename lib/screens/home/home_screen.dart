import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../products/products_screen.dart';
import '../sales/sales_screen.dart';
import '../reports/reports_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;
  final _pages = const [
    ProductsScreen(),
    SalesScreen(),
    ReportsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().current;
    // CAMBIO: Mostrar el 'fullName' (Nombre de la Tienda) en la AppBar.
    return Scaffold(
      appBar: AppBar(
        title: Text(user?.fullName ?? 'TienditaMejorada'),
        actions: [
          IconButton(
              onPressed: () async {
                await context.read<AuthProvider>().logout();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
                }
              },
              icon: const Icon(Icons.logout))
        ],
      ),
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.inventory), label: 'Productos'),
          NavigationDestination(icon: Icon(Icons.point_of_sale), label: 'Ventas'),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Reportes'),
        ],
      ),
    );
  }
}