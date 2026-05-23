import 'package:app_plaza_flutter/collections/firestore_collections.dart';
import 'package:app_plaza_flutter/models/local.dart';
import 'package:app_plaza_flutter/providers/firebase_provider.dart';
import 'package:app_plaza_flutter/utils/firebase_exceptions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localRepositoryProvider = Provider<LocalRepository>((ref) {
  final firestoreProvider = ref.watch(firestoreInstanceProvider);
  return LocalRepository(firestoreProvider: firestoreProvider);
});

class LocalRepository {
  final FirebaseFirestore _firestoreProvider;

  LocalRepository({required FirebaseFirestore firestoreProvider})
    : _firestoreProvider = firestoreProvider;

  // Local: Crear
  /// Crea un modelo Local en la base de datos. Lanza un error en caso de que falle.
  Future<void> createLocal(Local local) async {
    try {
      await _firestoreProvider
          .collection(FirestoreCollections.locals)
          .add(local.toMap());
    } on FirebaseException catch (e) {
      throw FirebaseExceptions.translateFirestoreException(e.code);
    } catch (e) {
      throw "Error desconocido al registrar el local.";
    }
  }

  // Local: Leer
  Future<Local> readLocal(String uid) async {
    try {
      final doc = await _firestoreProvider
          .collection(FirestoreCollections.locals)
          .doc(uid)
          .get();

      if (doc.exists) {
        return Local.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      } else {
        throw "El local solicitado no existe.";
      }
    } on FirebaseException catch (e) {
      throw FirebaseExceptions.translateFirestoreException(e.code);
    } catch (e) {
      throw "Error al obtener la información del local.";
    }
  }

  // Local: Actualizar
  Future<void> updateLocal(Local local) async {
    if (local.uid == null) throw "No se puede actualizar un local sin ID.";
    try {
      await _firestoreProvider
          .collection(FirestoreCollections.locals)
          .doc(local.uid)
          .update(local.toMap());
    } on FirebaseException catch (e) {
      throw FirebaseExceptions.translateFirestoreException(e.code);
    } catch (e) {
      throw "Error desconocido al actualizar el local.";
    }
  }

  // Local: Listar todos
  Future<List<Local>> getLocals() async {
    try {
      final querySnapshot = await _firestoreProvider
          .collection(FirestoreCollections.locals)
          //.orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => Local.fromMap(doc.data(), doc.id))
          .toList();
    } on FirebaseException catch (e) {
      throw FirebaseExceptions.translateFirestoreException(e.code);
    } catch (e) {
      throw "Error al cargar el listado de locales.";
    }
  }
}
