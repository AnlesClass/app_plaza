import 'package:app_plaza_flutter/collections/cloud_functions_names.dart';
import 'package:app_plaza_flutter/models/models.dart';
import 'package:app_plaza_flutter/providers/firebase_providers.dart';
import 'package:app_plaza_flutter/collections/firestore_collections.dart';
import 'package:app_plaza_flutter/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider del Repositorio de Usuario
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final firestoreProvider = ref.read(firestoreInstanceProvider);
  final firebaseFunctions = ref.read(firebaseFunctionsInstanceProvider);
  return UserRepository(
    firestoreProvider: firestoreProvider,
    firebaseFunctions: firebaseFunctions,
  );
});

class UserRepository {
  final FirebaseFirestore _firestoreProvider;
  final FirebaseFunctions _firebaseFunctions;

  UserRepository({
    required FirebaseFirestore firestoreProvider,
    required FirebaseFunctions firebaseFunctions,
  }) : _firebaseFunctions = firebaseFunctions,
       _firestoreProvider = firestoreProvider;

  // Usuario: Crear
  /// Crear a un usuario en Firestore con el mismo **UID** que su cuenta hecha
  /// con Authentication.
  /// Problema: Inicia sesión en Auth con la cuenta que se acaba de crear.
  Future<void> createUser(User user, String uid) async {
    try {
      await _firestoreProvider
          .collection(FirestoreCollections.users)
          .doc(uid)
          .set(user.toMap(), SetOptions(merge: true));
    } on FirebaseException catch (firestoreException) {
      throw FirebaseExceptions.translateFirestoreException(
        firestoreException.code,
      );
    } catch (e) {
      throw "Error desconocido al guardar usuario.";
    }
  }

  // Usuario: Crear con Cloud Functions
  /// Crea un usuario a través de Cloud Functions de Firebase, esto permite crear
  /// un usuario sin iniciar una sesión
  Future<void> createUserWithCloudFunction(User user, String password) async {
    try {
      // Llamar a la Cloud Function: Función 'Crear Usuario'
      final result = await _firebaseFunctions
          .httpsCallable(CloudFunctionsNames.createUser)
          .call({
            'email': user.email,
            'password': password,
            'username': user.username,
            'name': user.name,
            'lastname': user.lastname,
            'idLocal': user.idLocal,
            'idRole': user.idRole,
            'isActive': user.isActive,
          });

      // Verificar resultado
      final data = result.data as Map<String, dynamic>;

      // En NO sea exitoso. Lanzar excepción.
      if (!data['success']) {
        throw Exception(data['message'] ?? "Error al crear usuario");
      }
    } on FirebaseFunctionsException catch (e) {
      debugPrint("¿Ahora qué? : $e");
      throw FirebaseExceptions.translateFirestoreException(e.code);
    } catch (e) {
      throw "Error inesperado: $e";
    }
  }

  // Usuario: Actualizar
  /// Actualiza la información del usuario en base a su **UID**
  Future<void> updateUser(User user, String uid) async {
    try {
      await _firestoreProvider
          .collection(FirestoreCollections.users)
          .doc(uid)
          .update(user.toMap());
    } on FirebaseException catch (e) {
      throw FirebaseExceptions.translateFirestoreException(e.code);
    } catch (e) {
      throw "Error desconocido al actualizar usuario.";
    }
  }

  // Usuario: Leer
  /// Devuelve la información del usuario basado en un **UID**.
  Future<User> readUser(String uid) async {
    try {
      final DocumentSnapshot documentSnapshot = await _firestoreProvider
          .collection(FirestoreCollections.users)
          .doc(uid)
          .get();
      // Validar que exista
      if (documentSnapshot.exists) {
        // Devolver el usuario
        final data = documentSnapshot.data() as Map<String, dynamic>;
        return User.fromMap(data, documentSnapshot.id);
      } else {
        throw "El usuario solicitado no existe.";
      }
    } on FirebaseException catch (e) {
      throw FirebaseExceptions.translateFirestoreException(e.code);
    } catch (e) {
      throw "Error al obtener los datos del usuario.";
    }
  }
}
