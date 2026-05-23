import 'package:app_plaza_flutter/models/models.dart';
import 'package:app_plaza_flutter/repositories/repositories.dart';
import 'package:app_plaza_flutter/themes/app_theme.dart';
import 'package:app_plaza_flutter/utils/utils.dart';
import 'package:app_plaza_flutter/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

class CreateLocalView extends ConsumerStatefulWidget {
  const CreateLocalView({super.key});

  @override
  ConsumerState<CreateLocalView> createState() => _CreateLocalViewState();
}

class _CreateLocalViewState extends ConsumerState<CreateLocalView> {
  // Contraladores
  final TextEditingController _rucCtrl = TextEditingController();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _addressCtrl = TextEditingController();

  // Llave global para el Formulario
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // Libera memoria
    _rucCtrl.dispose();
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final LocalRepository localRepository = ref.watch(localRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {},
        ),
        title: const Text(
          "Local",
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
          key: _formKey, // Asignamos la llave al formulario
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Información del Establecimiento",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.tertiaryColor,
                ),
              ),
              const SizedBox(height: 20),

              // Campo: RUC
              CustomTextFormField(
                label: "RUC",
                hint: "Ingresa los 11 dígitos del RUC",
                maxLength: 11,
                controller: _rucCtrl,
                keyboardType: TextInputType.number,
                icon: Icons.badge_outlined,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "El RUC es requerido";
                  }
                  if (value.length != 11) {
                    return "El RUC debe tener exactamente 11 dígitos";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo: Nombre
              CustomTextFormField(
                label: "Nombre Comercial",
                hint: "Ej. Plaza Restaurante Sede Chincha",
                maxLength: 50,
                controller: _nameCtrl,
                icon: Icons.storefront_outlined,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "El nombre es requerido";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo: Dirección
              CustomTextFormField(
                label: "Dirección",
                hint: "Ej. Av. Benavides 123, Chincha Alta",
                maxLength: 100,
                maxLines: 2, // Le damos más espacio por ser dirección
                controller: _addressCtrl,
                icon: Icons.location_on_outlined,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "La dirección es requerida";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Botón: Crear Local
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () async {
                    // Validar los campos
                    if (!_formKey.currentState!.validate()) return;
                    // Ejecutar Modal para comprobación
                    final bool isAccepted = await AppAlerts.showConfirmation(
                      context: context,
                      title: "Confirmar Acción",
                      message:
                          "Crear un local es un procedimiento que no está diseñado para hacerse con frecuencia, ¿está seguro(a) que desea crear un nuevo local?",
                    );
                    // Validar aceptación
                    if (!isAccepted) return;
                    // TODO: Empezar a procesar. Bloquear campos y Botón.
                    // TODO: Validar RUC? -> Pedir confirmación.
                    // Crear modelo Local
                    final newLocal = Local(
                      name: _nameCtrl.text,
                      address: _addressCtrl.text,
                      ruc: _rucCtrl.text,
                    );
                    // Registrar Local
                    try {
                      // Intenta registrar en la base de datos
                      await localRepository.createLocal(newLocal);
                      // Muestra un SnackBar de confirmación de operación
                      if (context.mounted) {
                        AppAlerts.showSnackbar(
                          context,
                          "Local registrado correctamente.",
                        );
                      }
                    } catch (e) {
                      // Muestra un SnackBar de error en la operación
                      if (context.mounted) {
                        AppAlerts.showSnackbar(context, e.toString());
                      }
                    }
                    // Limpia los campos del formulario
                    clearFields();
                  },
                  child: const Text(
                    "Crear Local",
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
    // Limpia campos de formularios
    _rucCtrl.clear();
    _nameCtrl.clear();
    _addressCtrl.clear();
    // Reinicia el estado del formulario. Evita que los campos se marquen como errores.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _formKey.currentState?.reset();
    });
  }
}
