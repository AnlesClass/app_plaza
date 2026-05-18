import 'package:app_plaza_flutter/models/models.dart';
import 'package:app_plaza_flutter/providers/firebase_provider.dart';
import 'package:app_plaza_flutter/collections/firestore_collections.dart';
import 'package:app_plaza_flutter/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final firestoreProvider = ref.watch(firestoreInstanceProvider);
  return UserRepository(firestoreProvider: firestoreProvider);
});

class UserRepository {
  final FirebaseFirestore _firestoreProvider;

  UserRepository({required FirebaseFirestore firestoreProvider})
    : _firestoreProvider = firestoreProvider;

  // Usuario: Crear
  /// Crear a un usuario en Firestore con el mismo **UID** que su cuenta hecha
  /// con Authentication.
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
