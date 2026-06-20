import 'package:app_plaza_flutter/models/category.dart';
import 'package:app_plaza_flutter/repositories/category_repository.dart';
import 'package:app_plaza_flutter/router/app_router.dart';
import 'package:app_plaza_flutter/themes/app_theme.dart';
import 'package:app_plaza_flutter/utils/utils.dart';
import 'package:app_plaza_flutter/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

class CreateCategoryView extends ConsumerStatefulWidget {
  const CreateCategoryView({super.key});

  @override
  ConsumerState<CreateCategoryView> createState() => _CreateCategoryState();
}

class _CreateCategoryState extends ConsumerState<CreateCategoryView> {
  final TextEditingController _categoryNameCtrl = TextEditingController();
  final TextEditingController _descriptionCtrl = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _categoryNameCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Escuchamos el repositorio recién creado
    final CategoryRepository categoryRepository = ref.watch(
      categoryRepositoryProvider,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Crear Categoría",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Cree una nueva categoría para sus productos.",
                style: TextStyle(
                  color: AppTheme.tertiaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 35),

              // Campo: Nombre de Categoría
              CustomTextFormField(
                label: "Nombre de la Categoría",
                hint: "Ej: Bebidas Alcohólicas",
                maxLength: 50,
                controller: _categoryNameCtrl,
                icon: Icons.category_outlined,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "El nombre de la categoría es requerido";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 25),

              // Campo: Descripción
              CustomTextFormField(
                label: "Descripción",
                hint: "Describe la categoría (opcional)",
                maxLength: 200,
                maxLines: 4,
                controller: _descriptionCtrl,
                icon: Icons.text_fields_outlined,
                // Al ser opcional, no requiere validador estricto de vacío
              ),
              const SizedBox(height: 35),

              // Botón de Acción optimizado
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () async {
                    // Validar campos locales
                    if (!_formKey.currentState!.validate()) return;

                    // Solicitar confirmación
                    final bool isAccepted = await AppAlerts.showConfirmation(
                      context: context,
                      title: "Confirmar Acción",
                      message:
                          "¿Está seguro(a) de que desea crear esta nueva categoría de productos?",
                    );

                    if (!isAccepted) return;

                    // Crear modelo
                    final newCategory = Category(
                      name: _categoryNameCtrl.text.trim(),
                      description: _descriptionCtrl.text.trim(),
                    );

                    // Guardar en Firestore
                    try {
                      await categoryRepository.createCategory(newCategory);

                      if (context.mounted) {
                        AppAlerts.showSnackbar(
                          context,
                          "Categoría registrada correctamente.",
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        AppAlerts.showSnackbar(context, e.toString());
                      }
                    }

                    // Limpiar campos
                    clearFields();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
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
      ),
    );
  }

  void clearFields() {
    _categoryNameCtrl.clear();
    _descriptionCtrl.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _formKey.currentState?.reset();
    });
  }
}
