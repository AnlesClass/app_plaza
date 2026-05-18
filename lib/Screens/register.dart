import 'package:flutter/material.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  bool isUserActive = true;
  String? selectedLocal;
  String? selectedRol;
  

  final TextEditingController _userCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  final TextEditingController _repeatPassCtrl = TextEditingController();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _lastNameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    _repeatPassCtrl.dispose();
    _nameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

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

          Positioned.fill(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 60), 

                  Container(
                    width: 111,
                    height: 111,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),
                    child: const CircleAvatar(
                      backgroundColor: Color(0xFF701321), 
                      backgroundImage: AssetImage('assets/images/iconoregister.png'),
                    ),
                  ),
                  
                  const SizedBox(height: 30), 

                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 35),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Row(
                          children: [
                            const Icon(Icons.star_border, color: Color(0xFF701321), size: 28),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Crear Usuario",
                                  style: TextStyle(
                                    fontSize: 22, 
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF701321),
                                  ),
                                ),
                                Text(
                                  "Crear un nuevo usuario para su local",
                                  style: TextStyle(color: Colors.orange.shade800, fontSize: 13),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        

                        _buildField("Usuario", "Ej: Brigith.Cusipuma", Icons.cancel_outlined, _userCtrl),
                        _buildField("Contraseña", "**********", Icons.sentiment_satisfied_alt, _passCtrl, isPassword: true),
                        _buildField("Repetir Contraseña", "**********", Icons.sentiment_satisfied_alt, _repeatPassCtrl, isPassword: true),
                        _buildField("Nombre(s)", "Ej: Brigith", Icons.cancel_outlined, _nameCtrl),
                        _buildField("Apellido(s)", "Ej: Cusipuma Candela", Icons.cancel_outlined, _lastNameCtrl),
                        _buildField("Correo Electrónico", "Ej: correo@gmail.com", Icons.cancel_outlined, _emailCtrl),


                        _buildLabel("Local"),
                        _buildDropdown(
                          hint: "Selecciona un local",
                          value: selectedLocal,
                          items: ['Restaurante Plaza', 'Café 107'],
                          onChanged: (val) => setState(() => selectedLocal = val),
                        ),
                        
                        const SizedBox(height: 25),
                        
                        _buildLabel("Rol"),
                        _buildDropdown(
                          hint: "Selecciona un rol",
                          value: selectedRol,
                          items: ['Administrador', 'Mesero'],
                          onChanged: (val) => setState(() => selectedRol = val),
                        ),

                        const SizedBox(height: 25),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Usuario activo en el sistema",
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black),
                            ),
                            Switch(
                              value: isUserActive,
                              activeColor: Colors.white,
                              activeTrackColor: const Color(0xFF701321),
                              onChanged: (value) {
                                setState(() {
                                  isUserActive = value;
                                });
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 35),


                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: () {
                              print("Registrando: ${_userCtrl.text}");
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF701321),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              elevation: 2,
                            ),
                            child: const Text(
                              "Registrar Usuario",
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        
          Positioned(
            top: 45,
            left: 15,
            child: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.3),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: Text(text, style: const TextStyle(color: Color(0xFF701321), fontSize: 13, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildField(String label, String hint, IconData icon, TextEditingController controller, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return TextFormField(
            controller: controller,
            obscureText: isPassword,
            maxLength: 50,
            decoration: InputDecoration(
              labelText: label,
              labelStyle: const TextStyle(color: Color(0xFF701321), fontSize: 13, fontWeight: FontWeight.w500),
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
              suffixIcon: Icon(icon, color: const Color(0xFF701321)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              counterText: "${controller.text.length}/50",
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF701321), width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF701321), width: 2),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDropdown({required String hint, String? value, required List<String> items, required Function(String?) onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF701321), width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF701321)),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}