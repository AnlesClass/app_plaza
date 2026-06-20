import 'package:app_plaza_flutter/collections/routes_collections.dart';
import 'package:app_plaza_flutter/repositories/repositories.dart';
import 'package:app_plaza_flutter/router/app_router.dart';
import 'package:app_plaza_flutter/themes/app_theme.dart';
import 'package:app_plaza_flutter/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeAdminView extends ConsumerWidget {
  const HomeAdminView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Panel de Administración',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const AdminDrawer(),
      body: const DashboardPlaceholder(),
    );
  }
}

/// Drawer del Administrador.
/// Elemento: NO REUTILIZABLE
/// Centraliza los accesos a las rutas del sistema que requieren privilegios de admin.
class AdminDrawer extends ConsumerWidget {
  const AdminDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Creamos una lista con los diferentes nombres y rutas.
    final menuItems = [
      const _DrawerItemData(
        title: "Registrar Usuario",
        icon: Icons.person_add_alt_1_rounded,
        route: RoutesCollections.register,
      ),
      const _DrawerItemData(
        title: "Crear Locales",
        icon: Icons.storefront_rounded,
        route: RoutesCollections.createLocal,
      ),
      const _DrawerItemData(
        title: "Crear Categorías",
        icon: Icons.category_rounded,
        route: RoutesCollections.createCategory,
      ),
      const _DrawerItemData(
        title: "Crear Productos",
        icon: Icons.inventory_2_rounded,
        route: RoutesCollections.createProduct,
      ),
      const _DrawerItemData(
        title: "Asignar Productos",
        icon: Icons.assignment_turned_in_rounded,
        route: RoutesCollections.assignProduct,
      ),
      const _DrawerItemData(
        title: "Crear Mesas",
        icon: Icons.table_restaurant_rounded,
        route: RoutesCollections.createTable,
      ),
      const _DrawerItemData(
        title: "Gestionar Roles",
        icon: Icons.admin_panel_settings_rounded,
        route: RoutesCollections.createRole,
      ),
    ];

    return Drawer(
      backgroundColor: AppTheme.quaternaryColor,
      semanticLabel: "Abrir menú de navegación",
      child: Column(
        children: [
          // Encabezado del Drawer
          const _AdminDrawerHeader(),
          // Botones: Navegación a diferentes pantallas
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              itemCount: menuItems.length,
              separatorBuilder: (_, _) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final item = menuItems[index];
                return _DrawerTile(
                  title: item.title,
                  icon: item.icon,
                  onTap: () {
                    // Cerar Drawer
                    Navigator.of(context).pop();

                    // Leemos provider y navegamos
                    ref.read(appRouterProvider).push(item.route);
                  },
                );
              },
            ),
          ),
          // Botón de cerrar sesión
          _DrawerTile(
            title: "Cerrar Sesión",
            icon: Icons.logout,
            onTap: () {
              ref.read(authRepositoryProvider).signOut();
            },
          ),
          // Marca de Versión
          const AppVersionLabel(),
        ],
      ),
    );
  }
}

/// Encabezado para el Drawer
/// Elemento: NO REUTILIZABLE
class _AdminDrawerHeader extends StatelessWidget {
  const _AdminDrawerHeader();

  @override
  Widget build(BuildContext context) {
    return DrawerHeader(
      decoration: const BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Center(
        child: Row(
          children: [
            // Ícono: Administrador
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppTheme.tertiaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.analytics_rounded,
                color: AppTheme.primaryColor,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),

            // Columna: Datos de Sesión
            const Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Panel General",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Rol: Administrador",
                    style: TextStyle(
                      color: AppTheme.quaternaryColor,
                      fontSize: 13,
                    ),
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

/// Elemento individual de Drawer
/// Elemento: REUTILIZABLE
class _DrawerTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _DrawerTile({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppTheme.secondaryColor,
        size: 20,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      hoverColor: AppTheme.secondaryColor.withValues(alpha: 0.08),
      onTap: onTap,
    );
  }
}

/// Placeholder para WIP
class DashboardPlaceholder extends StatelessWidget {
  const DashboardPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.quaternaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.tertiaryColor, width: 3),
              ),
              child: const Icon(
                Icons.dashboard_customize_rounded,
                size: 80,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Módulo de Analítica",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6E1022),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFECA817).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "WORK IN PROGRESS",
                style: TextStyle(
                  color: AppTheme.secondaryColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                "Espacio pensado para incluir gráficos de ventas por local, rendimiento de mesas e indicadores comerciales del negocio.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Clase auxiliar. Guarda los datos de un Drawer Tile.
/// Elemento: REUTILIZABLE
class _DrawerItemData {
  final String title;
  final IconData icon;
  final String route;

  const _DrawerItemData({
    required this.title,
    required this.icon,
    required this.route,
  });
}
