import 'package:app_plaza_flutter/collections/firestore_collections.dart';
import 'package:app_plaza_flutter/models/table.dart';
import 'package:app_plaza_flutter/providers/firebase_providers.dart';
import 'package:app_plaza_flutter/utils/firebase_exceptions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart' as mat;
import 'package:flutter_riverpod/flutter_riverpod.dart';

// TODO: Borrar los import material.dart cuando finalice el debuging.

/// Provider del repositorio de mesa(s)
final tableRepositoryProvider = Provider<TableRepository>((ref) {
  final firestoreProvider = ref.watch(firestoreInstanceProvider);
  return TableRepository(firestoreProvider: firestoreProvider);
});

/// Clase tipo repositorio para las mesas de un local.
class TableRepository {
  final FirebaseFirestore _firestoreProvider;

  TableRepository({required FirebaseFirestore firestoreProvider})
    : _firestoreProvider = firestoreProvider;

  /// Mesa: Crear
  Future<void> createTable(Table table) async {
    try {
      await _firestoreProvider
          .collection(FirestoreCollections.tables)
          .add(table.toMap());
    } on FirebaseException catch (e) {
      throw FirebaseExceptions.translateFirestoreException(e.code);
    } catch (e) {
      throw "Error desconocido al registrar la mesa.";
    }
  }

  /// Mesa: Leer por identificador
  Future<Table> readTable(String uid) async {
    try {
      final doc = await _firestoreProvider
          .collection(FirestoreCollections.tables)
          .doc(uid)
          .get();

      if (doc.exists) {
        return Table.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      } else {
        throw "La mesa solicitada no existe.";
      }
    } on FirebaseException catch (e) {
      throw FirebaseExceptions.translateFirestoreException(e.code);
    } catch (e) {
      throw "Error al obtener la información de la mesa.";
    }
  }

  /// Mesa: Actualizar basada en otra mesa
  Future<void> updateTable(Table table) async {
    if (table.uid == null) throw "No se puede actualizar una mesa sin ID.";
    try {
      await _firestoreProvider
          .collection(FirestoreCollections.tables)
          .doc(table.uid)
          .update(table.toMap());
    } on FirebaseException catch (e) {
      throw FirebaseExceptions.translateFirestoreException(e.code);
    } catch (e) {
      throw "Error desconocido al actualizar la mesa.";
    }
  }

  /// Mesa: Listar todas (future, asíncrona)
  Future<List<Table>> getTables() async {
    try {
      final querySnapshot = await _firestoreProvider
          .collection(FirestoreCollections.tables)
          .get();

      return querySnapshot.docs
          .map((doc) => Table.fromMap(doc.data(), doc.id))
          .toList();
    } on FirebaseException catch (e) {
      throw FirebaseExceptions.translateFirestoreException(e.code);
    } catch (e) {
      throw "Error al cargar el listado de mesas.";
    }
  }

  /// Mesa: Listar todas por Local (stream, tiempo real)
  Stream<List<Table>> streamTablesByLocal(String idLocal) {
    try {
      return _firestoreProvider
          .collection(FirestoreCollections.tables)
          .where('idLocal', isEqualTo: idLocal)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => Table.fromMap(doc.data(), doc.id))
                .toList(),
          );
    } catch (e) {
      throw "Error al obtener stream de mesas: $e";
    }
  }

  /// Mesa: Actualizar el estado de ocupación para múltiples mesas en lote
  Future<void> updateTablesOccupation(
    List<String> tableIds,
    bool isOccupied,
  ) async {
    // Si no hay mesas, no se actualiza
    if (tableIds.isEmpty) {
      mat.debugPrint("[TABLE REPOSITORY] No hay mesas para actualizar.");
      return;
    }
    // Consulta general para varias mesas
    try {
      final batch = _firestoreProvider.batch();
      final collectionRef = _firestoreProvider.collection(
        FirestoreCollections.tables,
      );

      for (final id in tableIds) {
        final docRef = collectionRef.doc(id);
        // Actualizamos únicamente el campo 'isOccupied' sin alterar lo demás
        batch.update(docRef, {'isOccupied': isOccupied});
        mat.debugPrint("[TABLE REPOSITORY] Cargado en lote: $id");
      }

      // Se ejecutan todas las escrituras en una sola petición de red
      mat.debugPrint("[TABLE REPOSITORY] Antes de hacer commit.");
      await batch.commit();
      mat.debugPrint(
        "[TABLE REPOSITORY] Commit ya hecho. Mesas actualizada a estado ocupado: $isOccupied",
      );
    } on FirebaseException catch (e) {
      mat.debugPrint("[TABLE_REPOSITORY] Error de Firestore: $e");
      throw FirebaseExceptions.translateFirestoreException(e.code);
    } catch (e) {
      mat.debugPrint(
        "[TABLE_REPOSITORY] Error al actualizar el estado de las mesas: $e",
      );
      throw "Error al actualizar el estado de las mesas.";
    }
  }
}
