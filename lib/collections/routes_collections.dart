abstract class RoutesCollections {
  // ### DEFINICIÓN DE RUTAS ###
  // Rutas públicas
  static const String splash = "/";
  static const String login = "/login";

  // Rutas de Administrador
  static const String homeAdmin = "/home-admin";
  static const String register = "/register";
  static const String assignProduct = "/assign-product";
  static const String createCategory = "/create-category";
  static const String createLocal = "/create-local";
  static const String createRole = "/create-role";
  static const String createProduct = "/create-product";
  static const String createTable = "/create-table";

  // Rutas de Operadores
  static const String localProducts = "/local-products";
  static const String localProductsMenu = "/local-products-menu";
  static const String showTables = "/show-tables";
  static const String showTableDetail = "/show-table-detail/:tableId";
  static const String showOrders = "/show-orders";
  static const String preOrderAccount = "/pre-order-account";

  // Rutas de Pruebas
  static const String testRoutes = "/test-routes";

  // ### CONSTRUCTORES DE RUTAS ###
  static String buildShowTableDetailUrl(String tableId) =>
      "/show-table-detail/$tableId";
}
