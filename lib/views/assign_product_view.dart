import 'package:app_plaza_flutter/themes/app_theme.dart';
import 'package:app_plaza_flutter/widgets/widgets.dart';
import 'package:flutter/material.dart';

class AssignProductView extends StatefulWidget {
  const AssignProductView({super.key});

  @override
  State<AssignProductView> createState() => _AssignProductViewState();
}

class _AssignProductViewState extends State<AssignProductView> {
  final TextEditingController _priceCtrl = TextEditingController();
  final TextEditingController _dateCtrl = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _selectedProduct;
  String? _selectedLocal;
  bool _isBlocked = true;

  @override
  void dispose() {
    _priceCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {},
        ),
        title: const Text(
          "Asignar Producto",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 35),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Asignar Producto",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Configura el precio de venta de este producto para el local seleccionado. Permite manejar precios diferenciados por local.",
                style: TextStyle(
                  color: Color(0xFFB38E44),
                  fontSize: 14,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 35),
              _buildLabel("Producto"),
              _buildDropdown(
                hint: "Selecciona un producto",
                value: _selectedProduct,
                items: ['Ceviche Grande', 'Caldo de Gallina'],
                onChanged: (val) => setState(() => _selectedProduct = val),
              ),
              const SizedBox(height: 25),

              _buildLabel("Local"),
              _buildDropdown(
                hint: "Selecciona un local",
                value: _selectedLocal,
                items: ['Restaurante Plaza', 'Café 107'],
                onChanged: (val) => setState(() => _selectedLocal = val),
              ),
              const SizedBox(height: 25),

              CustomTextFormField(
                label: "Precio",
                hint: "0.00",
                controller: _priceCtrl,
                icon: Icons.sell_outlined,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 25),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Iniciar Bloqueado",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  Switch(
                    value: _isBlocked,
                    activeThumbColor: Colors.white,
                    activeTrackColor: AppTheme.primaryColor,
                    onChanged: (value) {
                      setState(() {
                        _isBlocked = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 15),

              if (_isBlocked)
                CustomTextFormField(
                  label: "Bloquear Hasta",
                  hint: "DD/MM/AAAA",
                  controller: _dateCtrl,
                  icon: Icons.calendar_today_outlined,
                ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      debugPrint("Asignando...");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    "Asignar Producto",
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
      ),
    );
  }

  // Herramientas Diseño :b

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          color: AppTheme.primaryColor,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      hint: Text(
        hint,
        style: const TextStyle(color: Colors.grey, fontSize: 14),
      ),
      isExpanded: true,
      icon: const Icon(Icons.arrow_drop_down, color: AppTheme.primaryColor),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 15,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(value: item, child: Text(item));
      }).toList(),
      onChanged: onChanged,
    );
  }
}
