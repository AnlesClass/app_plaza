import 'package:app_plaza_flutter/collections/routes_collections.dart';
import 'package:app_plaza_flutter/router/app_router.dart';
import 'package:app_plaza_flutter/themes/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashView extends ConsumerStatefulWidget {
  const SplashView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashView> {
  @override
  void initState() {
    super.initState();
    // Llamar al provider del Navegador: App Router
    final GoRouter appRouter = ref.read(appRouterProvider);
    // Esperar 3 segundos e ir al Login
    Future.delayed(const Duration(seconds: 3), () {
      appRouter.go(RoutesCollections.login);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/FondoPlaza.jpg',
            fit: BoxFit.cover,
            color: Colors.white.withValues(alpha: 0.7),
            colorBlendMode: BlendMode.lighten,
          ),
          Container(color: Colors.white.withValues(alpha: 0.5)),
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.church, size: 80, color: AppTheme.primaryColor),
              Text(
                "Plaza",
                style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                  fontFamily: 'Serif',
                ),
              ),
              SizedBox(height: 20),
              CircularProgressIndicator(color: AppTheme.primaryColor),
            ],
          ),
        ],
      ),
    );
  }
}
