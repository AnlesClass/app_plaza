import 'package:app_plaza_flutter/models/category.dart';
import 'package:app_plaza_flutter/models/product.dart';
import 'package:app_plaza_flutter/repositories/category_repository.dart';
import 'package:app_plaza_flutter/repositories/product_repository.dart';
import 'package:app_plaza_flutter/router/app_router.dart';
import 'package:app_plaza_flutter/themes/app_theme.dart';
import 'package:app_plaza_flutter/utils/utils.dart';
import 'package:app_plaza_flutter/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateProductView extends ConsumerStatefulWidget {
  const CreateProductView({super.key});

  @override
  ConsumerState<CreateProductView> createState() => _CreateProductViewState();
}

class _CreateProductViewState extends ConsumerState<CreateProductView> {
  final TextEditingController _productNameCtrl = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _selectedCategoryId;
  String? _selectedCategoryName;
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _productNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final categoryRepository = ref.read(categoryRepositoryProvider);
      final categories = await categoryRepository.getCategories();
      setState(() {
        _categories = categories;
      });
    } catch (e) {
      if (mounted) {
        AppAlerts.showSnackbar(context, "Error al cargar categorías: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productRepository = ref.watch(productRepositoryProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.tertiaryColor),
          onPressed: () {
            // Consultar AppRouter
            final appRouter = ref.read(appRouterProvider);
            // Navegar hacia atrás de ser posible
            if (appRouter.canPop()) {
              appRouter.pop();
            }
          },
        ),
        title: const Text(
          "Producto",
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
                "Crear Producto",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 6),
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    color: AppTheme.tertiaryColor,
                    fontSize: 14,
                    height: 1.3,
                  ),
                  children: [
                    TextSpan(
                      text:
                          "Crea una plantilla global del producto. Podrás asignar precios específicos para cada local en la sección ",
                    ),
                    TextSpan(
                      text: "Asignar Producto",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 35),

              CustomTextFormField(
                label: "Nombre del Producto",
                hint: "Ej: Ceviche Grande",
                maxLength: 50,
                controller: _productNameCtrl,
                icon: Icons.fastfood_outlined,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "El nombre del producto es requerido";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 25),

              _buildLabel("Categoría"),
              _buildDropdown(
                hint: "Selecciona una categoría",
                value: _selectedCategoryName,
                items: _categories.map((c) => c.name).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedCategoryName = val;
                    _selectedCategoryId = _categories
                        .firstWhere(
                          (c) => c.name == val,
                          orElse: () => Category(name: '', description: ''),
                        )
                        .uid;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Debe seleccionar una categoría";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;

                    final bool isAccepted = await AppAlerts.showConfirmation(
                      context: context,
                      title: "Confirmar Acción",
                      message:
                          "¿Está seguro(a) de que desea crear este producto?",
                    );

                    if (!isAccepted) return;

                    final newProduct = Product(
                      idCategory: _selectedCategoryId!,
                      name: _productNameCtrl.text.trim(),
                    );

                    try {
                      await productRepository.createProduct(newProduct);

                      if (context.mounted) {
                        AppAlerts.showSnackbar(
                          context,
                          "Producto registrado correctamente.",
                        );
                        clearFields();
                      }
                    } catch (e) {
                      if (context.mounted) {
                        AppAlerts.showSnackbar(context, e.toString());
                      }
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
                    "Crear Producto",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 35),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 13,
                      height: 1.4,
                    ),
                    children: [
                      TextSpan(
                        text: "Debug: ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text:
                            "El producto se crea como plantilla global. Luego se asignará a un local específico.",
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
    required String? Function(String?)? validator,
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(value: item, child: Text(item));
      }).toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }

  void clearFields() {
    _productNameCtrl.clear();
    setState(() {
      _selectedCategoryName = null;
      _selectedCategoryId = null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _formKey.currentState?.reset();
    });
  }
}
