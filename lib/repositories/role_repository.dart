import 'package:app_plaza_flutter/models/role.dart';
import 'package:app_plaza_flutter/utils/firebase_exceptions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../collections/firestore_collections.dart';
import '../providers/providers.dart';

// Provider del Repositorio de los Roles
final roleRepositoryProvider = Provider<RoleRepository>((ref) {
  final firestoreProvider = ref.watch(firestoreInstanceProvider);
  return RoleRepository(firestoreProvider: firestoreProvider);
});

class RoleRepository {
  final FirebaseFirestore _firestoreProvider;

  RoleRepository({required FirebaseFirestore firestoreProvider})
    : _firestoreProvider = firestoreProvider;

  // Rol: Crear
  Future<void> createRole(Role role) async {
    try {
      await _firestoreProvider
          .collection(
            FirestoreCollections.roles,
          ) // Asumiendo que existe en tus collections
          .add(role.toMap());
    } on FirebaseException catch (e) {
      throw FirebaseExceptions.translateFirestoreException(e.code);
    } catch (e) {
      throw "Error desconocido al crear el rol.";
    }
  }

  // Rol: Leer
  Future<Role> readRole(String uid) async {
    try {
      final doc = await _firestoreProvider
          .collection(FirestoreCollections.roles)
          .doc(uid)
          .get();

      if (doc.exists) {
        return Role.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      } else {
        throw "El rol solicitado no existe.";
      }
    } on FirebaseException catch (e) {
      throw FirebaseExceptions.translateFirestoreException(e.code);
    } catch (e) {
      throw "Error al obtener los datos del rol.";
    }
  }

  // Rol: Listar todas
  Future<List<Role>> getRoles() async {
    try {
      final querySnapshot = await _firestoreProvider
          .collection(FirestoreCollections.roles)
          //.orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => Role.fromMap(doc.data(), doc.id))
          .toList();
    } on FirebaseException catch (e) {
      throw FirebaseExceptions.translateFirestoreException(e.code);
    } catch (e) {
      throw "Error al cargar el listado de roles.";
    }
  }
}
