import 'package:flutter/material.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/fondologin.jpg',
            fit: BoxFit.cover,
          ),
          
          Center(
            child: SingleChildScrollView( 
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 25),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40), 
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.restaurant_menu_outlined, 
                      size: 60, 
                      color: Color(0xFF701321), 
                    ),
                    const SizedBox(height: 15),
                    
                    // Títulos
                    const Text(
                      "Bienvenido(a)",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF701321),
                        fontFamily: 'Georgia', 
                      ),
                    ),
                    const Text(
                      "Inicia Sesión para Continuar",
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFFB38E44),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 35),

                    // INPUT USUARIO
                    _buildTextField(
                      label: "Usuario",
                      hint: "Ingresa tu usuario",
                      icon: Icons.cancel_outlined,
                    ),
                    const SizedBox(height: 20),

                    // INPUT CONTRASEÑA
                    _buildTextField(
                      label: "Contraseña",
                      hint: "Ingresa tu contraseña",
                      icon: Icons.sentiment_satisfied_alt,
                      isPassword: true,
                    ),
                    const SizedBox(height: 35),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {
                          print("Iniciando sesión...");
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF701321),
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

                    // LOGO PLAZA INFERIOR
                    Image.asset(
                      'assets/images/iconodelgado.png',
                      height: 60,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label, 
    required String hint, 
    required IconData icon, 
    bool isPassword = false
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "  $label",
          style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 5),
        TextField(
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            suffixIcon: Icon(icon, color: Colors.grey),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.grey, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Color(0xFF701321), width: 2),
            ),
          ),
        ),
      ],
    );
  }
}