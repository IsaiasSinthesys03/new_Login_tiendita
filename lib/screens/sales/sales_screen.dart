import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../providers/sales_provider.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});
  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  Product? _selected;
  final _qtyCtrl = TextEditingController(text: '1');

  Future<void> _reloadProducts() async {
    final available = await context.read<SalesProvider>().availableProducts();
    setState(() {
      _selected = available.isNotEmpty ? available.first : null;
    });
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(_reloadProducts);
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<SalesProvider>();
    final current = prov.current;

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          const Text('Nueva Venta', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          FutureBuilder<List<Product>>(
            future: context.read<SalesProvider>().availableProducts(),
            builder: (_, snap) {
              final list = snap.data ?? [];
              if (list.isEmpty) {
                return const Text('No hay productos disponibles o todos ya están en la venta.');
              }
              _selected ??= list.first;
              return Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<Product>(
                      value: _selected,
                      items: list.map((p) => DropdownMenuItem(value: p, child: Text('${p.name} (\$${p.unitPrice})'))).toList(),
                      onChanged: (p) => setState(() => _selected = p),
                      decoration: const InputDecoration(labelText: 'Producto'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _qtyCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Cant.'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () {
                      final qty = int.tryParse(_qtyCtrl.text) ?? 0;
                      if (_selected == null || qty <= 0) return;
                      prov.addToCurrent(_selected!, qty);
                      _qtyCtrl.text = '1';
                      _reloadProducts();
                    },
                    child: const Text('Añadir'),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          const Text('Productos en la venta'),
          const SizedBox(height: 8),
          ...current.entries.map((e) {
            final p = e.value.$1; final qty = e.value.$2;
            return Card(
              child: ListTile(
                title: Text(p.name),
                subtitle: Text('Cant: $qty • \$${p.unitPrice.toStringAsFixed(2)}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () {
                        if (qty > 1) prov.updateQty(e.key, qty - 1);
                      }),
                    IconButton(icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => prov.updateQty(e.key, qty + 1)),
                    IconButton(icon: const Icon(Icons.delete_outline),
                      onPressed: () => prov.removeFromCurrent(e.key)),
                  ],
                ),
              ),
            );
          }),
          const Divider(),
          Align(
            alignment: Alignment.centerRight,
            child: Text('Total: \$${prov.total.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            icon: const Icon(Icons.check),
            label: const Text('Vender'),
            onPressed: () async {
              final err = await prov.commitSale();
              if (context.mounted) {
                if (err != null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Venta registrada')));
                  setState(() {}); // refrescar widgets
                }
              }
            },
          ),
          const SizedBox(height: 16),
          const Text(
              'Nota: Un producto no aparece dos veces en la misma transacción; para aumentar cantidad usa +/-.')
        ],
      ),
    );
  }
}
