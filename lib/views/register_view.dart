import 'package:app_plaza_flutter/models/models.dart';
import 'package:app_plaza_flutter/repositories/repositories.dart';
import 'package:app_plaza_flutter/themes/app_theme.dart';
import 'package:app_plaza_flutter/widgets/custom_text_form_field.dart';
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

  late Future<List<Local>> _localsFuture;
  late Future<List<Role>> _rolesFuture;

  @override
  void initState() {
    super.initState();
    _localsFuture = ref.read(localRepositoryProvider).getLocals();
    _rolesFuture = ref.read(roleRepositoryProvider).getRoles();
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
                      backgroundColor: Color(0xFF701321),
                      backgroundImage: AssetImage(
                        'assets/images/iconoregister.png',
                      ),
                    ),
                  ),
                  // Espacio
                  const SizedBox(height: 30),
                  // Tarjeta
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
                        Row(
                          children: [
                            const Icon(
                              Icons.star_border,
                              color: Color(0xFF701321),
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
                                    color: Color(0xFF701321),
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

                        // Campo: Usuario
                        CustomTextFormField(
                          label: "Usuario",
                          hint: "Ej: Brigith.Cusipuma",
                          controller: _userCtrl,
                        ),
                        // Campo: Contraseña
                        CustomTextFormField(
                          label: "Contraseña",
                          hint: "**********",
                          controller: _passCtrl,
                          isPassword: true,
                        ),
                        // Campo: Repetir contraseña
                        CustomTextFormField(
                          label: "Repetir Contraseña",
                          hint: "**********",
                          controller: _repeatPassCtrl,
                          isPassword: true,
                        ),
                        // Campo: Nombres
                        CustomTextFormField(
                          label: "Nombre(s)",
                          hint: "Ej: Brigith",
                          controller: _nameCtrl,
                        ),
                        // Campo: Apellidos
                        CustomTextFormField(
                          label: "Apellido(s)",
                          hint: "Ej: Cusipuma Candela",
                          controller: _lastNameCtrl,
                        ),
                        // Campo: Correo Electrónico
                        CustomTextFormField(
                          label: "Correo Electrónico",
                          hint: "Ej: correo@gmail.com",
                          controller: _emailCtrl,
                        ),

                        // Campo seleccionable: Local
                        _buildLabel("Local"),
                        FutureBuilder<List<Local>>(
                          future: _localsFuture,
                          builder: (context, snapshot) {
                            // Esperando...
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16.0),
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
                              // TODO: Bloquear al botón de envío de formulario.
                            }

                            // Mostrar: En caso de lista vacía.
                            final List<Local> locals = snapshot.data ?? [];
                            if (locals.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16.0),
                                child: Text(
                                  'No hay locales disponibles. Crea uno primero.',
                                ),
                              );
                              // TODO: Bloquear envío de formulario.
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
                        _buildLabel("Rol"),
                        FutureBuilder<List<Role>>(
                          future: _rolesFuture,
                          builder: (context, snapshot) {
                            // Esperando...
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16.0),
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
                              // TODO: Bloquear al botón de envío de formulario.
                            }

                            // Mostrar: En caso de lista vacía.
                            final List<Role> roles = snapshot.data ?? [];
                            if (roles.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16.0),
                                child: Text(
                                  'No hay roles disponibles. Crea uno primero.',
                                ),
                              );
                              // TODO: Bloquear envío de formulario.
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
                                // Validar no-nulo
                                if (role == null) {
                                  return "Debe seleccionar un local";
                                }
                                return null;
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 25),

                        // Botón Switch: Usuario Activo
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

                        // Botón: Registrar usuario
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            // Registrar un usuario
                            onPressed: () async {
                              final username = _userCtrl.text;
                              final name = _nameCtrl.text;
                              final lastname = _lastNameCtrl.text;
                              final email = _emailCtrl.text;
                              final password = _passCtrl.text;

                              String uid = await authRepository.registerUser(
                                email,
                                password,
                              );

                              // TODO: Leer rol y colocar uid
                              // TODO: Leer local y color uid

                              final user = User(
                                idRol: selectedRol!.uid!,
                                idLocal: selectedLocal!.uid!,
                                username: username,
                                name: name,
                                lastname: lastname,
                                email: email,
                                isActive: isUserActive,
                              );

                              userRepository.createUser(user, uid);
                            },
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

  /// Construye un 'Label' simple para texto.
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
}

class CustomDropdownButtonFormField<T> extends StatefulWidget {
  final String hint;
  final T initialValue;
  final List<T> items;
  final void Function(T? value)? onChanged;
  final String? Function(T? value)? validator;
  final Icon icon;

  const CustomDropdownButtonFormField({
    super.key,
    required this.hint,
    required this.initialValue,
    required this.items,
    this.validator,
    this.onChanged,
    this.icon = const Icon(Icons.arrow_drop_down, color: AppTheme.primaryColor),
  });

  @override
  State<CustomDropdownButtonFormField<T>> createState() =>
      _CustomDropdownButtonFormFieldState<T>();
}

class _CustomDropdownButtonFormFieldState<T>
    extends State<CustomDropdownButtonFormField<T>> {
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      hint: Text(widget.hint),
      initialValue: widget.initialValue,
      items: widget.items.map((T element) {
        return DropdownMenuItem(
          value: element,
          child: Text(element.toString()),
        );
      }).toList(),
      onChanged: widget.onChanged,
      validator: widget.validator,
      icon: widget.icon,
    );
  }
}
