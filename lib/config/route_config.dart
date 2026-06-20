// config/route_config.dart
import 'package:app_plaza_flutter/collections/roles_collections.dart';
import 'package:app_plaza_flutter/collections/routes_collections.dart';

class RouteConfig {
  // Definición de rutas con sus permisos requeridos
  static const Map<String, List<String>> routePermissions = {
    RoutesCollections.splash: [],
    RoutesCollections.login: [],

    // Rutas administrativas
    RoutesCollections.homeAdmin: [RolesCollections.adminId],
    RoutesCollections.createCategory: [RolesCollections.adminId],
    RoutesCollections.createLocal: [RolesCollections.adminId],
    RoutesCollections.createRole: [RolesCollections.adminId],
    RoutesCollections.createProduct: [RolesCollections.adminId],
    RoutesCollections.assignProduct: [RolesCollections.adminId],
    RoutesCollections.createTable: [RolesCollections.adminId],
    RoutesCollections.register: [RolesCollections.adminId],

    // Rutas operativas
    RoutesCollections.waiterTables: [
      RolesCollections.waiterId,
      RolesCollections.adminId,
    ],
    RoutesCollections.localProducts: [
      RolesCollections.waiterId,
      RolesCollections.adminId,
      RolesCollections.chefId,
      RolesCollections.cashierId,
    ],

    // Testing Público (solo desarrollo)
    RoutesCollections.testRoutes: [],
  };

  // Configurar ruta de inicio para cada tipo de Usuario
  static const Map<String, String> roleHomeRoutes = {
    RolesCollections.adminId: RoutesCollections.homeAdmin,
    RolesCollections.chefId: RoutesCollections.localProducts,
    RolesCollections.waiterId: RoutesCollections.waiterTables,
    RolesCollections.cashierId: RoutesCollections.localProducts,
  };

  // Ruta por defecto: No hay sesión activa
  static const String defaultRoute = RoutesCollections.login;

  // Ruta por defecto: En caso no haya Home válido
  static const String fallbackRoute = RoutesCollections.waiterTables;

  // Rutas públicas
  static const List<String> publicRoutes = [
    RoutesCollections.splash,
    RoutesCollections.login,
    RoutesCollections.testRoutes,
  ];

  /// Verifica si una ruta requiere permisos
  static bool routeRequiresAuth(String routePath) {
    return routePermissions.containsKey(routePath) &&
        routePermissions[routePath]!.isNotEmpty;
  }

  /// Obtiene la lista de roles permitidos para una ruta
  static List<String> getRequiredRoles(String routePath) {
    return routePermissions[routePath] ?? [];
  }

  /// Verifica si un rol específico puede acceder a la ruta proporcionada
  static bool hasAccess(String routePath, String userRoleId) {
    final requiredRoles = getRequiredRoles(routePath);
    if (requiredRoles.isEmpty) return true;
    return requiredRoles.contains(userRoleId);
  }

  /// Obtiene la ruta "Home" de un rol
  static String getHomeRoute(String userRoleId) {
    return roleHomeRoutes[userRoleId] ?? fallbackRoute;
  }

  /// Verifica si una ruta es pública
  static bool isPublicRoute(String routePath) {
    return publicRoutes.contains(routePath);
  }
}
