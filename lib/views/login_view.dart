import 'package:app_plaza_flutter/themes/app_theme.dart';
import 'package:app_plaza_flutter/widgets/widgets.dart';
import 'package:flutter/material.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController userCtrl = TextEditingController();
    final TextEditingController passCtrl = TextEditingController();

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/fondologin.jpg', fit: BoxFit.cover),

          Center(
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 25),
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 40,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Ícono principal
                    const Icon(
                      Icons.restaurant_menu_outlined,
                      size: 60,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(height: 15),

                    // Títulos
                    const Text(
                      "Bienvenido(a)",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                        fontFamily: 'Georgia',
                      ),
                    ),
                    const Text(
                      "Inicia Sesión para Continuar",
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.tertiaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 35),

                    // Campo: Nombre de Usuario o Correo
                    CustomTextFormField(
                      label: "Nombre de usuario o Contraseña",
                      hint: "Ej. Brigith o brigith.cusipuma@gmail.com",
                      controller: userCtrl,
                    ),
                    const SizedBox(height: 20),

                    // Campo: Contraseña
                    CustomTextFormField(
                      label: "Contraseña",
                      hint: "Ingresa tu contraseña",
                      controller: passCtrl,
                      isPassword: true,
                    ),

                    const SizedBox(height: 35),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {
                          debugPrint("Iniciando sesión...");
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 5,
                        ),
                        child: const Text(
                          "Iniciar Sesión",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Logo Inferior
                    Image.asset('assets/images/iconodelgado.png', height: 60),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
