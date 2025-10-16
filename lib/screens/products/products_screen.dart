import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/products_provider.dart';
import 'product_form_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});
  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ProductsProvider>().refresh());
  }

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductsProvider>().items;

    return Scaffold(
      body: products.isEmpty
          ? const Center(child: Text('Sin productos. Agrega con el botón +'))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: products.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final p = products[i];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.inventory_2),
                    title: Text(p.name),
                    subtitle: Text('Stock: ${p.stock} • \$${p.unitPrice.toStringAsFixed(2)}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        await showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          useSafeArea: true,
                          builder: (_) => ProductFormScreen(product: p),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            builder: (_) => const ProductFormScreen(),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Producto'),
      ),
    );
  }
}
