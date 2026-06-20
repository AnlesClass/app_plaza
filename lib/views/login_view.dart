import 'package:app_plaza_flutter/models/models.dart';
import 'package:app_plaza_flutter/providers/providers.dart';
import 'package:app_plaza_flutter/repositories/repositories.dart';
import 'package:app_plaza_flutter/themes/app_theme.dart';
import 'package:app_plaza_flutter/utils/app_alerts.dart';
import 'package:app_plaza_flutter/widgets/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// VISTA: Logeo de un usuario registrado en el sistema por el administrador.
class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  // Variables Globales
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
    // Providers: Observar cambio en sesión activa,
    final sessionDataAsync = ref.watch(sessionDataProvider);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Imagen: Fondo de pantalla
          Image.asset('assets/images/fondologin.jpg', fit: BoxFit.cover),
          // Tarjeta: Formulario de Inicio de Sesión
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
                      // ------ INICIO DEL DEBUG ------
                      // Widget Genérico: En base a datos de la sesión actual.
                      sessionDataAsync.when(
                        data: (sessionData) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            sessionData == null
                                ? '[debug] sessionData: null (sin sesión)'
                                : '[debug] sessionData:\n'
                                      '  uid: ${sessionData.firebaseUid}\n'
                                      '  usuario: ${sessionData.user.username}\n'
                                      '  local: ${sessionData.user.idLocal}\n'
                                      '  rol: ${sessionData.user.idRole}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        loading: () => const Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: Text(
                            '[debug] sessionData: cargando...',
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ),
                        error: (error, _) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            '[debug] sessionData error: $error',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.red,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      // ------ FIN DEL DEBUG ------

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

                      // Botón: Inicio de Sesión
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () async {
                            // Retornar si ya se está enviando
                            if (_isSubmitting) return;
                            // Retornar si el formulario no es válido
                            if (!(_formKey.currentState?.validate() ?? false)) {
                              return;
                            }
                            // De no ser el caso, cambiar estado a "True"
                            setState(() => changeSubmitState(true));

                            // Leer providers: repositorio Auth, User y GoRouter
                            final authRepository = ref.read(
                              authRepositoryProvider,
                            );
                            final userRepository = ref.read(
                              userRepositoryProvider,
                            );

                            // Capturar el texto de los campos
                            final email = _userCtrl.text.trim();
                            final password = _passCtrl.text;
                            // Crear credencial de usuario (nula)
                            final UserCredential userCredential;

                            // Intentar consultar usuario
                            try {
                              userCredential = await authRepository.loginUser(
                                email,
                                password,
                              );
                            } catch (e) {
                              // Mensaje: El usuario no pudo iniciar sesión. Si el contexto está montado
                              if (context.mounted) {
                                AppAlerts.showSnackbar(context, e.toString());
                              }
                              // Se establece el estado de envío a false.
                              if (mounted) {
                                setState(() => changeSubmitState(false));
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
                              }
                              if (mounted) {
                                setState(() => changeSubmitState(false));
                              }
                              return;
                            }

                            // Crear modelo de Usuario (nulo)
                            final User user;
                            // Intentar consultar datos de usuario
                            try {
                              user = await userRepository.readUser(
                                userCredential.user!.uid,
                              );
                            } catch (e) {
                              // Lanzar mensaje en caso de error
                              if (context.mounted) {
                                AppAlerts.showSnackbar(context, e.toString());
                              }
                              // Cambiar estado de envío a "False"
                              if (mounted) {
                                setState(() => changeSubmitState(false));
                              }
                              return;
                            }

                            // Validar que el usuario esté activo
                            if (!user.isActive) {
                              // Lanzar mensaje en caso de Inactivo
                              if (context.mounted) {
                                AppAlerts.showInformation(
                                  context,
                                  "Usuario Inhabilitado",
                                  "Este usuario se encuentra inhabilitado para realizar acciones dentro de la aplicación.",
                                );
                              }
                              // Cambiar estado de envío de formulario a "False"
                              if (mounted) {
                                setState(() => changeSubmitState(false));
                              }
                              return;
                            }

                            // Limpiar campos antes de cambiar pantalla.
                            _userCtrl.clear();
                            _passCtrl.clear();

                            // Dejar el estado de "Enviando"
                            if (mounted) {
                              setState(() => changeSubmitState(false));
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

  /// Cambia el estado de enviando/no enviando del formulario.
  void changeSubmitState(bool value) {
    _isSubmitting = value;
  }
}
