import 'package:app_plaza_flutter/models/models.dart';
import 'package:app_plaza_flutter/providers/providers.dart';
import 'package:app_plaza_flutter/repositories/repositories.dart';
import 'package:app_plaza_flutter/themes/app_theme.dart';
import 'package:app_plaza_flutter/utils/app_alerts.dart';
import 'package:app_plaza_flutter/widgets/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _userCtrl = TextEditingController();
  late final TextEditingController _passCtrl = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/fondologin.jpg', fit: BoxFit.cover),

          Center(
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 25),
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 40,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Ícono principal
                      const Icon(
                        Icons.restaurant_menu_outlined,
                        size: 60,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(height: 15),

                      // Títulos
                      const Text(
                        "Bienvenido(a)",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                          fontFamily: 'Georgia',
                        ),
                      ),
                      const Text(
                        "Inicia Sesión para Continuar",
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.tertiaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 35),

                      // Campo: Nombre de Usuario o Correo
                      CustomTextFormField(
                        label: "Nombre de usuario o Contraseña",
                        hint: "Ej. Brigith o brigith.cusipuma@gmail.com",
                        controller: _userCtrl,
                      ),
                      const SizedBox(height: 20),

                      // Campo: Contraseña
                      CustomTextFormField(
                        label: "Contraseña",
                        hint: "Ingresa tu contraseña",
                        controller: _passCtrl,
                        isPassword: true,
                      ),

                      const SizedBox(height: 35),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_isSubmitting) return;
                            if (!(_formKey.currentState?.validate() ?? false)) {
                              return;
                            }

                            setState(() => _isSubmitting = true);

                            // Leer repositorios: Authentication, User
                            final authRepository = ref.read(
                              authRepositoryProvider,
                            );
                            final userRepository = ref.read(
                              userRepositoryProvider,
                            );

                            // Capturar el texto de los campos
                            final email = _userCtrl.text.trim();
                            final password = _passCtrl.text;

                            final UserCredential userCredential;

                            // Consultar usuario
                            try {
                              userCredential = await authRepository.loginUser(
                                email,
                                password,
                              );
                            } catch (e) {
                              if (context.mounted) {
                                AppAlerts.showSnackbar(context, e.toString());
                                debugPrint("Error en logeo");
                              }
                              if (mounted) {
                                setState(() => _isSubmitting = false);
                              }
                              return;
                            }

                            // Validar que contenga usuario
                            if (userCredential.user == null) {
                              if (context.mounted) {
                                AppAlerts.showSnackbar(
                                  context,
                                  "No se ha encontrado usuario",
                                );
                                debugPrint("Error de usuario nulo");
                              }
                              if (mounted) {
                                setState(() => _isSubmitting = false);
                              }
                              return;
                            }

                            // Consultar datos de usuario
                            final User user;

                            try {
                              user = await userRepository.readUser(
                                userCredential.user!.uid,
                              );
                            } catch (e) {
                              if (context.mounted) {
                                AppAlerts.showSnackbar(context, e.toString());
                                debugPrint(
                                  "Error al consultar datos de usuario",
                                );
                              }
                              if (mounted) {
                                setState(() => _isSubmitting = false);
                              }
                              return;
                            }

                            // Validar que el usuario esté activo
                            if (!user.isActive) {
                              if (context.mounted) {
                                AppAlerts.showInformation(
                                  context,
                                  "Usuario Inhabilitado",
                                  "Este usuario se encuentra inhabilitado para realizar acciones dentro de la aplicación.",
                                );
                              }
                              if (mounted) {
                                setState(() => _isSubmitting = false);
                              }
                              return;
                            }

                            // Limpiar campos antes de cambiar pantalla (si más adelante navegas).
                            _userCtrl.clear();
                            _passCtrl.clear();

                            if (mounted) setState(() => _isSubmitting = false);
                            // NOTA: ¿Por qué no es necesario cargar los datos del usuario en este punto?
                            // Porque hay un provider que está escuchando el estado de autenticación. Si
                            // el usuario está autenticado el provider carga en automático.
                            await Future.delayed(const Duration(seconds: 3));

                            final sessionData = await ref.read(
                              sessionDataProvider.future,
                            );
                            if (sessionData != null) {
                              debugPrint(
                                "Usuario ingresado: ${sessionData.user}, UID: ${sessionData.firebaseUid}",
                              );
                            } else {
                              debugPrint("El valor del Provider es nulo.");
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 5,
                          ),
                          child: const Text(
                            "Iniciar Sesión",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Logo Inferior
                      Image.asset('assets/images/iconodelgado.png', height: 60),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
