import 'package:app_plaza_flutter/models/models.dart' as models;
import 'package:app_plaza_flutter/models/payment_details.dart';

// Revisado: Está bien.
/// Modelo para registrar la transacción de cierre y facturación de una cuenta.
class AccountReceipt {
  final String? uid;
  final String? orderId;
  final String tableId;
  final double total;
  final double subtotal;
  final double igv;
  final List<PaymentDetails> payments;
  final DateTime? createdAt;

  const AccountReceipt({
    this.uid,
    this.orderId,
    this.tableId = '',
    this.total = 0,
    this.subtotal = 0,
    this.igv = 0,
    this.payments = const [],
    this.createdAt,
  });

  /// Factory simplificado para inicializar la cuenta directo desde el modelo 'Order'
  /// Realiza el cálculo matemático del IGV (10.5%) de forma automatizada.
  factory AccountReceipt.fromOrder({
    required models.Order order,
    required List<PaymentDetails> paymentsList,
  }) {
    final computedSubtotal = order.total / 1.105;
    final computedIgv = order.total - computedSubtotal;

    return AccountReceipt(
      orderId: order.uid!,
      tableId: order.tableIds.first,
      total: order.total,
      subtotal: computedSubtotal,
      igv: computedIgv,
      payments: paymentsList,
      createdAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'orderId': orderId,
      'tableId': tableId,
      'total': total,
      'subtotal': subtotal,
      'igv': igv,
      'payments': payments.map((x) => x.toMap()).toList(),
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory AccountReceipt.fromMap(Map<String, dynamic> map) {
    return AccountReceipt(
      uid: map['uid'] ?? '',
      orderId: map['orderId'] ?? '',
      tableId: map['tableId'] ?? '',
      total: (map['total'] as num).toDouble(),
      subtotal: (map['subtotal'] as num).toDouble(),
      igv: (map['igv'] as num).toDouble(),
      payments: List<PaymentDetails>.from(
        (map['payments'] as List<dynamic>).map(
          (x) => PaymentDetails.fromMap(x as Map<String, dynamic>),
        ),
      ),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
