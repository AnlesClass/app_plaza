import 'package:app_plaza_flutter/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'package:app_plaza_flutter/router/app_router.dart';

void main() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GoRouter appRouter = ref.watch(appRouterProvider);
    // TODO: Implementar provider para controlar el redibujado de ltema oscuro/claro

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Plaza App',
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}
