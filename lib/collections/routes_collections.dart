abstract class RoutesCollections {
  // Rutas públicas
  static const String splash = '/';
  static const String login = '/login';

  // Rutas de Administrador
  static const String homeAdmin = '/home-admin';
  static const String createCategory = '/create-category';
  static const String createLocal = '/create-local';
  static const String createRole = '/create-role';
  static const String createProduct = '/create-product';
  static const String assignProduct = '/assign-product';
  static const String createTable = '/create-table';
  static const String register = '/register';

  // Rutas de Operadores
  static const String waiterTables = '/waiter-tables';
  static const String localProducts = '/local-products';

  // Rutas de Testeo
  static const String testRoutes = '/test-routes';

  /// Lista de todas las rutas como `String`
  static const List<String> allRoutes = [
    splash,
    login,
    register,
    createCategory,
    createLocal,
    createRole,
    createProduct,
    assignProduct,
    createTable,
    waiterTables,
    localProducts,
    testRoutes,
  ];

  /// Nombres de las rutas de forma amigable. Para consultas específicas.
  static const Map<String, String> routeNames = {
    splash: 'Inicio',
    login: 'Iniciar Sesión',
    register: 'Registrar Usuario',
    createCategory: 'Crear Categoría',
    createLocal: 'Crear Local',
    createRole: 'Crear Rol',
    createProduct: 'Crear Producto',
    assignProduct: 'Asignar Producto',
    createTable: 'Crear Mesa',
    waiterTables: 'Mesas',
    localProducts: 'Productos del Local',
    testRoutes: 'Testing',
  };

  /// Obtener el nombre de una ruta (desde el mapa)
  static String getRouteName(String route) {
    return routeNames[route] ?? route;
  }
}
