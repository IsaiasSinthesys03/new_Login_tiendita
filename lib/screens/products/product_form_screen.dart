import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../../core/models/product.dart';
import '../../providers/products_provider.dart';
import '../../widgets/ui.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;
  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _name = TextEditingController();
  final _price = TextEditingController();
  final _qty = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _name.text = widget.product!.name;
      _price.text = widget.product!.unitPrice.toString();
      _qty.text = widget.product!.stock.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;
    return Padding(
      padding: EdgeInsets.only(
        left: 16, right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16, top: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(isEdit ? 'Editar Producto' : 'Agregar Producto', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          gap(12),
          TextField(controller: _name, decoration: appInput('Nombre', Icons.label)),
          gap(12),
          TextField(controller: _price, keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: appInput('Precio Unitario', Icons.attach_money)),
          gap(12),
          TextField(controller: _qty, keyboardType: TextInputType.number,
            decoration: appInput('Cantidad (stock)', Icons.calculate)),
          gap(16),
          Row(
            children: [
              if (isEdit)
                GestureDetector(
                  onTap: () async {
                    final confirm = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Confirmar'),
                        content: const Text('¿Seguro que quieres eliminar este producto?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      final err = await context.read<ProductsProvider>().delete(widget.product!.id!);
                      if (!context.mounted) return;
                      if (err != null) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
                      } else {
                        Navigator.pop(context);
                      }
                    }
                  },
                  child: Lottie.asset('assets/Trash can.json', width: 40, height: 40),
                ),
              const Spacer(),
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
                  if (isEdit) {
                    final updatedProduct = widget.product!.copyWith(
                      name: name,
                      unitPrice: price,
                      stock: qty,
                    );
                    final err = await context.read<ProductsProvider>().update(updatedProduct);
                    if (err != null) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
                      }
                    } else {
                      if (context.mounted) Navigator.pop(context);
                    }
                  } else {
                    final err = await context.read<ProductsProvider>().addSmart(name, price, qty);
                    if (err != null) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
                      }
                    } else {
                      if (context.mounted) Navigator.pop(context);
                    }
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
