import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/products_provider.dart';
import '../../widgets/ui.dart';

class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({super.key});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _name = TextEditingController();
  final _price = TextEditingController();
  final _qty = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16, right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16, top: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Agregar Producto', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          gap(12),
          TextField(controller: _name, decoration: appInput('Nombre', Icons.label)),
          gap(12),
          TextField(controller: _price, keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: appInput('Precio Unitario', Icons.attach_money)),
          gap(12),
          TextField(controller: _qty, keyboardType: TextInputType.number,
            decoration: appInput('Cantidad (stock inicial)', Icons.calculate)),
          gap(16),
          FilledButton.icon(
            icon: const Icon(Icons.save),
            label: const Text('Guardar'),
            onPressed: () async {
              final name = _name.text.trim();
              final price = double.tryParse(_price.text.trim());
              final qty = int.tryParse(_qty.text.trim());
              if (name.isEmpty || price == null || qty == null || qty <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Datos inválidos')));
                return;
              }
              final err = await context.read<ProductsProvider>().addSmart(name, price, qty);
              if (err != null) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
                }
              } else {
                if (context.mounted) Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }
}
