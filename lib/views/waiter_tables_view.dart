// views/waiter/waiter_tables_view.dart
import 'package:app_plaza_flutter/models/models.dart';
import 'package:app_plaza_flutter/providers/table_providers.dart';
import 'package:app_plaza_flutter/themes/app_theme.dart';
// ignore: unused_import
import 'package:app_plaza_flutter/widgets/widgets.dart'; // TODO: Esto lo usaré al cambiar los widgets a su carpeta corres.
import 'package:flutter/material.dart' hide Table;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WaiterTablesView extends ConsumerStatefulWidget {
  const WaiterTablesView({super.key});

  @override
  ConsumerState<WaiterTablesView> createState() => _WaiterTablesViewState();
}

class _WaiterTablesViewState extends ConsumerState<WaiterTablesView> {
  @override
  Widget build(BuildContext context) {
    final tablesAsync = ref.watch(tablesByLocalStreamProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            // TODO: Abrir drawer
          },
        ),
        title: const Text(
          "Mesas - Salón",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        elevation: 2,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Forzar refresco del stream (opcional, el stream ya es en tiempo real)
          ref.invalidate(tablesByLocalStreamProvider);
        },
        child: tablesAsync.when(
          loading: () => const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Cargando mesas..."),
              ],
            ),
          ),
          error: (error, stackTrace) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  "Error al cargar mesas",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    ref.invalidate(tablesByLocalStreamProvider);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                  ),
                  child: const Text("Reintentar"),
                ),
              ],
            ),
          ),
          data: (tables) {
            if (tables.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.table_restaurant_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      "No hay mesas registradas",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Contacta al administrador para agregar mesas",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Columnas
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1, // Rectángulo vertical
              ),
              itemCount: tables.length,
              itemBuilder: (context, index) {
                final table = tables[index];
                return _TableCard(table: table);
              },
            );
          },
        ),
      ),
    );
  }
}

// Widget para cada tarjeta de mesa
class _TableCard extends StatelessWidget {
  final Table table;

  const _TableCard({required this.table});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color borderColor;
    Color textColor;

    if (table.isEnable) {
      backgroundColor = Colors.grey[200]!;
      borderColor = Colors.grey[400]!;
      textColor = Colors.grey[600]!;
    } else if (table.isOccupied) {
      backgroundColor = Colors.red[50]!;
      borderColor = Colors.red[400]!;
      textColor = Colors.red[700]!;
    } else {
      backgroundColor = Colors.green[50]!;
      borderColor = Colors.green[400]!;
      textColor = Colors.green[700]!;
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor, width: 2),
      ),
      color: backgroundColor,
      child: InkWell(
        onTap: table.isEnable
            ? null
            : () {
                // TODO: Navegar a la vista de pedido de la mesa
                if (table.isOccupied) {
                  // TODO: Ver pedido actual
                } else {
                  // TODO: Crear nuevo pedido
                }
              },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                table.isOccupied
                    ? Icons.restaurant_outlined
                    : Icons.table_restaurant_outlined,
                size: 48,
                color: textColor,
              ),
              const SizedBox(height: 12),
              Text(
                table.name,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.people_outline,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "${table.capacity} personas",
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: textColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  table.isOccupied ? "Ocupado" : "Libre",
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
