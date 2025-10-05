import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/models/product.dart';
import '../../providers/sales_provider.dart';
import '../../providers/products_provider.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});
  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  Product? _selected;
  final _qtyCtrl = TextEditingController(text: '1');
  
  late Future<List<Product>> _productsFuture;
  List<Product> _allProducts = []; 

  @override
  void initState() {
    super.initState();
    _productsFuture = _loadProducts();
  }

  // Carga los productos y actualiza el estado local
  Future<List<Product>> _loadProducts() async {
    _allProducts = await context.read<ProductsProvider>().refresh();
    
    final availableProducts = _allProducts.where((p) => !_selectedProductIds().contains(p.id) && p.stock > 0).toList();
    
    // CORRECCIÓN del error de cast_from_null_always_fails y Null is not a subtype of Product
    if (_selected == null) {
      _selected = availableProducts.isNotEmpty ? availableProducts.first : null;
    }
    
    // CORRECCIÓN DE SINTAXIS: Uso de un operador Elvis (??) en lugar de un bloque if/null
    final selectedStock = _selected != null ? _getCurrentStock(_selected!) : 0;

    if (selectedStock == 0) {
        _selected = null;
    }
    
    if (_qtyCtrl.text.isEmpty || int.tryParse(_qtyCtrl.text) == 0) {
        _qtyCtrl.text = '1';
    }
    
    setState(() {});
    return _allProducts;
  }

  int _getCurrentStock(Product p) {
    try {
      return _allProducts.firstWhere((item) => item.id == p.id).stock;
    } catch (_) {
      return 0;
    }
  }

  Iterable<int?> _selectedProductIds() {
    return context.read<SalesProvider>().current.keys;
  }
  
  @override
  Widget build(BuildContext context) {
    context.watch<ProductsProvider>(); 
    final prov = context.watch<SalesProvider>();
    final current = prov.current;

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          const Text('Nueva Venta', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          FutureBuilder<List<Product>>(
            future: _productsFuture, 
            builder: (_, snap) {
              final allProducts = snap.data ?? [];
              
              final availableToSelect = allProducts
                  .where((p) => !_selectedProductIds().contains(p.id) && p.stock > 0)
                  .toList();
              
              if (availableToSelect.isEmpty && current.isEmpty) {
                return const Text('No hay productos disponibles o todos ya están en la venta.');
              }

              if (_selected == null || !availableToSelect.any((p) => p.id == _selected!.id)) {
                  _selected = availableToSelect.isNotEmpty ? availableToSelect.first : null;
              }
              
              final maxStock = _selected != null ? _getCurrentStock(_selected!) : 0;
              
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 4,
                    child: DropdownButtonFormField<Product>(
                      value: _selected,
                      items: availableToSelect.map((p) => DropdownMenuItem(value: p, child: Text('${p.name} (Stock: ${p.stock})'))).toList(),
                      onChanged: (p) => setState(() {
                        _selected = p;
                        _qtyCtrl.text = '1';
                      }),
                      decoration: const InputDecoration(labelText: 'Producto'),
                      // Asegura que el dropdown solo se muestre si hay elementos.
                      isExpanded: true,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _qtyCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Cant.',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: (int.tryParse(_qtyCtrl.text)??0) > maxStock ? Colors.red : Colors.grey),
                        ),
                      ),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (value) {
                        final enteredQty = int.tryParse(value) ?? 0;
                        if (enteredQty > maxStock) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('La cantidad máxima es $maxStock.')));
                          if (maxStock > 0) {
                              _qtyCtrl.text = maxStock.toString();
                          }
                        }
                        setState(() {});
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: (_selected == null || (int.tryParse(_qtyCtrl.text) ?? 0) <= 0 || (int.tryParse(_qtyCtrl.text) ?? 0) > maxStock) 
                      ? null 
                      : () {
                          final qty = int.tryParse(_qtyCtrl.text) ?? 0;
                          prov.addToCurrent(_selected!, qty);
                          _productsFuture = _loadProducts(); // Reasignar para forzar FutureBuilder a recargar
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
            final pStock = _getCurrentStock(p);

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
                      onPressed: () {
                        if (qty < pStock) {
                           prov.updateQty(e.key, qty + 1);
                        } else {
                           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Máximo stock disponible alcanzado')));
                        }
                      }),
                    IconButton(icon: const Icon(Icons.delete_outline),
                      onPressed: () {
                        prov.removeFromCurrent(e.key);
                        _productsFuture = _loadProducts(); // Reasignar para recargar disponibles
                      }),
                  ],
                ),
              ),
            );
          }).toList(),
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
                  _productsFuture = _loadProducts(); // Reasignar para recargar al finalizar la venta
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