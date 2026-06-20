import 'package:app_plaza_flutter/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_plaza_flutter/providers/providers.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final auth = ref.watch(firebaseAuthInstanceProvider);
  return AuthRepository(auth: auth);
});

class AuthRepository {
  final FirebaseAuth _auth;

  AuthRepository({required FirebaseAuth auth}) : _auth = auth;

  // Usuario: Iniciar Sesión
  /// Inicia una sesión de usuario con su **correo** y **contraseña**.
  Future<UserCredential> loginUser(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);
      return userCredential;
    } on FirebaseAuthException catch (authException) {
      throw FirebaseExceptions.translateFirebaseAuthException(
        authException.code,
      );
    } catch (e) {
      throw "Ocurrió un error inesperado.";
    }
  }

  // Usuario: Registrar
  /// Registra al usuario en la aplicación con correo y contraseña. Retorna el
  /// **UID** del usuario registrado.
  Future<String> registerUser(String email, String password) async {
    try {
      // Crear usuario y obtener credencial.
      final UserCredential userCrendetial = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      // Validar uid.
      if (userCrendetial.user == null) throw "No se pudo crear usuario";
      // Devolver uid.
      return userCrendetial.user!.uid;
    } on FirebaseAuthException catch (authException) {
      throw FirebaseExceptions.translateFirebaseAuthException(
        authException.code,
      );
    } catch (e) {
      throw "Error al intentar registrar el usuario.";
    }
  }

  /// Salir de la sesión actual
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
