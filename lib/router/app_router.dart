import 'package:app_plaza_flutter/config/route_config.dart';
import 'package:app_plaza_flutter/collections/routes_collections.dart';
import 'package:app_plaza_flutter/providers/session_providers.dart';
import 'package:app_plaza_flutter/utils/app_alerts.dart';
import 'package:app_plaza_flutter/views/show_orders_view.dart';
import 'package:app_plaza_flutter/views/views.dart';
import 'package:app_plaza_flutter/views/admin/create_product_view.dart';
import 'package:app_plaza_flutter/views/admin/assign_product_view.dart';
import 'package:app_plaza_flutter/views/waiter/product_menu_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Provider del Router configurado para la aplicación.
/// `Nota para Devs:`
/// - initialLocation: Configura la ruta inicial de la aplicación como un String.
/// - redirect: Configura la redirección de rutas en caso no exista sesión activa.
/// - routes: Configura las rutas disponibles en base a un String y la vista seleccionada.
final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: RoutesCollections.splash,
    redirect: (context, state) {
      // ¿Qué hace?
      // Devuelve la ruta a la que se quiere navegar `(String)` si se cumplen o
      // no ciertas condiciones.
      // context => Contexto de la aplicación.
      // state => Estado de la aplicación, utilizado para consultar la ruta a la que se quiere acceder.
      // return null; => Significa que no hay problema, que se siga en la misma vista.

      debugPrint("DEBUG: Entrando al redireccionamiento");
      // Estado de autenticación, Usuario Auth de Firebase
      final authState = ref.watch(firebaseAuthUserProvider);

      // En caso no haya usuario autenticado y la ruta a la que quiere ir no es pública
      // entonces redirigir al Login.
      if (authState.value == null) {
        if (!RouteConfig.isPublicRoute(state.uri.path)) {
          debugPrint("DEBUG: Redirigiendo al Login");
          return RoutesCollections.login;
        }
        return null;
      }

      // Cargar los datos de la sesión activa
      final sessionData = ref.watch(sessionDataProvider);

      // Permanecer en la sesión actual mientras está cargando.
      if (sessionData.isLoading) {
        debugPrint(
          "[AUTH SESSION] Sesión está cargando. Continúa en la pestaña actual.",
        );
        return null;
      }
      // Si no hay sesión activa, redireccionar al Login
      if (sessionData.value == null) {
        debugPrint("[ENRUTAMIENTO] Redirigiendo al Login...");
        return RoutesCollections.login;
      }

      // Consultar modelo de usuario de la sesión actual
      final user = sessionData.value!.user;
      final userRole = user.idRole;
      final currentPath = state.uri.path;
      debugPrint("[]: Redirigiendo al Login...");

      // Si el usuario está en la vista Login pero ya hay sesión activa
      debugPrint("[REDIRECT-ROUTER] Ruta Actual => $currentPath");
      debugPrint("[REDIRECT-ROUTER] Ruta Login => ${RoutesCollections.login}");
      if (currentPath == RoutesCollections.login ||
          currentPath == RoutesCollections.splash) {
        return RouteConfig.getHomeRoute(userRole);
      }

      // Verificar si el usuario tiene acceso a la ruta
      // En caso no tenga entonces redireccionar a su vista "Home"
      if (!RouteConfig.hasAccess(currentPath, userRole)) {
        // Espera 1 frame para mostrar el Snackbar. Nuevo contexto montado.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            AppAlerts.showSnackbar(
              context,
              "No tienes permiso para acceder a esta sección",
              isError: true,
            );
          }
        });

        return RouteConfig.getHomeRoute(userRole);
      }

      debugPrint("DEBUG: Llega hasta el final...");
      // Si todo lo anterior no lo redirige, entonces permitir estar en esta ruta.
      return null;
    },
    routes: [
      // Definimos todas las rutas para la aplicación
      GoRoute(
        path: RoutesCollections.splash,
        builder: (context, state) => const SplashView(),
      ),
      GoRoute(
        path: RoutesCollections.login,
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        path: RoutesCollections.register,
        builder: (context, state) => const RegisterView(),
      ),
      GoRoute(
        path: RoutesCollections.homeAdmin,
        builder: (context, state) => const BusinessDashboardView(),
      ),
      GoRoute(
        path: RoutesCollections.createCategory,
        builder: (context, state) => const CreateCategoryView(),
      ),
      GoRoute(
        path: RoutesCollections.createLocal,
        builder: (context, state) => const CreateLocalView(),
      ),
      GoRoute(
        path: RoutesCollections.createRole,
        builder: (context, state) => const CreateRoleView(),
      ),
      GoRoute(
        path: RoutesCollections.createProduct,
        builder: (context, state) => const CreateProductView(),
      ),
      GoRoute(
        path: RoutesCollections.assignProduct,
        builder: (context, state) => const AssignProductView(),
      ),
      GoRoute(
        path: RoutesCollections.createTable,
        builder: (context, state) => const CreateTableView(),
      ),
      GoRoute(
        path: RoutesCollections.showTables,
        builder: (context, state) => const ShowTablesView(),
      ),
      GoRoute(
        path: RoutesCollections.showTableDetail,
        builder: (context, state) {
          // Capturamos el identificador de la mesa y consultamos si tiene una orden aún sin completar.
          final param = state.pathParameters;
          return ShowTableDetailView(tableId: param['tableId']!);
        },
      ),
      GoRoute(
        path: RoutesCollections.localProducts,
        builder: (context, state) => const LocalProductsView(),
      ),
      GoRoute(
        path: RoutesCollections.localProductsMenu,
        builder: (context, state) {
          return const ProductMenuView();
        },
      ),
      GoRoute(
        path: RoutesCollections.showOrders,
        builder: (context, state) => const ShowOrdersView(),
      ),
      // TODO: Pruebas de rutas, eliminar en la versión final.
      GoRoute(
        path: RoutesCollections.testRoutes,
        builder: (context, state) => const TestRoutesView(),
      ),
      GoRoute(
        path: RoutesCollections.preOrderAccount,
        builder: (context, state) => const PreOrderAccountView(),
      ),
    ],
  );

  return router;
});
