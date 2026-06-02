import 'package:app_plaza_flutter/models/models.dart';
import 'package:app_plaza_flutter/repositories/repositories.dart';
import 'package:app_plaza_flutter/themes/app_theme.dart';
import 'package:app_plaza_flutter/utils/utils.dart';
import 'package:app_plaza_flutter/widgets/widgets.dart';
import 'package:flutter/material.dart' hide Table;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateTableView extends ConsumerStatefulWidget {
  const CreateTableView({super.key});

  @override
  ConsumerState<CreateTableView> createState() => _CreateTableViewState();
}

class _CreateTableViewState extends ConsumerState<CreateTableView> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _capacityCtrl = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Local? selectedLocal;
  late Future<List<Local>> _localsFuture;
  bool _isSubmitEnabled = false;

  @override
  void initState() {
    super.initState();
    _localsFuture = ref.read(localRepositoryProvider).getLocals();
    _localsFuture
        .then((locals) {
          if (!mounted) return;
          setState(() => _isSubmitEnabled = locals.isNotEmpty);
        })
        .catchError((_) {
          if (!mounted) return;
          setState(() => _isSubmitEnabled = false);
        });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _capacityCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TableRepository tableRepository = ref.watch(tableRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {},
        ),
        title: const Text(
          "Mesa",
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
                "Crear Mesa",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const Text(
                "Configura el precio de venta de este producto para el local seleccionado. Permite manejar precios diferenciados por local.",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w200,
                  color: AppTheme.tertiaryColor,
                ),
              ),
              const SizedBox(height: 20),

              // Campo: Nombre o número de mesa
              CustomTextFormField(
                label: "Nombre o número de mesa",
                hint: "Ej: Mesa 01 o Terraza 3",
                maxLength: 30,
                controller: _nameCtrl,
                icon: Icons.table_restaurant_outlined,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "El nombre o número de mesa es requerido";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Campo: Local
              const CustomFieldLabel(text: "Local"),
              FutureBuilder<List<Local>>(
                future: _localsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    final String errorMessage = snapshot.error.toString();
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'No se pudieron cargar los locales: $errorMessage',
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final List<Local> locals = snapshot.data ?? [];
                  if (locals.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(
                        'No hay locales disponibles. Crea uno primero.',
                      ),
                    );
                  }

                  return CustomDropdownButtonFormField<Local?>(
                    hint: "Selecciona un local",
                    initialValue: selectedLocal,
                    items: locals,
                    onChanged: (Local? local) {
                      setState(() {
                        selectedLocal = local;
                      });
                    },
                    validator: (Local? local) {
                      if (local == null) {
                        return "Debe seleccionar un local";
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 16),

              // Campo: Capacidad
              CustomTextFormField(
                label: "Capacidad",
                hint: "Ej: 4",
                maxLength: 3,
                controller: _capacityCtrl,
                keyboardType: TextInputType.number,
                icon: Icons.people_outline,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "La capacidad es requerida";
                  }
                  final int? capacity = int.tryParse(value.trim());
                  if (capacity == null || capacity <= 0) {
                    return "Ingrese un entero válido mayor a 0";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Botón: Asignar mesa
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isSubmitEnabled
                      ? () async {
                          if (!_formKey.currentState!.validate()) return;

                          final bool
                          isAccepted = await AppAlerts.showConfirmation(
                            context: context,
                            title: "Confirmar Acción",
                            message:
                                "¿Está seguro(a) de que desea asignar esta mesa al local seleccionado?",
                          );
                          if (!isAccepted) return;

                          final int capacity = int.parse(
                            _capacityCtrl.text.trim(),
                          );
                          final newTable = Table(
                            idLocal: selectedLocal!.uid!,
                            name: _nameCtrl.text.trim(),
                            capacity: capacity,
                            creationDate: DateTime.now(),
                            isEnable: true,
                            isOccupied: false,
                          );

                          try {
                            await tableRepository.createTable(newTable);
                            if (context.mounted) {
                              AppAlerts.showSnackbar(
                                context,
                                'Mesa "${newTable.name}" asignada correctamente.',
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              AppAlerts.showSnackbar(context, e.toString());
                            }
                          }

                          setState(() {
                            selectedLocal = null;
                          });
                          clearFields();
                        }
                      : null,
                  child: const Text(
                    "Asignar Mesa",
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
    _nameCtrl.clear();
    _capacityCtrl.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _formKey.currentState?.reset();
    });
  }
}
