// views/waiter/waiter_tables_view.dart
import 'package:app_plaza_flutter/providers/table_providers.dart';
import 'package:app_plaza_flutter/themes/app_theme.dart';
import 'package:app_plaza_flutter/widgets/widgets.dart';
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
                return TableCard(table: table);
              },
            );
          },
        ),
      ),
    );
  }
}
