/// Modelo que representa un artículo individual dentro de un pedido.
class OrderItem {
  final String productId;
  final String name;
  final double price;
  final int quantity;
  final bool isServed;

  const OrderItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.isServed,
  });

  /// Convierte un mapa de Firestore en un objeto OrderItem.
  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      quantity: map['quantity'] ?? 0,
      isServed: map['isServed'] ?? false,
    );
  }

  /// Convierte este objeto OrderItem a un mapa listo para guardarse en Firestore.
  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'isServed': isServed,
    };
  }
}
