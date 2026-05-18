import 'package:app_plaza_flutter/views/views.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Provider del GoRouter
final appRouterProvider = Provider<GoRouter>((ref) {
  return appRouter;
});

final appRouter = GoRouter(
  routes: [
    GoRoute(path: "/", builder: (context, state) => const TestProviders()),
  ],
);
