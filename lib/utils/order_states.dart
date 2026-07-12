// Lógica de estados de una 'Orden'
// 0: 'pending'; el pedido ha sido tomado en una mesa, esta se bloquea.
// 1: 'cooking'; al menos un plato ha sido servido (isServed: true), pero no todos.
// 2: 'ready'; todos los platos han sido cocinados, mas no servidos. No se ha pagado cuenta, mesa ocupada.
// 3: 'served'; todos los platos han sido servidos. Aún no se ha pagado la cuenta, mesa ocupada.
// 4: 'completed'; la cuenta ha sido pagada, la mesa vuelve a estar disponible.

enum OrderStates {
  pending('pending'),
  cooking('cooking'),
  ready('ready'),
  served('served'),
  completed('completed');

  // Propiedad que se guardará
  final String value;
  const OrderStates(this.value);

  /// Convierte el String de la BD de vuelta a un enum
  static OrderStates fromString(String status) {
    return OrderStates.values.firstWhere(
      (element) => element.value == status,
      orElse: () => OrderStates.pending, // Fallback
    );
  }

  static String translate(OrderStates translateState) {
    switch (translateState) {
      case OrderStates.pending:
        return 'Pendiente';
      case OrderStates.cooking:
        return 'Cocinando';
      case OrderStates.ready:
        return 'Listo';
      case OrderStates.served:
        return 'Servido';
      default:
        return 'Completado';
    }
  }
}
