import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/repositories/sales_repository.dart';
import '../../providers/sales_provider.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});
  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final _repo = SalesRepository();
  late Future<(List<Map<String, dynamic>>, double)> _future;

  @override
  void initState() {
    super.initState();
    _future = _repo.dailyReport(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    // refrescar cuando se hace una venta
    context.watch<SalesProvider>();

    return Scaffold(
      body: FutureBuilder<(List<Map<String, dynamic>>, double)>(
        future: _repo.dailyReport(DateTime.now()),
        builder: (_, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final (rows, total) = snap.data!;
          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              const Text('Reporte Diario', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (rows.isEmpty) const Text('Aún no hay ventas hoy.'),
              ...rows.map((r) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.receipt_long),
                      title: Text(r['name'] as String),
                      subtitle: Text('Cant: ${r['quantity']} • \$${(r['unit_price'] as num).toDouble().toStringAsFixed(2)}'),
                      trailing: Text(
                        (DateTime.parse(r['created_at'] as String)).toLocal().toString().substring(11, 16),
                      ),
                    ),
                  )),
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
