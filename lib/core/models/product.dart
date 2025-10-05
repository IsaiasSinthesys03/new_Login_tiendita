class Product {
  final int? id;
  final String name;
  final double unitPrice;
  final int stock;

  Product({
    this.id,
    required this.name,
    required this.unitPrice,
    required this.stock,
  });

  Product copyWith({int? id, String? name, double? unitPrice, int? stock}) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      unitPrice: unitPrice ?? this.unitPrice,
      stock: stock ?? this.stock,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'unit_price': unitPrice,
        'stock': stock,
      };

  factory Product.fromMap(Map<String, dynamic> m) => Product(
        id: m['id'] as int?,
        name: m['name'] as String,
        unitPrice: (m['unit_price'] as num).toDouble(),
        stock: m['stock'] as int,
      );

  // CORRECCIÓN: Sobrescribir == y hashCode para que la comparación
  // en DropdownButtonFormField se base en el 'id' del producto.
  @override
  bool operator ==(Object other) => 
      identical(this, other) || 
      other is Product && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}