import 'package:app_plaza_flutter/collections/firestore_collections.dart';
import 'package:app_plaza_flutter/controllers/order_controller.dart';
import 'package:app_plaza_flutter/models/models.dart' as models;
import 'package:app_plaza_flutter/models/payment_details.dart';
import 'package:app_plaza_flutter/providers/firebase_providers.dart';
import 'package:app_plaza_flutter/utils/order_states.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccountController extends Notifier<models.AccountReceipt> {
  late final FirebaseFirestore firestore;

  // Propiedades de estado de la interfaz de usuario (UI State)
  bool isLoading = false;
  String? errorMessage;
  bool isSuccess = false;

  // Almacenamos la orden original para la persistencia final
  models.Order? currentOrder;

  @override
  models.AccountReceipt build() {
    firestore = ref.read(firestoreInstanceProvider);
    _resetUIState();
    return const models.AccountReceipt();
  }

  void _resetUIState() {
    isLoading = false;
    errorMessage = null;
    isSuccess = false;
  }

  // === GETTERS PARA LA VISTA (Reemplazan lo que hacía AccountState) ===
  double get totalOrder => state.total;
  double get subtotal => state.subtotal;
  double get igv => state.igv;
  List<PaymentDetails> get payments => state.payments;

  double get totalPaid {
    return state.payments.fold(0.0, (suma, item) => suma + item.amount);
  }

  double get pendingAmount {
    final diff = totalOrder - totalPaid;
    return diff < 0 ? 0.0 : diff;
  }

  bool get isAccountSettled {
    if (currentOrder == null) return false;
    return pendingAmount.toStringAsFixed(2) == "0.00";
  }

  /// Vincula la orden activa a la que se le generará el cálculo de pre-cuenta
  void initializeWithOrder(models.Order order) {
    currentOrder = order;
    _resetUIState();

    // Generamos el estado inicial usando el factory del modelo
    state = models.AccountReceipt.fromOrder(
      order: order,
      paymentsList: const [],
    );
  }

  /// Añade un nuevo desglose de pago a la lista local
  void addPayment(PaymentDetails payment) {
    if (currentOrder == null) return;
    errorMessage = null;

    // Verificación de seguridad para evitar sobrepagos accidentales
    if (payment.amount > pendingAmount + 0.01) {
      errorMessage = "El monto ingresado supera el saldo pendiente de la mesa.";
      ref.notifyListeners(); // Forzamos el redibujado de la UI para mostrar el error
      return;
    }

    // Usamos el copyWith de tu modelo o creamos una nueva instancia con la lista actualizada
    state = models.AccountReceipt(
      uid: state.uid,
      orderId: state.orderId,
      tableId: state.tableId,
      total: state.total,
      subtotal: state.subtotal,
      igv: state.igv,
      payments: [...state.payments, payment],
      createdAt: state.createdAt,
    );
  }

  /// Permite retirar un pago parcial de la grilla antes de cerrar caja
  void removePaymentAt(int index) {
    final updatedPayments = List<PaymentDetails>.from(state.payments)
      ..removeAt(index);

    state = models.AccountReceipt(
      uid: state.uid,
      orderId: state.orderId,
      tableId: state.tableId,
      total: state.total,
      subtotal: state.subtotal,
      igv: state.igv,
      payments: updatedPayments,
      createdAt: state.createdAt,
    );
  }

  /// Operación atómica y transaccional para cerrar la mesa en Cloud Firestore
  Future<void> submitAndCloseAccount() async {
    if (currentOrder == null || !isAccountSettled) return;

    isLoading = true;
    errorMessage = null;
    ref.notifyListeners();

    try {
      final batch = firestore.batch();
      final receiptRef = firestore
          .collection(FirestoreCollections.receipts)
          .doc();

      // Creamos el objeto final con los datos definitivos y el ID de Firestore
      final receipt = models.AccountReceipt(
        uid: receiptRef.id,
        orderId: state.orderId,
        tableId: state.tableId,
        total: state.total,
        subtotal: state.subtotal,
        igv: state.igv,
        payments: state.payments,
        createdAt: DateTime.now(),
      );

      // Guardar recibo
      batch.set(receiptRef, receipt.toMap());

      // Modificar estado de la orden original
      final orderRef = firestore.collection('orders').doc(currentOrder!.uid);
      batch.update(orderRef, {
        'status': OrderStates.completed.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      // Liberar mesas
      if (currentOrder!.tableIds.isNotEmpty) {
        // Accedemos al notifier de órdenes y desmarcamos la selección de todas las mesas asociadas
        ref
            .read(orderControllerProvider.notifier)
            .updateAlltablesSelection(currentOrder!.tableIds, false);
      }

      isLoading = false;
      isSuccess = true;
      ref.notifyListeners();
    } catch (e) {
      debugPrint("Error crítico al procesar el cierre de cuenta: $e");
      isLoading = false;
      errorMessage =
          "Error en el servidor: No se pudo registrar el pago. Intente de nuevo.";
      ref.notifyListeners();
    }
  }
}

// Provider global sin .autoDispose para que la orden no se limpie durante la animación de navegación
final accountControllerProvider =
    NotifierProvider<AccountController, models.AccountReceipt>(() {
      return AccountController();
    });
