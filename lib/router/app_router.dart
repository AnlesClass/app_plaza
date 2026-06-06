import 'package:app_plaza_flutter/views/create_role_view.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_plaza_flutter/views/views.dart';
import 'package:app_plaza_flutter/views/create_product_view.dart';
import 'package:app_plaza_flutter/views/assign_product_view.dart';

// Provider del GoRouter
final appRouterProvider = Provider<GoRouter>((ref) {
  return appRouter;
});

final appRouter = GoRouter(
  initialLocation: "/",
  routes: [
    GoRoute(path: "/", builder: (context, state) => const SplashView()),
    GoRoute(path: "/login", builder: (context, state) => const LoginView()),
    GoRoute(
      path: "/register",
      builder: (context, state) => const RegisterView(),
    ),
    GoRoute(
      path: "/create-category",
      builder: (context, state) => const CreateCategoryView(),
    ),
    GoRoute(
      path: "/create-local",
      builder: (context, state) => const CreateLocalView(),
    ),
    GoRoute(
      path: "/create-role",
      builder: (context, state) => const CreateRoleView(),
    ),
    GoRoute(
      path: '/create-product',
      builder: (context, state) => const CreateProductView(),
    ),
    GoRoute(
      path: '/assign-product',
      builder: (context, state) => const AssignProductView(),
    ),
    GoRoute(
      path: "/create-table",
      builder: (context, state) => const CreateTableView(),
    ),
    GoRoute(
      path: "/waiter-table",
      builder: (context, state) => const WaiterTablesView(),
    ),
    // TESTING
    GoRoute(
      path: "/test-routes",
      builder: (context, state) => const TestRoutesView(),
    ),
  ],
);
