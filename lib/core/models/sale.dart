class Sale {
// ... (Sale class sin cambios)
  final int? id;
  final DateTime createdAt;

  Sale({this.id, required this.createdAt});

  Map<String, dynamic> toMap() => {
        'id': id,
        'created_at': createdAt.toIso8601String(),
      };

  factory Sale.fromMap(Map<String, dynamic> m) => Sale(
        id: m['id'] as int?,
        createdAt: DateTime.parse(m['created_at'] as String),
      );
}

class SaleItem {
  final int? id;
  final int saleId;
  final int productId;
  final int quantity;
  final double unitPrice;
  // NUEVOS CAMPOS:
  final int? isReturned;
  final String? returnReason;
  final int? returnedQuantity;

  SaleItem({
    this.id,
    required this.saleId,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    // Inicialización de nuevos campos:
    this.isReturned,
    this.returnReason,
    this.returnedQuantity,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'sale_id': saleId,
        'product_id': productId,
        'quantity': quantity,
        'unit_price': unitPrice,
        'is_returned': isReturned,
        'return_reason': returnReason,
        'returned_quantity': returnedQuantity,
      };

  factory SaleItem.fromMap(Map<String, dynamic> m) => SaleItem(
        id: m['id'] as int?,
        saleId: m['sale_id'] as int,
        productId: m['product_id'] as int,
        quantity: m['quantity'] as int,
        unitPrice: (m['unit_price'] as num).toDouble(),
        // Lectura de nuevos campos:
        isReturned: m['is_returned'] as int?,
        returnReason: m['return_reason'] as String?,
        returnedQuantity: m['returned_quantity'] as int?,
      );
}