import 'package:app_plaza_flutter/utils/order_states.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_plaza_flutter/models/models.dart';

/// Modelo principal que mapea el documento del pedido completo en Firestore.
class Order {
  final String? uid;
  final String userId;
  final String username;
  final String orderTypeName;
  final List<String> tableIds;
  final String localId;
  final OrderStates status;
  final DateTime? createdAt;
  final List<OrderItem> items;
  final double total;

  /// Obtener la cantidad total de items de una orden
  int get totalItems => items.fold(0, (int sum, item) => sum + item.quantity);

  const Order({
    this.uid,
    required this.userId,
    required this.username,
    required this.orderTypeName,
    required this.tableIds,
    required this.localId,
    required this.status,
    this.createdAt,
    required this.items,
    required this.total,
  });

  /// Convierte el Order de Firestore a un Order de Flutter
  factory Order.fromMap(Map<String, dynamic> map, String id) {
    // Mapeamos de forma segura la lista de mapas internos a objetos OrderItem
    final List<dynamic> itemsRaw = map['items'] ?? [];
    final List<OrderItem> orderItems = itemsRaw
        .map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
        .toList();

    // Convertir el Timestamp nativo de Firebase a DateTime de Dart
    final Timestamp? timestamp = map['createdAt'] as Timestamp?;

    return Order(
      uid: id,
      userId: map['userId'] ?? '',
      username: map['username'] ?? '',
      orderTypeName: map['orderTypeName'] ?? '',
      tableIds: List<String>.from(map['tableIds'] ?? []),
      localId: map['localId'] ?? '',
      status: OrderStates.fromString(
        map['status'] ?? OrderStates.pending.value,
      ),
      createdAt: timestamp?.toDate(),
      items: orderItems,
      total: (map['total'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Convierte el objeto Order completo a un mapa JSON para actualizarlo o crearlo en la nube.
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'username': username,
      'orderTypeName': orderTypeName,
      'tableIds': tableIds,
      'localId': localId,
      'status': status.value,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'items': items.map((item) => item.toMap()).toList(),
      'total': total,
    };
  }
}
