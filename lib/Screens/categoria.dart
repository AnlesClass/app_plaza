import 'package:flutter/material.dart';

class categoria extends StatefulWidget {
  const categoria({super.key});

  @override
  State<categoria> createState() => _CreateCategoryState();
}

class _CreateCategoryState extends State<categoria> {
  
  final TextEditingController _categoryNameCtrl = TextEditingController();
  final TextEditingController _descriptionCtrl = TextEditingController();

  @override
  void dispose() {
    _categoryNameCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF701321),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white), 
          onPressed: () {
          },
        ),
        title: const Text(
          "Categoría",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 35),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Crear Categoría",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF701321), 
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Cree una nueva categoría para sus productos.",
              style: TextStyle(
                color: Color(0xFFB38E44), 
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 35),

            _buildTextField(
              label: "Nombre de la Categoría",
              hint: "Ej: Bebidas Alcohólicas",
              maxLength: 50,
              controller: _categoryNameCtrl,
            ),
            const SizedBox(height: 25),

            _buildTextField(
              label: "Descripción",
              hint: "Describe categoría (opcional)",
              maxLength: 200,
              maxLines: 4, 
              controller: _descriptionCtrl,
            ),
            const SizedBox(height: 35),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {

                  print("Nueva Categoría: ${_categoryNameCtrl.text}");
                  print("Descripción: ${_descriptionCtrl.text}");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF701321),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  "Crear Categoría",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildTextField({
    required String label,
    required String hint,
    required int maxLength,
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return TextFormField(
          controller: controller,
          maxLength: maxLength,
          maxLines: maxLines,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(
              color: Color(0xFF701321),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),

            suffixIcon: controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.cancel_outlined, color: Colors.grey),
                    onPressed: () => controller.clear(),
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            counterText: "${controller.text.length}/$maxLength", // Contador reactivo en tiempo real
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
    );
  }
}