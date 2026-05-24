import 'package:app_plaza_flutter/models/models.dart';
import 'package:app_plaza_flutter/repositories/repositories.dart';
import 'package:app_plaza_flutter/themes/app_theme.dart';
import 'package:app_plaza_flutter/utils/utils.dart';
import 'package:app_plaza_flutter/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisterView extends ConsumerStatefulWidget {
  const RegisterView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _RegisterViewState();
}

class _RegisterViewState extends ConsumerState<RegisterView> {
  bool isUserActive = true;
  Local? selectedLocal;
  Role? selectedRol;

  final TextEditingController _userCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  final TextEditingController _repeatPassCtrl = TextEditingController();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _lastNameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late Future<List<Local>> _localsFuture;
  late Future<List<Role>> _rolesFuture;
  bool _isSubmitEnabled = false;
  bool _hasLocals = false;
  bool _hasRoles = false;

  @override
  void initState() {
    super.initState();
    _localsFuture = ref.read(localRepositoryProvider).getLocals();
    _rolesFuture = ref.read(roleRepositoryProvider).getRoles();

    _localsFuture
        .then((locals) {
          if (!mounted) return;
          _updateSubmitState(hasLocals: locals.isNotEmpty);
        })
        .catchError((_) {
          if (!mounted) return;
          _updateSubmitState(hasLocals: false);
        });

    _rolesFuture
        .then((roles) {
          if (!mounted) return;
          _updateSubmitState(hasRoles: roles.isNotEmpty);
        })
        .catchError((_) {
          if (!mounted) return;
          _updateSubmitState(hasRoles: false);
        });
  }

  void _updateSubmitState({bool? hasLocals, bool? hasRoles}) {
    if (hasLocals != null) _hasLocals = hasLocals;
    if (hasRoles != null) _hasRoles = hasRoles;
    final bool enabled = _hasLocals && _hasRoles;
    if (_isSubmitEnabled == enabled) return;
    setState(() => _isSubmitEnabled = enabled);
  }

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
    final AuthRepository authRepository = ref.read(authRepositoryProvider);
    final UserRepository userRepository = ref.read(userRepositoryProvider);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Imagen de Fondo
          Image.asset('assets/images/fondologin.jpg', fit: BoxFit.cover),
          // Todo el resto
          Positioned.fill(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  // Logo
                  Container(
                    width: 111,
                    height: 111,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const CircleAvatar(
                      backgroundColor: AppTheme.primaryColor,
                      backgroundImage: AssetImage(
                        'assets/images/iconoregister.png',
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Container Card
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 35,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Título y descripción
                        Row(
                          children: [
                            const Icon(
                              Icons.star_border,
                              color: AppTheme.primaryColor,
                              size: 28,
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Crear Usuario",
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                                Text(
                                  "Crear un nuevo usuario para su local",
                                  style: TextStyle(
                                    color: Colors.orange.shade800,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),

                        // Formulario
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Campo: Usuario
                              CustomTextFormField(
                                label: "Usuario",
                                hint: "Ej: Brigith.Cusipuma",
                                controller: _userCtrl,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "El usuario es requerido";
                                  }
                                  if (value.trim().length < 3) {
                                    return "El usuario debe tener al menos 3 caracteres";
                                  }
                                  return null;
                                },
                              ),

                              // Campo: Contraseña
                              CustomTextFormField(
                                label: "Contraseña",
                                hint: "**********",
                                controller: _passCtrl,
                                isPassword: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "La contraseña es requerida";
                                  }
                                  if (value.length < 6) {
                                    return "La contraseña debe tener al menos 6 caracteres";
                                  }
                                  return null;
                                },
                              ),

                              // Campo: Repetir Contraseña
                              CustomTextFormField(
                                label: "Repetir Contraseña",
                                hint: "**********",
                                controller: _repeatPassCtrl,
                                isPassword: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Debe repetir la contraseña";
                                  }
                                  if (value != _passCtrl.text) {
                                    return "Las contraseñas no coinciden";
                                  }
                                  return null;
                                },
                              ),

                              // Campo: Nombre(s)
                              CustomTextFormField(
                                label: "Nombre(s)",
                                hint: "Ej: Brigith",
                                controller: _nameCtrl,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "El nombre es requerido";
                                  }
                                  return null;
                                },
                              ),

                              // Campo: Apellido(s)
                              CustomTextFormField(
                                label: "Apellido(s)",
                                hint: "Ej: Cusipuma Candela",
                                controller: _lastNameCtrl,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "El apellido es requerido";
                                  }
                                  return null;
                                },
                              ),

                              // Campo: Correo Electrónico
                              CustomTextFormField(
                                label: "Correo Electrónico",
                                hint: "Ej: correo@gmail.com",
                                controller: _emailCtrl,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "El correo electrónico es requerido";
                                  }
                                  final emailRegex = RegExp(
                                    r'^[^@]+@[^@]+\.[^@]+$',
                                  );
                                  if (!emailRegex.hasMatch(value.trim())) {
                                    return "Ingrese un correo electrónico válido";
                                  }
                                  return null;
                                },
                              ),

                              // Campo seleccionable: Local
                              const CustomFieldLabel(text: "Local"),
                              FutureBuilder<List<Local>>(
                                future: _localsFuture,
                                builder: (context, snapshot) {
                                  // Esperando...
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 16.0,
                                      ),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          color: AppTheme.primaryColor,
                                        ),
                                      ),
                                    );
                                  }

                                  // En caso de error...
                                  if (snapshot.hasError) {
                                    final String errorMessage = snapshot.error
                                        .toString();
                                    // TODO: Mostrar error de alguna forma.
                                    // TEST: Padding para mostrar error.
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16.0,
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.error_outline,
                                            color: Colors.red,
                                          ),
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

                                  // Mostrar: En caso de lista vacía.
                                  final List<Local> locals =
                                      snapshot.data ?? [];
                                  if (locals.isEmpty) {
                                    return const Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 16.0,
                                      ),
                                      child: Text(
                                        'No hay locales disponibles. Crea uno primero.',
                                      ),
                                    );
                                  }

                                  // Mostrar: En caso de lista con elementos.
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
                                      // Validar no-nulo
                                      if (local == null) {
                                        return "Debe seleccionar un local";
                                      }
                                      return null;
                                    },
                                  );
                                },
                              ),
                              const SizedBox(height: 25),

                              // Campo seleccionable: Rol
                              const CustomFieldLabel(text: "Rol"),
                              FutureBuilder<List<Role>>(
                                future: _rolesFuture,
                                builder: (context, snapshot) {
                                  // Esperando...
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 16.0,
                                      ),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          color: AppTheme.primaryColor,
                                        ),
                                      ),
                                    );
                                  }

                                  // En caso de error...
                                  if (snapshot.hasError) {
                                    final String errorMessage = snapshot.error
                                        .toString();
                                    // TODO: Mostrar error de alguna forma.
                                    // TEST: Padding para mostrar error.
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16.0,
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.error_outline,
                                            color: Colors.red,
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              'No se pudieron cargar los roles: $errorMessage',
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

                                  // Mostrar: En caso de lista vacía.
                                  final List<Role> roles = snapshot.data ?? [];
                                  if (roles.isEmpty) {
                                    return const Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 16.0,
                                      ),
                                      child: Text(
                                        'No hay roles disponibles. Crea uno primero.',
                                      ),
                                    );
                                  }

                                  // Mostrar: En caso de lista con elementos.
                                  return CustomDropdownButtonFormField<Role?>(
                                    hint: "Selecciona un rol",
                                    initialValue: selectedRol,
                                    items: roles,
                                    onChanged: (Role? role) {
                                      setState(() {
                                        selectedRol = role;
                                      });
                                    },
                                    validator: (Role? role) {
                                      if (role == null) {
                                        return "Debe seleccionar un rol";
                                      }
                                      return null;
                                    },
                                  );
                                },
                              ),
                              const SizedBox(height: 25),

                              // Botón Switch: Usuario activo en el sistema
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Usuario activo en el sistema",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Switch(
                                    value: isUserActive,
                                    activeThumbColor: Colors.white,
                                    activeTrackColor: AppTheme.primaryColor,
                                    onChanged: (value) {
                                      setState(() {
                                        isUserActive = value;
                                      });
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 35),

                              // Botón: Registrar Usuario
                              SizedBox(
                                width: double.infinity,
                                height: 55,
                                child: ElevatedButton(
                                  onPressed: _isSubmitEnabled
                                      ? () async {
                                          if (!_formKey.currentState!
                                              .validate()) {
                                            return;
                                          }

                                          final username = _userCtrl.text
                                              .trim();
                                          final name = _nameCtrl.text.trim();
                                          final lastname = _lastNameCtrl.text
                                              .trim();
                                          final email = _emailCtrl.text.trim();
                                          final password = _passCtrl.text;

                                          // Intentar registrar usuario en Auth

                                          late final String uid;
                                          try {
                                            uid = await authRepository
                                                .registerUser(email, password);
                                          } catch (e) {
                                            if (context.mounted) {
                                              AppAlerts.showSnackbar(
                                                context,
                                                e.toString(),
                                                isError: true,
                                              );
                                              return;
                                            }
                                          }

                                          final user = User(
                                            idRol: selectedRol!.uid!,
                                            idLocal: selectedLocal!.uid!,
                                            username: username,
                                            name: name,
                                            lastname: lastname,
                                            email: email,
                                            isActive: isUserActive,
                                          );

                                          await userRepository.createUser(
                                            user,
                                            uid,
                                          );

                                          _clearFields();
                                        }
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF701321),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    elevation: 2,
                                  ),
                                  child: const Text(
                                    "Registrar Usuario",
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
              backgroundColor: Colors.white.withValues(alpha: 0.3),
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

  void _clearFields() {
    _userCtrl.clear();
    _passCtrl.clear();
    _repeatPassCtrl.clear();
    _nameCtrl.clear();
    _lastNameCtrl.clear();
    _emailCtrl.clear();
    selectedLocal = null;
    selectedRol = null;
    isUserActive = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _formKey.currentState?.reset();
    });
  }
}
