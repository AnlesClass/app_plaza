// views/test_routes_view.dart
import 'package:app_plaza_flutter/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Vista de testing que muestra todas las rutas disponibles
/// Solo para desarrollo, no incluir en producción
class TestRoutesView extends StatelessWidget {
  const TestRoutesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Routes - Panel de Navegación'),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 2,
        actions: [
          // Badge de desarrollo
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.tertiaryColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'TEST',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Encabezado con información
          _buildHeader(context),
          const SizedBox(height: 20),

          // Sección de autenticación
          _buildSectionTitle('Autenticación', Icons.login),
          _buildRouteCard(
            context,
            title: 'Splash',
            route: '/',
            description: 'Pantalla de inicio/splash',
            icon: Icons.perm_identity,
            color: Colors.blue,
          ),
          _buildRouteCard(
            context,
            title: 'Login',
            route: '/login',
            description: 'Inicio de sesión',
            icon: Icons.login,
            color: Colors.green,
          ),
          _buildRouteCard(
            context,
            title: 'Register',
            route: '/register',
            description: 'Registro de usuario',
            icon: Icons.app_registration,
            color: Colors.teal,
          ),

          const SizedBox(height: 16),

          // Sección de configuración principal
          _buildSectionTitle('Configuración Principal', Icons.settings),
          _buildRouteCard(
            context,
            title: 'Crear Local',
            route: '/create-local',
            description: 'Registro de nuevos locales',
            icon: Icons.storefront,
            color: Colors.orange,
          ),
          _buildRouteCard(
            context,
            title: 'Crear Rol',
            route: '/create-role',
            description: 'Definición de roles de usuario',
            icon: Icons.admin_panel_settings,
            color: Colors.purple,
          ),
          _buildRouteCard(
            context,
            title: 'Crear Categoría',
            route: '/create-category',
            description: 'Gestión de categorías',
            icon: Icons.category,
            color: Colors.indigo,
          ),

          const SizedBox(height: 16),

          // Sección de productos
          _buildSectionTitle('Productos', Icons.inventory_2),
          _buildRouteCard(
            context,
            title: 'Crear Producto',
            route: '/create-product',
            description: 'Alta de nuevos productos',
            icon: Icons.add_business,
            color: Colors.deepOrange,
          ),
          _buildRouteCard(
            context,
            title: 'Asignar Producto',
            route: '/assign-product',
            description: 'Asignar productos a categorías/locales',
            icon: Icons.assignment_ind,
            color: Colors.brown,
          ),
          _buildRouteCard(
            context,
            title: 'Productos del Local',
            route: '/local-products',
            description: 'Ver productos asignados al local actual',
            icon: Icons.inventory,
            color: Colors.deepOrange,
          ),

          const SizedBox(height: 16),

          // Sección de mesas y operación
          _buildSectionTitle('Mesas y Operación', Icons.table_restaurant),
          _buildRouteCard(
            context,
            title: 'Crear Mesa',
            route: '/create-table',
            description: 'Registro de nuevas mesas',
            icon: Icons.add_circle,
            color: Colors.cyan,
          ),
          _buildRouteCard(
            context,
            title: 'Vista de Mesas (Mesero)',
            route: '/waiter-table',
            description: 'Pantalla principal del mesero',
            icon: Icons.restaurant_menu,
            color: Colors.red,
          ),

          const SizedBox(height: 24),

          // Información adicional
          _buildInfoCard(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.route, size: 50, color: Colors.white),
          const SizedBox(height: 12),
          const Text(
            'Panel de Navegación',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Rutas Permitiidas: ${_getTotalRoutes()}',
            style: const TextStyle(fontSize: 16, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Row(
        children: [
          Icon(icon, size: 28, color: AppTheme.primaryColor),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.secondaryColor,
            ),
          ),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }

  Widget _buildRouteCard(
    BuildContext context, {
    required String title,
    required String route,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          context.push(route);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      route,
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 20, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.amber.shade700, size: 24),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "Esta es una vista de testeo. Brigith pon tu parte antes de acabar el segundo sprint UWU.",
              style: TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  int _getTotalRoutes() {
    // Excluyendo la ruta actual de testing
    const excludedRoutes = ['/test-routes'];
    const allRoutes = [
      '/',
      '/login',
      '/register',
      '/create-category',
      '/create-local',
      '/create-role',
      '/create-product',
      '/assign-product',
      '/create-table',
      '/waiter-table',
    ];
    return allRoutes.where((r) => !excludedRoutes.contains(r)).length;
  }
}
