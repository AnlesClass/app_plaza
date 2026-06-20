// views/local_products_view.dart
import 'package:app_plaza_flutter/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_plaza_flutter/providers/product_providers.dart';
import 'package:app_plaza_flutter/models/local_product_with_details.dart';

class LocalProductsView extends ConsumerWidget {
  const LocalProductsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(localProductsWithDetailsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos del Local'),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(localProductsWithDetailsStreamProvider);
            },
          ),
        ],
      ),
      body: productsAsync.when(
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Cargando productos...'),
            ],
          ),
        ),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: ${error.toString()}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(localProductsWithDetailsStreamProvider);
                },
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (products) {
          if (products.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No hay productos asignados a este local',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Asigna productos desde el panel de administración',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(localProductsWithDetailsStreamProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final item = products[index];
                return _ProductCard(item: item);
              },
            ),
          );
        },
      ),
    );
  }
}

// Widget para tarjeta de producto
class _ProductCard extends StatelessWidget {
  final LocalProductWithDetails item;

  const _ProductCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: item.isBlocked ? Colors.grey.shade50 : Colors.white,
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: item.isBlocked
                  ? Colors.grey.shade300
                  : AppTheme.secondaryColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              item.isBlocked ? Icons.block : Icons.fastfood,
              color: item.isBlocked ? Colors.grey : AppTheme.quaternaryColor,
              size: 30,
            ),
          ),
          title: Text(
            item.name,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              decoration: item.isBlocked ? TextDecoration.lineThrough : null,
              color: item.isBlocked ? Colors.grey : Colors.black87,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                'Precio: S/.${item.price.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: item.isBlocked ? Colors.grey : Colors.green.shade700,
                ),
              ),
              if (item.isBlocked && item.blockLimit.isAfter(DateTime.now()))
                Text(
                  'Bloqueado hasta: ${_formatDate(item.blockLimit)}',
                  style: const TextStyle(fontSize: 12, color: Colors.red),
                ),
            ],
          ),
          trailing: item.isBlocked
              ? const Icon(Icons.block_flipped, color: Colors.red)
              : const Icon(Icons.check_circle, color: Colors.green),
          onTap: () {
            _showProductDetails(context, item);
          },
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }

  void _showProductDetails(BuildContext context, LocalProductWithDetails item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Precio: \$${item.price.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            Text('Estado: ${item.isBlocked ? "Bloqueado" : "Disponible"}'),
            if (item.isBlocked && item.blockLimit.isAfter(DateTime.now()))
              Text('Bloqueado hasta: ${_formatDate(item.blockLimit)}'),
            const Divider(),
            Text('ID Producto: ${item.product.uid}'),
            Text('Categoría ID: ${item.idCategory}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
