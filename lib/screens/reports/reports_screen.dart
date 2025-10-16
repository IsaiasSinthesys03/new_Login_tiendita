import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../../data/repositories/sales_repository.dart';
import '../../providers/sales_provider.dart';
import '../../providers/products_provider.dart'; 

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});
  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final _repo = SalesRepository();
  late Future<(List<Map<String, dynamic>> rows, double total)> _future;

  @override
  void initState() {
    super.initState();
    _refreshReport();
  }
  
  void _refreshReport() {
    setState(() {
      _future = _repo.dailyReport(DateTime.now());
    });
  }

  // Muestra el diálogo de devolución
  Future<void> _showReturnDialog(int saleItemId, String productName, double price, int maxQty) async {
    final qtyCtrl = TextEditingController(text: '1');
    String? reason;
    String customReason = '';
    
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateSB) {
          final currentQty = int.tryParse(qtyCtrl.text) ?? 0;
          final maxAllowedToReturn = maxQty; // Cantidad máxima que se puede devolver (vendido - devuelto)
          final isValidQty = currentQty > 0 && currentQty <= maxAllowedToReturn;
          final isCustomReason = reason == 'Otro';

          return AlertDialog(
            title: const Text('Confirmar Devolución'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Producto: "$productName" (Max. a devolver: $maxAllowedToReturn)'),
                  const SizedBox(height: 16),
                  
                  // Campo de Cantidad a Devolver
                  TextField(
                    controller: qtyCtrl,
                    keyboardType: TextInputType.number, // CORRECCIÓN: Uso correcto de TextInputType
                    decoration: InputDecoration(
                      labelText: 'Cantidad a devolver',
                      hintText: 'Máx. $maxAllowedToReturn',
                      errorText: isValidQty ? null : 'Cantidad inválida. Debe ser entre 1 y $maxAllowedToReturn.',
                    ),
                    onChanged: (value) => setStateSB(() {
                      // Limitar el input al máximo stock
                      final enteredQty = int.tryParse(value) ?? 0;
                      if (enteredQty > maxAllowedToReturn && maxAllowedToReturn > 0) {
                          qtyCtrl.text = maxAllowedToReturn.toString();
                          qtyCtrl.selection = TextSelection.fromPosition(TextPosition(offset: qtyCtrl.text.length));
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('La cantidad máxima a devolver es $maxAllowedToReturn.')));
                      }
                    }),
                  ),
                  
                  const SizedBox(height: 16),
                  const Text('Razón:', style: TextStyle(fontWeight: FontWeight.bold)),
                  
                  // Opciones de Razón
                  ListTile(
                    title: const Text('No deseado'),
                    leading: Radio<String>(
                      value: 'No deseado',
                      groupValue: reason,
                      onChanged: (val) => setStateSB(() => reason = val),
                    ),
                  ),
                  ListTile(
                    title: const Text('Defectuoso'),
                    leading: Radio<String>(
                      value: 'Defectuoso',
                      groupValue: reason,
                      onChanged: (val) => setStateSB(() => reason = val),
                    ),
                  ),
                  ListTile(
                    title: const Text('Otro (Especifique)'),
                    leading: Radio<String>(
                      value: 'Otro',
                      groupValue: reason,
                      onChanged: (val) => setStateSB(() => reason = val),
                    ),
                  ),
                  
                  // Campo para Razón Personalizada
                  if (isCustomReason)
                    TextField(
                      onChanged: (val) => customReason = val,
                      decoration: const InputDecoration(
                        labelText: 'Razón personalizada',
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
              FilledButton(
                onPressed: isValidQty && reason != null && (!isCustomReason || customReason.isNotEmpty)
                    ? () {
                        final finalReason = isCustomReason && customReason.isNotEmpty ? customReason : reason!;
                        Navigator.pop(ctx);
                        _handleReturn(saleItemId, finalReason, currentQty);
                      }
                    : null,
                child: const Text('Confirmar Devolución'),
              ),
            ],
          );
        },
      ),
    );
  }

  // Procesa la devolución y actualiza la UI
  Future<void> _handleReturn(int saleItemId, String reason, int quantity) async {
    final err = await _repo.recordPartialReturn(saleItemId: saleItemId, reason: reason, quantity: quantity);

    if (context.mounted) {
      if (err != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al devolver: $err')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Devolución registrada')));
        _refreshReport();
        context.read<ProductsProvider>().refresh(); 
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<SalesProvider>();
    context.watch<ProductsProvider>();

    return Scaffold(
      body: FutureBuilder<(List<Map<String, dynamic>> rows, double total)>(
        future: _future,
        builder: (_, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final (rows, total) = snap.data!;
          
          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              const Text('Reporte Diario', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (rows.isEmpty) const Text('Aún no hay ventas hoy.'),
              ...rows.map((r) {
                final saleItemId = r['id'] as int;
                final qtySold = r['quantity'] as int;
                final qtyReturned = (r['returned_quantity'] as int);
                final qtyNet = qtySold - qtyReturned;
                final isFullyReturned = qtyNet <= 0;
                final returnReason = r['return_reason'] as String?;
                final productName = r['name'] as String;
                final price = (r['unit_price'] as num).toDouble();

                return Card(
                  color: isFullyReturned ? Colors.red.shade50 : null,
                  child: ListTile(
                    leading: isFullyReturned ? const Icon(Icons.undo, color: Colors.red) : const Icon(Icons.receipt_long),
                    title: Text(productName, style: TextStyle(
                      decoration: isFullyReturned ? TextDecoration.lineThrough : null,
                    )),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Cant: ${isFullyReturned ? 0 : qtyNet} vendida / $qtyReturned devuelta • \$${price.toStringAsFixed(2)}'),
                        if (qtyReturned > 0)
                          Text('Razón: ${returnReason ?? 'Desconocida'}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                    trailing: isFullyReturned
                        ? Text(
                            (DateTime.parse(r['created_at'] as String)).toLocal().toString().substring(11, 16),
                            style: const TextStyle(color: Colors.red),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                (DateTime.parse(r['created_at'] as String)).toLocal().toString().substring(11, 16),
                              ),
                              GestureDetector(
                                onTap: () => _showReturnDialog(saleItemId, productName, price, qtyNet),
                                child: Lottie.asset('assets/Trash can.json', width: 30, height: 30),
                              ),
                            ],
                          ),
                  ),
                );
              }),
              const Divider(),
              Align(
                alignment: Alignment.centerRight,
                child: Text('Total del día: \$${total.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }
}