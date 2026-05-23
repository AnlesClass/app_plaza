import 'package:app_plaza_flutter/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:app_plaza_flutter/views/views.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    // Tardar N segundos en pasar a la siguiente vista.
    final navigator = Navigator.of(context);
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      navigator.pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginView()),
      );
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
