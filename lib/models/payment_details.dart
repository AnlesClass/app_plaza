// Revisado: Está bien.
/// Modelo para los detalles de pago dentro de una cuenta
class PaymentDetails {
  final String method; // 'Yape', 'Plin', 'Efectivo', 'Tarjeta'
  final double amount;
  final String? reference; // Para operaciones electrónicas (Yape/Plin/Tarjeta)
  final double? received; // Solo Efectivo: Dinero entregado por el cliente
  final double? change; // Solo Efectivo: Vuelto devuelto

  const PaymentDetails({
    required this.method,
    required this.amount,
    this.reference,
    this.received,
    this.change,
  });

  Map<String, dynamic> toMap() {
    return {
      'method': method,
      'amount': amount,
      'reference': reference,
      'received': received,
      'change': change,
    };
  }

  factory PaymentDetails.fromMap(Map<String, dynamic> map) {
    return PaymentDetails(
      method: map['method'] ?? '',
      amount: (map['amount'] as num).toDouble(),
      reference: map['reference'],
      received: (map['received'] as num?)?.toDouble(),
      change: (map['change'] as num?)?.toDouble(),
    );
  }
}
