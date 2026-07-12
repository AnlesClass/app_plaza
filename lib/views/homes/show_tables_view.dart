// views/waiter/waiter_tables_view.dart
import 'package:app_plaza_flutter/collections/routes_collections.dart'; // Asegúrate de que apunte a tus rutas
import 'package:app_plaza_flutter/providers/providers.dart';
import 'package:app_plaza_flutter/repositories/auth_repository.dart';
import 'package:app_plaza_flutter/router/app_router.dart';
import 'package:app_plaza_flutter/themes/app_theme.dart';
import 'package:app_plaza_flutter/widgets/widgets.dart';
import 'package:flutter/material.dart' hide Table;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShowTablesView extends ConsumerStatefulWidget {
  const ShowTablesView({super.key});

  @override
  ConsumerState<ShowTablesView> createState() => _WaiterTablesViewState();
}

class _WaiterTablesViewState extends ConsumerState<ShowTablesView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final tablesAsync = ref.watch(tablesByLocalStreamProvider);
    final appRouter = ref.read(appRouterProvider);

    // Recuperamos los datos de sesión para personalizar el Drawer según el usuario logueado
    final sessionAsync = ref.watch(sessionDataProvider);
    final user = sessionAsync.value?.user;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.quaternaryColor, // Tu fondo crema suave
      appBar: AppBar(
        // Cambiamos el leading dinámicamente
        leading: appRouter.canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: () => appRouter.pop(),
              )
            : IconButton(
                icon: const Icon(Icons.menu_rounded, color: Colors.white),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
        title: const Text(
          "Mesas - Salón",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        elevation: 2,
      ),

      drawer: Drawer(
        backgroundColor: AppTheme.quaternaryColor,
        child: Column(
          children: [
            // Encabezado del Drawer usando los colores del AppTheme
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: AppTheme.primaryColor),
              currentAccountPicture: CircleAvatar(
                backgroundColor: AppTheme.secondaryColor,
                child: Text(
                  user?.name.substring(0, 1).toUpperCase() ?? "U",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              accountName: Text(
                user?.name ?? "Usuario",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              accountEmail: const Text("generic_email@gmail.com"),
            ),

            // Opción: Menú de Productos de Local
            ListTile(
              leading: const Icon(
                Icons.restaurant_menu_rounded,
                color: AppTheme.primaryColor,
              ),
              title: const Text(
                "Productos del Local",
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Navigator.pop(context); // Cierra el drawer
                appRouter.push(RoutesCollections.localProducts);
              },
            ),

            // Opción: Visualizar Órdenes del día
            ListTile(
              leading: const Icon(
                Icons.receipt_long_rounded,
                color: AppTheme.primaryColor,
              ),
              title: const Text(
                "Historial de Órdenes",
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                appRouter.push(RoutesCollections.showOrders);
              },
            ),

            const Spacer(), // Empuja el botón de cierre de sesión al fondo
            Divider(color: AppTheme.secondaryColor.withValues(alpha: 0.3)),

            // Opción: Cierre de Sesión
            ListTile(
              leading: const Icon(
                Icons.logout_rounded,
                color: Colors.redAccent,
              ),
              title: const Text(
                "Cerrar Sesión",
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                // Llama al notifier de autenticación o repositorio para limpiar credenciales
                await ref.read(authRepositoryProvider).signOut();
                // El router o listener de auth debería redirigir de forma automática al Loginview
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),

      body: RefreshIndicator(
        color: AppTheme.primaryColor,
        onRefresh: () async {
          ref.invalidate(tablesByLocalStreamProvider);
        },
        child: tablesAsync.when(
          loading: () => const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppTheme.primaryColor),
                SizedBox(height: 16),
                Text(
                  "Cargando mesas...",
                  style: TextStyle(color: AppTheme.primaryColor),
                ),
              ],
            ),
          ),
          error: (error, stackTrace) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  "Error al cargar mesas",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.primaryColor.withValues(alpha: 0.6),
                  ),
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
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.table_restaurant_outlined,
                      size: 64,
                      color: AppTheme.secondaryColor.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "No hay mesas registradas",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Contacta al administrador para agregar mesas",
                      style: TextStyle(
                        color: AppTheme.primaryColor.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
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
