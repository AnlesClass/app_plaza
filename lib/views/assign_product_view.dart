import 'package:app_plaza_flutter/models/models.dart';
import 'package:app_plaza_flutter/repositories/repositories.dart';
import 'package:app_plaza_flutter/router/app_router.dart';
import 'package:app_plaza_flutter/themes/app_theme.dart';
import 'package:app_plaza_flutter/utils/utils.dart';
import 'package:app_plaza_flutter/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

class AssignProductView extends ConsumerStatefulWidget {
  const AssignProductView({super.key});

  @override
  ConsumerState<AssignProductView> createState() => _AssignProductViewState();
}

class _AssignProductViewState extends ConsumerState<AssignProductView> {
  final TextEditingController _priceCtrl = TextEditingController();
  final TextEditingController _dateCtrl = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Product? _selectedProduct;
  Local? _selectedLocal;

  bool _isBlocked = true;

  List<Product> _products = [];
  List<Local> _locals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _priceCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final productRepo = ref.read(productRepositoryProvider);
      final localRepo = ref.read(localRepositoryProvider);

      final products = await productRepo.getAllProducts();
      final locals = await localRepo.getLocals();

      setState(() {
        _products = products;
        _locals = locals;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        AppAlerts.showSnackbar(context, "Error al cargar datos: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          "Asignar Producto",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                    CustomDropdownButtonFormField<Product>(
                      hint: "Selecciona un producto",
                      initialValue: _selectedProduct,
                      items: _products,
                      validator: (value) {
                        if (value == null) {
                          return "Debe seleccionar un producto";
                        }
                        return null;
                      },
                      onChanged: (product) {
                        setState(() {
                          _selectedProduct = product;
                        });
                      },
                    ),
                    const SizedBox(height: 25),

                    _buildLabel("Local"),
                    CustomDropdownButtonFormField<Local>(
                      hint: "Selecciona un local",
                      initialValue: _selectedLocal,
                      items: _locals,
                      validator: (value) {
                        if (value == null) {
                          return "Debe seleccionar un local";
                        }
                        return null;
                      },
                      onChanged: (local) {
                        setState(() {
                          _selectedLocal = local;
                        });
                      },
                    ),
                    const SizedBox(height: 25),

                    CustomTextFormField(
                      label: "Precio",
                      hint: "0.00",
                      controller: _priceCtrl,
                      icon: Icons.sell_outlined,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "El precio es requerido";
                        }
                        final price = double.tryParse(value);
                        if (price == null || price <= 0) {
                          return "Ingrese un precio válido mayor a 0";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 25),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Iniciar Bloqueado",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Switch(
                          value: _isBlocked,
                          activeThumbColor: Colors.white,
                          activeTrackColor: AppTheme.primaryColor,
                          onChanged: (value) {
                            setState(() {
                              _isBlocked = value;
                              if (!_isBlocked) {
                                _dateCtrl.clear();
                              }
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
                        readOnly: true,
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (date != null) {
                            setState(() {
                              _dateCtrl.text = _formatDate(date);
                            });
                          }
                        },
                        validator: (value) {
                          if (_isBlocked &&
                              (value == null || value.trim().isEmpty)) {
                            return "Debe seleccionar una fecha de bloqueo";
                          }
                          return null;
                        },
                      ),

                    const SizedBox(height: 40),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSubmit,
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

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProduct == null || _selectedLocal == null) return;

    final bool isAccepted = await AppAlerts.showConfirmation(
      context: context,
      title: "Confirmar Acción",
      message:
          "¿Está seguro(a) de que desea asignar '${_selectedProduct!.name}' al local '${_selectedLocal!.name}'?",
    );

    if (!isAccepted) return;

    final price = double.parse(_priceCtrl.text.trim());
    final blockLimit = _isBlocked && _dateCtrl.text.isNotEmpty
        ? _parseDate(_dateCtrl.text)
        : DateTime.now();

    final newLocalProduct = LocalProduct(
      idLocal: _selectedLocal!.uid!,
      idProduct: _selectedProduct!.uid!,
      prize: price,
      isBlocked: _isBlocked,
      blockLimit: blockLimit,
    );

    try {
      final localProductRepository = ref.read(localProductRepositoryProvider);
      await localProductRepository.createLocalProduct(newLocalProduct);

      if (mounted) {
        AppAlerts.showSnackbar(context, "Producto asignado correctamente.");
        _clearFields();
      }
    } catch (e) {
      if (mounted) {
        AppAlerts.showSnackbar(context, e.toString());
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  DateTime _parseDate(String dateStr) {
    final parts = dateStr.split('/');
    return DateTime(
      int.parse(parts[2]),
      int.parse(parts[1]),
      int.parse(parts[0]),
    );
  }

  void _clearFields() {
    _priceCtrl.clear();
    _dateCtrl.clear();
    setState(() {
      _selectedProduct = null;
      _selectedLocal = null;
      _isBlocked = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _formKey.currentState?.reset();
    });
  }
}
