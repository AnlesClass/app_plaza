import 'package:app_plaza_flutter/models/models.dart';
import 'package:app_plaza_flutter/repositories/repositories.dart';
import 'package:app_plaza_flutter/themes/app_theme.dart';
import 'package:app_plaza_flutter/utils/utils.dart';
import 'package:app_plaza_flutter/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

/// VISTA DEBUG. No agrega por ningún motivo en las visualización final.
class CreateRoleView extends ConsumerStatefulWidget {
  const CreateRoleView({super.key});

  @override
  ConsumerState<CreateRoleView> createState() => _CreateRoleViewState();
}

class _CreateRoleViewState extends ConsumerState<CreateRoleView> {
  // Controladores para los campos de texto
  final TextEditingController _roleNameCtrl = TextEditingController();
  final TextEditingController _descriptionCtrl = TextEditingController();

  // Llave global para validación del Form
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // Liberación de recursos en memoria
    _roleNameCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Repositorio encargado de la persistencia de roles
    final RoleRepository roleRepository = ref.watch(roleRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {},
        ),
        title: const Text(
          "Rol de Usuario",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Configuración del Nuevo Rol",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.tertiaryColor,
                ),
              ),
              const SizedBox(height: 20),

              // Campo: Nombre del Rol
              CustomTextFormField(
                label: "Nombre del Rol",
                hint: "Ej. Administrador, Mozo, Cocinero",
                maxLength: 30,
                controller: _roleNameCtrl,
                icon: Icons.admin_panel_settings_outlined,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "El nombre del rol es requerido";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo: Descripción de funciones
              CustomTextFormField(
                label: "Descripción de Funciones",
                hint:
                    "Ej. Gestión total del sistema, apertura de caja y reportes.",
                maxLength: 150,
                maxLines: 3, // Mayor espacio vertical para detallar el rol
                controller: _descriptionCtrl,
                icon: Icons.description_outlined,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "La descripción es requerida";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Botón: Crear Rol
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () async {
                    // Validar los campos localmente
                    if (!_formKey.currentState!.validate()) return;

                    // Ejecutar Modal de comprobación asíncrono
                    final bool isAccepted = await AppAlerts.showConfirmation(
                      context: context,
                      title: "Confirmar Acción",
                      message:
                          "¿Está seguro(a) de que desea crear este nuevo rol de usuario para el sistema?",
                    );

                    // Validar aceptación del usuario
                    if (!isAccepted) return;

                    // Instanciar el objeto del modelo Role
                    final newRole = Role(
                      name: _roleNameCtrl.text.trim(),
                      description: _descriptionCtrl.text.trim(),
                    );

                    // Registrar en la Base de Datos
                    try {
                      await roleRepository.createRole(newRole);

                      if (context.mounted) {
                        AppAlerts.showSnackbar(
                          context,
                          "Rol registrado correctamente.",
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        AppAlerts.showSnackbar(context, e.toString());
                      }
                    }

                    // Limpieza segura de campos
                    clearFields();
                  },
                  child: const Text(
                    "Crear Rol",
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
    // Limpiar campos.
    _roleNameCtrl.clear();
    _descriptionCtrl.clear();

    // Resetear en el siguiente frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _formKey.currentState?.reset();
    });
  }
}
