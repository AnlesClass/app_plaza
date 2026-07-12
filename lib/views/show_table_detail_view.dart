import 'package:app_plaza_flutter/collections/routes_collections.dart';
import 'package:app_plaza_flutter/controllers/account_controller.dart';
import 'package:app_plaza_flutter/controllers/controllers.dart';
import 'package:app_plaza_flutter/models/order.dart';
import 'package:app_plaza_flutter/router/app_router.dart';
import 'package:app_plaza_flutter/themes/app_theme.dart';
import 'package:app_plaza_flutter/utils/order_states.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

class ShowTableDetailView extends ConsumerWidget {
  final String tableId;

  const ShowTableDetailView({super.key, required this.tableId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchamos de forma reactiva si la mesa tiene una orden hoy
    final orderAsync = ref.watch(activeOrderByTableProvider(tableId));

    return Scaffold(
      backgroundColor: AppTheme.quaternaryColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppTheme.quaternaryColor,
          ),
          onPressed: () => ref.read(appRouterProvider).pop(),
        ),
        title: const Text(
          "Detalle de Mesa",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: orderAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) {
          debugPrint(err.toString());
          return Center(child: Text("Error al cargar la mesa: $err"));
        },
        data: (activeOrder) {
          // Mesa Libre / Sin Órdenes activas
          if (activeOrder == null) {
            return _EmptyTableState(tableId: tableId);
          }

          // Mesa Ocupada / Consumo activo
          return _ActiveOrderState(order: activeOrder);
        },
      ),
    );
  }
}

// WIDGET NO REUTILIZABLE: Mesa Libre
class _EmptyTableState extends ConsumerWidget {
  final String tableId;
  const _EmptyTableState({required this.tableId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.table_restaurant_rounded,
              size: 100,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 20),
            const Text(
              "Mesa Disponible",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Esta mesa no registra consumos activos el día de hoy.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 35),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () {
                  // 1. Inicializamos el pedido en blanco en tu orderController
                  ref
                      .read(orderControllerProvider.notifier)
                      .setInitialTable(tableId);

                  // 2. Navegamos directo a la UI de selección de productos que armamos antes
                  ref
                      .read(appRouterProvider)
                      .push(RoutesCollections.localProductsMenu);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                ),
                icon: const Icon(
                  Icons.add_shopping_cart_rounded,
                  color: Colors.white,
                ),
                label: const Text(
                  "Abrir Nuevo Pedido",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// WIDGET NO REUTILIZABLE: Mesa Ocupada
class _ActiveOrderState extends ConsumerWidget {
  final Order order;
  const _ActiveOrderState({required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Convertimos el estado de la orden actual a nuestro enum OrderStates
    final currentStatus = order.status;

    // Bloquear si el pedido está listo para salir, ya se sirvió todo o se completó
    final bool isAdditionBlocked =
        currentStatus == OrderStates.served ||
        currentStatus == OrderStates.completed;

    return Column(
      children: [
        // Tarjeta de Estado de la Orden
        Container(
          width: double.infinity,
          color: Colors.white,
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Pedido #${order.uid.toString().substring(0, 5).toUpperCase()}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Estado: ${OrderStates.translate(currentStatus)}",
                    style: TextStyle(
                      color: currentStatus == OrderStates.ready
                          ? Colors.green[800]
                          : Colors.orange[800],
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              Text(
                "S/. ${order.total.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        ),

        const Padding(
          padding: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "CONSUMO ACTUAL",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ),
        ),

        // Lista de Platillos pedidos
        Expanded(
          child: ListView.builder(
            itemCount: order.items.length,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemBuilder: (context, index) {
              final item = order.items[index];
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  title: Text(
                    item.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primaryColor.withValues(
                      alpha: 0.1,
                    ),
                    child: Text(
                      "${item.quantity}x",
                      style: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  trailing: Text(
                    "S/. ${(item.price * item.quantity).toStringAsFixed(2)}",
                  ),
                ),
              );
            },
          ),
        ),

        // Sección Dinámica de Acciones Inferiores
        Container(
          padding: const EdgeInsets.all(20),
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Mostrar el botón de servir la mesa
              if (currentStatus == OrderStates.ready) ...[
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        ref
                            .read(orderControllerProvider.notifier)
                            .loadExistingOrder(order);
                        ref
                            .read(orderControllerProvider.notifier)
                            .updateOrderState(OrderStates.served);
                        await ref
                            .read(orderControllerProvider.notifier)
                            .saveOrderToFirebase();
                      } catch (e) {
                        debugPrint("Error al cambiar estado a servido: $e");
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(
                      Icons.room_service_rounded,
                      color: Colors.white,
                    ),
                    label: const Text(
                      "MARCAR COMO SERVIDO",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              Row(
                children: [
                  // Botón Adicionar: Se oculta/deshabilita si está en estados served o completed
                  if (!isAdditionBlocked) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ref
                              .read(orderControllerProvider.notifier)
                              .loadExistingOrder(order);
                          ref
                              .read(appRouterProvider)
                              .push(RoutesCollections.localProductsMenu);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          side: const BorderSide(color: AppTheme.primaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(
                          Icons.add_circle_outline_rounded,
                          color: AppTheme.primaryColor,
                        ),
                        label: const Text(
                          "Adicionar",
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                  ],

                  // Botón Pre-Cuenta: Toma el ancho completo si Adicionar está bloqueado
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: order.status != OrderStates.served
                          ? null
                          : () {
                              // Inicializamos el controlador de la orden actual
                              ref
                                  .read(accountControllerProvider.notifier)
                                  .initializeWithOrder(order);

                              // Navegar a la vista de pre-cuenta
                              ref
                                  .read(appRouterProvider)
                                  .push(RoutesCollections.preOrderAccount);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(
                        Icons.receipt_long_rounded,
                        color: Colors.white,
                      ),
                      label: const Text(
                        "Pre-Cuenta",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
