// repositories/local_product_repository.dart
import 'package:app_plaza_flutter/collections/firestore_collections.dart';
import 'package:app_plaza_flutter/models/local_product.dart';
import 'package:app_plaza_flutter/providers/firebase_providers.dart';
import 'package:app_plaza_flutter/utils/firebase_exceptions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ### PROVIDERS DE PRODUCTOS EN LOCAL ###

/// Repositorio de "Local-Products"
final localProductRepositoryProvider = Provider<LocalProductRepository>((ref) {
  final firestoreProvider = ref.watch(firestoreInstanceProvider);
  return LocalProductRepository(firestoreProvider: firestoreProvider);
});

/// Provider que escucha los productos de un local específico (en streaming)
final streamProductsByLocalProvider =
    StreamProvider.family<List<LocalProduct>, String>((ref, localId) {
      final repository = ref.watch(localProductRepositoryProvider);
      return repository.streamLocalProductsByLocal(localId);
    });

/// Provider que devuelve los productos de un local específico (future)
final getLocalProductsByLocalProvider =
    FutureProvider.family<List<LocalProduct>, String>((ref, localId) {
      final repository = ref.watch(localProductRepositoryProvider);
      return repository.getLocalProductsByLocal(localId);
    });

/// Clase de repositorio que gestiona la interacción de productos de un local con la base
/// de datos Firestore.
class LocalProductRepository {
  final FirebaseFirestore _firestoreProvider;

  LocalProductRepository({required FirebaseFirestore firestoreProvider})
    : _firestoreProvider = firestoreProvider;

  /// LocalProduct: Crear asignación
  Future<void> createLocalProduct(LocalProduct localProduct) async {
    try {
      await _firestoreProvider
          .collection(FirestoreCollections.localProducts)
          .add(localProduct.toMap());
    } on FirebaseException catch (e) {
      throw FirebaseExceptions.translateFirestoreException(e.code);
    } catch (e) {
      throw "Error desconocido al asignar el producto al local.";
    }
  }

  /// LocalProduct: Leer por ID
  Future<LocalProduct?> readLocalProduct(String uid) async {
    try {
      final doc = await _firestoreProvider
          .collection(FirestoreCollections.localProducts)
          .doc(uid)
          .get();

      if (doc.exists) {
        return LocalProduct.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } on FirebaseException catch (e) {
      throw FirebaseExceptions.translateFirestoreException(e.code);
    } catch (e) {
      throw "Error al obtener la información del producto asignado.";
    }
  }

  /// LocalProduct: Stream de productos por local
  Stream<List<LocalProduct>> streamLocalProductsByLocal(String idLocal) {
    try {
      return _firestoreProvider
          .collection(FirestoreCollections.localProducts)
          .where('idLocal', isEqualTo: idLocal)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => LocalProduct.fromMap(doc.data(), doc.id))
                .toList(),
          );
    } catch (e) {
      throw "Error al obtener stream de productos del local: $e";
    }
  }

  /// LocalProduct: Leer todos los productos de un local (una sola vez)
  Future<List<LocalProduct>> getLocalProductsByLocal(String idLocal) async {
    try {
      final querySnapshot = await _firestoreProvider
          .collection(FirestoreCollections.localProducts)
          .where('idLocal', isEqualTo: idLocal)
          .get();

      return querySnapshot.docs
          .map((doc) => LocalProduct.fromMap(doc.data(), doc.id))
          .toList();
    } on FirebaseException catch (e) {
      throw FirebaseExceptions.translateFirestoreException(e.code);
    } catch (e) {
      throw "Error al cargar los productos del local.";
    }
  }

  /// LocalProduct: Actualizar
  Future<void> updateLocalProduct(LocalProduct localProduct) async {
    if (localProduct.uid == null) throw "No se puede actualizar sin ID.";
    try {
      await _firestoreProvider
          .collection(FirestoreCollections.localProducts)
          .doc(localProduct.uid)
          .update(localProduct.toMap());
    } on FirebaseException catch (e) {
      throw FirebaseExceptions.translateFirestoreException(e.code);
    } catch (e) {
      throw "Error desconocido al actualizar el producto del local.";
    }
  }

  // LocalProduct: Bloquear/Desbloquear
  Future<void> toggleBlockStatus(
    String uid,
    bool isBlocked,
    DateTime blockLimit,
  ) async {
    try {
      await _firestoreProvider
          .collection(FirestoreCollections.localProducts)
          .doc(uid)
          .update({'isBlocked': isBlocked, 'blockLimit': blockLimit});
    } on FirebaseException catch (e) {
      throw FirebaseExceptions.translateFirestoreException(e.code);
    } catch (e) {
      throw "Error al cambiar estado del producto.";
    }
  }

  // LocalProduct: Eliminar asignación
  Future<void> deleteLocalProduct(String uid) async {
    try {
      await _firestoreProvider
          .collection(FirestoreCollections.localProducts)
          .doc(uid)
          .delete();
    } on FirebaseException catch (e) {
      throw FirebaseExceptions.translateFirestoreException(e.code);
    } catch (e) {
      throw "Error al eliminar la asignación del producto.";
    }
  }
}
