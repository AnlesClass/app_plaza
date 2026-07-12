import 'package:app_plaza_flutter/collections/firestore_collections.dart';
import 'package:app_plaza_flutter/collections/order_types.dart';
import 'package:app_plaza_flutter/providers/providers.dart';
import 'package:app_plaza_flutter/repositories/table_repository.dart';
import 'package:app_plaza_flutter/utils/order_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_plaza_flutter/models/models.dart' as models;

/// Proveedor global para gestionar la creación de un nuevo pedido en caliente.
final orderControllerProvider = NotifierProvider<OrderController, models.Order>(
  () {
    return OrderController();
  },
);

class OrderController extends Notifier<models.Order> {
  /// Estado inicial por defecto de la orden en construcción.
  @override
  models.Order build() {
    // Obtenemos los datos del usuario logueado actualmente para amarrarlos al pedido.
    final sessionAsync = ref.watch(sessionDataProvider);
    final currentUser = sessionAsync.value?.user;
    final currentLocalId = currentUser?.idLocal ?? '';

    // Devolvemos un estado "Default" del modelo 'Order'.
    return models.Order(
      userId: currentUser?.uid ?? '',
      username: currentUser?.name ?? 'Mesero Anónimo',
      orderTypeName: OrderTypes.diningRoom,
      tableIds: [],
      localId: currentLocalId,
      status: OrderStates.pending,
      items: [],
      total: 0.0,
    );
  }

  /// Configurar o inicializar una orden asignando una mesa.
  void setInitialTable(String tableId) {
    state = models.Order(
      userId: state.userId,
      username: state.username,
      orderTypeName: state.orderTypeName,
      tableIds: [tableId], // Agregamos la mesa desde donde se aperturó el flujo
      localId: state.localId,
      status: state.status,
      items: [],
      total: 0.0,
    );
  }

  /// Añade una mesa adicional al pedido (para varias mesas).
  void setTableSelection(String tableId) {
    final currentTables = List<String>.from(state.tableIds);

    // Si la mesa ya está asignada la quitamos; caso contrario, la agregamos.
    if (currentTables.contains(tableId)) {
      if (currentTables.length > 1) currentTables.remove(tableId);
    } else {
      currentTables.add(tableId);
    }

    state = _copyWith(tableIds: currentTables);
  }

  /// Agrega un producto al carrito o incrementa su cantidad si ya existía.
  void addProduct(String productId, String name, double price) {
    // Copia la lista de items desde el estado
    final currentItems = List<models.OrderItem>.from(state.items);

    // Buscar si el producto ya existe en el pedido actual
    final existingIndex = currentItems.indexWhere(
      (item) => item.productId == productId,
    );

    if (existingIndex >= 0) {
      // Si ya existe, incrementamos su cantidad en 1
      final item = currentItems[existingIndex];
      currentItems[existingIndex] = models.OrderItem(
        productId: item.productId,
        name: item.name,
        price: item.price,
        quantity: item.quantity + 1,
        isServed: item.isServed,
      );
    } else {
      // Si es nuevo, lo añadimos a la lista con cantidad 1
      currentItems.add(
        models.OrderItem(
          productId: productId,
          name: name,
          price: price,
          quantity: 1,
          isServed: false,
        ),
      );
    }

    state = _copyWith(
      items: currentItems,
      total: _calculateTotal(currentItems),
    );
  }

  /// Actualiza el estado de la mesa cargada
  void updateOrderState(OrderStates orderState) {
    // Actualizamos el estado de la orden
    state = _copyWith(status: orderState);
  }

  /// Actualiza el estado de un item en la orden a servido o no servido basado en el identificador del producto.
  Future<void> updateItemState(String productId, bool isServed) async {
    state = _copyWith(
      items: state.items
          .map(
            (item) => item.productId == productId
                ? models.OrderItem(
                    productId: item.productId,
                    name: item.name,
                    price: item.price,
                    quantity: item.quantity,
                    isServed: isServed,
                  )
                : item,
          )
          .toList(),
    );

    if (_isOrderComplete()) {
      debugPrint("[ORDER_CONTROLLER] La orden está completa.");
      // Actualizamos el estado de la orden a listo para servir.
      updateOrderState(OrderStates.ready);
    } else {
      debugPrint("[ORDER_CONTROLLER] La orden está siendo cocinada.");
      // Actualizamos el estado de la orden a cocinando.
      updateOrderState(OrderStates.cooking);
    }

    // Guardamos la orden en Firestore.
    await saveOrderToFirebase();
  }

  /// Actualiza el estado de todos los items de la orden a servidos o no servidos.
  void updateAllItemsState(bool isServed) {
    state = _copyWith(
      items: state.items
          .map(
            (item) => models.OrderItem(
              productId: item.productId,
              name: item.name,
              price: item.price,
              quantity: item.quantity,
              isServed: isServed,
            ),
          )
          .toList(),
    );
  }

  /// Actualiza el estado de todas las mesas seleccionadas a libres u ocupadas.
  Future<void> updateAlltablesSelection(
    List<String> tableIds,
    bool isOccupied,
  ) async {
    final tableRepository = ref.read(tableRepositoryProvider);
    debugPrint(
      "[ORDER_CONTROLLER] Actualizando el estado de las mesas: $tableIds a $isOccupied",
    );
    await tableRepository.updateTablesOccupation(tableIds, isOccupied);
  }

  /// Reduce la cantidad de un producto o lo elimina si llega a 0.
  void removeProduct(String productId) {
    final currentItems = List<models.OrderItem>.from(state.items);
    final existingIndex = currentItems.indexWhere(
      (item) => item.productId == productId,
    );

    if (existingIndex < 0) return; // No existe, no hacemos nada

    final item = currentItems[existingIndex];

    if (item.quantity > 1) {
      // Reducimos cantidad
      currentItems[existingIndex] = models.OrderItem(
        productId: item.productId,
        name: item.name,
        price: item.price,
        quantity: item.quantity - 1,
        isServed: item.isServed,
      );
    } else {
      // Si la cantidad era 1, lo borramos por completo de la lista
      currentItems.removeAt(existingIndex);
    }

    state = _copyWith(
      items: currentItems,
      total: _calculateTotal(currentItems),
    );
  }

  /// Limpiar la orden actual para iniciar una en blanco.
  void clearOrder() {
    ref.invalidateSelf(); // Resetear al estado inicial
  }

  /// Subir el perdido a una colección 'Orders' en Firestore.
  /// TODO: Es probable que deba existir un repositorio para esto.
  Future<void> saveOrderToFirebase() async {
    // Lanzar excepciones por casos especiales
    if (state.tableIds.isEmpty) {
      throw Exception("Debes asignar al menos una mesa");
    }
    if (state.items.isEmpty) {
      throw Exception("No puedes registrar un pedido sin productos");
    }

    // Llamamos al singleton de Firestore
    final firestore = ref.read(firestoreInstanceProvider);

    // Generamos un documento nuevo en la colección de órdenes
    final docRef = state.uid != null
        ? firestore
              .collection(FirestoreCollections.orders)
              .doc(state.uid) // En caso exista
        : firestore
              .collection(FirestoreCollections.orders)
              .doc(); // En caso sea nuevo

    // Guardamos el pedido del cliente pasando el mapa con información de la orden
    await docRef.set(state.toMap());

    // Limpiamos el estado de la orden temporal
    clearOrder();
  }

  /// Función para cargar una orden, cuando se quiere consultar la orden actual o tal.
  void loadExistingOrder(models.Order order) {
    state = order;
  }

  // MÉTODOS PRIVADOS

  /// Calcula de forma precisa el monto total de la orden.
  double _calculateTotal(List<models.OrderItem> items) {
    return items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  /// Función para mutar la orden (solo mesas, items, precio total)
  models.Order _copyWith({
    List<String>? tableIds,
    List<models.OrderItem>? items,
    double? total,
    OrderStates? status,
  }) {
    return models.Order(
      uid: state.uid,
      userId: state.userId,
      username: state.username,
      orderTypeName: state.orderTypeName,
      tableIds: tableIds ?? state.tableIds,
      localId: state.localId,
      status: status ?? state.status,
      createdAt: state.createdAt,
      items: items ?? state.items,
      total: total ?? state.total,
    );
  }

  /// Función para comprobar si el pedido está completo.
  bool _isOrderComplete() {
    return state.items.every((item) => item.isServed);
  }
}
