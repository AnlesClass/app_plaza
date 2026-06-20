import 'package:app_plaza_flutter/repositories/auth_repository.dart';
import 'package:app_plaza_flutter/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'package:app_plaza_flutter/router/app_router.dart';

void main() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // NOTA: Si se quieren probar nuevas Funciones en Functions Firebase usar:
  // FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
  // Dentro de una condicional para solo en modo Debug.

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
      // TODO: Floating Button Debug. Borrar al finalizar las pruebas.
      builder: (context, child) {
        return Scaffold(
          body: child,
          floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.login_outlined),
            onPressed: () async {
              await ref.read(authRepositoryProvider).signOut();
            },
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        );
      },
    );
  }
}
