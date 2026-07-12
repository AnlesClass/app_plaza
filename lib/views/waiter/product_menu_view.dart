import 'package:app_plaza_flutter/repositories/local_product_repository.dart';
import 'package:app_plaza_flutter/router/app_router.dart';
import 'package:app_plaza_flutter/utils/alert_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_plaza_flutter/controllers/order_controller.dart';
import 'package:app_plaza_flutter/themes/app_theme.dart';
import 'package:app_plaza_flutter/models/models.dart' as models;

class ProductMenuView extends ConsumerWidget {
  const ProductMenuView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchamos el estado actual de la orden (build inicial)
    final currentOrder = ref.watch(orderControllerProvider);
    // Obtiene los productos basados en el local de manera asíncrona y en streaming
    final productsAsync = ref.watch(
      streamProductsByLocalProvider(currentOrder.localId),
    );

    return Scaffold(
      backgroundColor: AppTheme.quaternaryColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () {
            // Intentar volver a la vista anterior
            final appRouter = ref.read(appRouterProvider);
            if (appRouter.canPop()) {
              appRouter.pop();
            }
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AppBar: Título
            const Text(
              "Tomar Pedido",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            // AppBar: Subtítulo
            Text(
              "Mesas asignadas: ${currentOrder.tableIds.join(', ')}",
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Stack(
        children: [
          // Lista de Productos
          productsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) =>
                Center(child: Text("Error al cargar menú: $err")),
            data: (localProducts) {
              return ListView.builder(
                padding: const EdgeInsets.only(
                  top: 16,
                  left: 16,
                  right: 16,
                  bottom:
                      100, // Margen inferior extra para que el tique flotante no tape los platos
                ),
                itemCount: localProducts.length,
                itemBuilder: (context, index) {
                  final localProduct = localProducts[index];

                  // Verificamos si este producto ya está en el carrito para saber la cantidad
                  final cartItem = currentOrder.items.firstWhere(
                    (item) => item.productId == localProduct.uid,
                    orElse: () => const models.OrderItem(
                      productId: '',
                      name: '',
                      price: 0,
                      quantity: 0,
                      isServed: false,
                    ),
                  );

                  return _ProductMenuCard(
                    name: localProduct.productName,
                    price: localProduct.price,
                    category: localProduct.categoryName,
                    quantityInCart: cartItem.quantity,
                    onAdd: () {
                      ref
                          .read(orderControllerProvider.notifier)
                          .addProduct(
                            localProduct.uid!,
                            localProduct.productName,
                            localProduct.price,
                          );
                    },
                    onRemove: () {
                      ref
                          .read(orderControllerProvider.notifier)
                          .removeProduct(localProduct.uid!);
                    },
                  );
                },
              );
            },
          ),

          // Barra Flotante Inferior, no aparece si no hay items seleccionados.
          if (currentOrder.items.isNotEmpty)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: _FloatingOrderSummaryBar(
                total: currentOrder.total,
                itemCount: currentOrder.totalItems,
                onConfirm: () async {
                  // Consultamos los providers: Controlador de orden y AlertService.
                  final orderController = ref.read(
                    orderControllerProvider.notifier,
                  );
                  final alertService = ref.read(alertServiceProvider);
                  final appRouter = ref.read(appRouterProvider);

                  try {
                    // Actualizamos el estado de la(s) mesa(s) seleccionada(s) a ocupada.
                    await orderController.updateAlltablesSelection(
                      currentOrder.tableIds,
                      true,
                    );

                    // Guardamos la orden de forma nativa en Firestore.
                    await orderController.saveOrderToFirebase();

                    // Enviar mensaje de éxito
                    alertService.showSnackbar(
                      "¡Pedido enviado a cocina con éxito!",
                    );
                    // Volver a la vista anterior.
                    if (appRouter.canPop()) {
                      appRouter.pop();
                    }
                  } catch (e) {
                    alertService.showSnackbar("Error al enviar pedido: $e");
                  }
                },
              ),
            ),
        ],
      ),
    );
  }
}

// Widget: Tarjeta de Productos
class _ProductMenuCard extends StatelessWidget {
  final String name;
  final double price;
  final String category;
  final int quantityInCart;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _ProductMenuCard({
    required this.name,
    required this.price,
    required this.category,
    required this.quantityInCart,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasItems = quantityInCart > 0;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Detalles del Plato
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category,
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "S/. ${price.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),

            // Selector de Cantidad Dinámico
            Container(
              decoration: BoxDecoration(
                color: hasItems
                    ? AppTheme.primaryColor.withValues(alpha: 0.1)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  if (hasItems)
                    IconButton(
                      icon: const Icon(
                        Icons.remove_circle_outline,
                        color: AppTheme.primaryColor,
                      ),
                      onPressed: onRemove,
                    ),
                  if (hasItems)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Text(
                        '$quantityInCart',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  IconButton(
                    icon: Icon(
                      Icons.add_circle,
                      color: hasItems
                          ? AppTheme.primaryColor
                          : Colors.grey[600],
                    ),
                    onPressed: onAdd,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget: Barra Inferior Flotante
class _FloatingOrderSummaryBar extends StatelessWidget {
  final double total;
  final int itemCount;
  final VoidCallback onConfirm;

  const _FloatingOrderSummaryBar({
    required this.total,
    required this.itemCount,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      color: AppTheme.primaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Contador y Total acumulado
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "$itemCount ${itemCount == 1 ? 'producto' : 'productos'}",
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  "S/. ${total.toStringAsFixed(2)}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),

            // Botón de Envío
            ElevatedButton.icon(
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.send_rounded, size: 18),
              label: const Text(
                "Enviar Pedido",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
