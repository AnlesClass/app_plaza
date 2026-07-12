import 'package:app_plaza_flutter/controllers/controllers.dart';
import 'package:app_plaza_flutter/router/app_router.dart';
import 'package:app_plaza_flutter/utils/order_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_plaza_flutter/controllers/kitchen_controller.dart';
import 'package:app_plaza_flutter/themes/app_theme.dart';
import 'package:app_plaza_flutter/models/models.dart' as models;
import 'package:app_plaza_flutter/utils/utils.dart';

class ShowOrdersView extends ConsumerWidget {
  const ShowOrdersView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Órdenes que se visualizarán en la cocina (Pendientes y En preparación según tu nuevo Stream)
    final ordersAsync = ref.watch(kitchenOrdersStreamProvider);

    return Scaffold(
      backgroundColor: AppTheme.quaternaryColor,
      appBar: AppBar(
        // Volver a pantalla anterior
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => ref.read(appRouterProvider).pop(),
        ),
        title: const Text(
          "Panel de Órdenes",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
        actions: [
          // Visualizar la cantidad de pedidos faltantes
          ordersAsync.maybeWhen(
            data: (orders) => Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${orders.length} EN COLA",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: ordersAsync.when(
        // Cargando órdenes de pedidos
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor),
        ),
        // En caso de error en la carga de órdenes
        error: (err, _) => Center(
          child: Text(
            "Error en cocina: $err",
            style: const TextStyle(color: AppTheme.primaryColor),
          ),
        ),
        // Órdenes de pedidos cargadas correctamente
        data: (orders) {
          // En caso estén vacías
          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    size: 80,
                    color: AppTheme.tertiaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "¡Cocina limpia!\nNo hay pedidos pendientes.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.primaryColor.withValues(alpha: 0.6),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          // Lista Vertical Pura: Se adapta fluidamente al tamaño del contenido y dispositivos
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _KitchenTicketCard(order: orders[index]),
              );
            },
          );
        },
      ),
    );
  }
}

// --- Widget: Órden para cocina ---
class _KitchenTicketCard extends ConsumerWidget {
  final models.Order order;

  const _KitchenTicketCard({required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String timeAgo =
        (order.createdAt != null &&
            DateTime.now().difference(order.createdAt!).inMinutes > 1)
        ? "${DateTime.now().difference(order.createdAt!).inMinutes} min"
        : "Reciente";

    // Evaluamos si el pedido ya está en preparación activa (tiene al menos un plato ya servido/marcado)
    final bool isCooking = order.items.any((item) => item.isServed);

    return Card(
      color: Colors.white,
      elevation: 3,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isCooking
              ? Colors.orange.withValues(alpha: 0.4)
              : AppTheme.secondaryColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize:
            MainAxisSize.min, // Envoltura adaptativa exacta al contenido
        children: [
          // Encabezado: IDs de mesas, Tiempo de la orden (Cambia de color dinámicamente)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isCooking
                  ? Colors.orange.withValues(
                      alpha: 0.08,
                    ) // Tono cálido para órdenes en proceso
                  : AppTheme.secondaryColor.withValues(
                      alpha: 0.1,
                    ), // Tono por defecto para pendientes
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    // Nota: Quité el substring(1,4) original para evitar excepciones de rango si el ID de la mesa es corto.
                    "Mesa(s): ${order.tableIds.join(', ')}",
                    style: TextStyle(
                      color: isCooking
                          ? Colors.orange.shade900
                          : AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isCooking
                          ? Colors.orange.withValues(alpha: 0.5)
                          : AppTheme.secondaryColor.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    timeAgo,
                    style: TextStyle(
                      color: isCooking
                          ? Colors.orange.shade800
                          : AppTheme.secondaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Mesero encargado y tipo de orden
          Padding(
            padding: const EdgeInsets.only(
              left: 14,
              right: 14,
              top: 8,
              bottom: 4,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Mesero: ${order.username}",
                  style: TextStyle(
                    color: AppTheme.primaryColor.withValues(alpha: 0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (order.orderTypeName.isNotEmpty)
                  Text(
                    order.orderTypeName.toUpperCase(),
                    style: TextStyle(
                      color: isCooking
                          ? Colors.orange.shade800
                          : AppTheme.secondaryColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
          Divider(
            color: isCooking
                ? Colors.orange.withValues(alpha: 0.15)
                : AppTheme.secondaryColor.withValues(alpha: 0.2),
            height: 1,
          ),

          // Lista de productos interactiva por Checkbox
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: order.items.length,
            padding: const EdgeInsets.symmetric(vertical: 4),
            itemBuilder: (context, index) {
              final item = order.items[index];
              return CheckboxListTile(
                activeColor: AppTheme.tertiaryColor,
                controlAffinity: ListTileControlAffinity.leading,
                checkboxShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 0,
                ),
                dense: true,
                value: item.isServed,
                title: Row(
                  children: [
                    // Cantidad del producto
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: item.isServed
                            ? Colors.grey.withValues(alpha: 0.15)
                            : AppTheme.primaryColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "${item.quantity}x",
                        style: TextStyle(
                          color: item.isServed
                              ? Colors.grey
                              : AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          decoration: item.isServed
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Nombre del producto con tachado dinámico
                    Expanded(
                      child: Text(
                        item.name,
                        style: TextStyle(
                          color: item.isServed
                              ? Colors.grey.withValues(alpha: 0.7)
                              : AppTheme.primaryColor.withValues(alpha: 0.9),
                          fontSize: 15,
                          fontWeight: item.isServed
                              ? FontWeight.normal
                              : FontWeight.w500,
                          decoration: item.isServed
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
                onChanged: (bool? newValue) async {
                  if (newValue == null) return;

                  // Cargamos la orden correspondiente en el controlador e impactamos el plato individual
                  ref
                      .read(orderControllerProvider.notifier)
                      .loadExistingOrder(order);
                  await ref
                      .read(orderControllerProvider.notifier)
                      .updateItemState(item.productId, newValue);
                },
              );
            },
          ),

          // Botón Inferior: Despachar pedido completo
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () async {
                  // Consultamos providers: Alerta service, controlador y repositorio de mesas
                  final alertService = ref.read(alertServiceProvider);
                  final orderController = ref.read(
                    orderControllerProvider.notifier,
                  );

                  // Intentamos actualizar el estado de la orden.
                  try {
                    // Cargamos la orden correspondiente en el controlador
                    orderController.loadExistingOrder(order);
                    // Actualizamos el estado de la orden a lista de una vez.
                    orderController.updateOrderState(OrderStates.ready);
                    // Actualizamos el estado de todos los items de la orden a servidos.
                    orderController.updateAllItemsState(true);
                    // Guardamos la orden en Firestore.
                    await orderController.saveOrderToFirebase();
                    // Mostrar mensaje de éxito
                    alertService.showSnackbar(
                      "Pedido de la mesa ${order.tableIds.join(', ')} despachado.",
                    );
                  } catch (e) {
                    alertService.showSnackbar("Error al despachar pedido: $e.");
                    debugPrint(
                      "[ORDER REPOSITORY] Error al despachar pedido: $e}.",
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.tertiaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 1,
                ),
                icon: const Icon(Icons.done_all_rounded, color: Colors.white),
                label: const Text(
                  "DESPACHAR PEDIDO",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
