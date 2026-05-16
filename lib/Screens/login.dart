import 'package:flutter/material.dart';


class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              'https://teresarestaurant.com/wp-content/uploads/2025/01/WA_00138-scaled.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 30),
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Form(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.flatware, color: Color(0xFF701321), size: 40),
                      const SizedBox(height: 10),
                      const Text(
                        "Bienvenido(a)",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF5D1111)),
                      ),
                      const Text(
                        "Inicia Sesión para Continuar",
                        style: TextStyle(color: Colors.orange),
                      ),
                      const SizedBox(height: 25),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: "Usuario",
                          hintText: "Ingresa tu usuario",
                          suffixIcon: const Icon(Icons.cancel_outlined, color: Colors.grey),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "Contraseña",
                          hintText: "Ingresa tu contraseña",
                          suffixIcon: const Icon(Icons.sentiment_satisfied_alt, color: Colors.grey),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 25),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF701321),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          child: const Text("Iniciar Sesión", style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text("Plaza", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF5D1111))),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}