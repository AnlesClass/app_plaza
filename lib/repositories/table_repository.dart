import 'package:app_plaza_flutter/collections/firestore_collections.dart';
import 'package:app_plaza_flutter/models/table.dart';
import 'package:app_plaza_flutter/providers/firebase_provider.dart';
import 'package:app_plaza_flutter/utils/firebase_exceptions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final tableRepositoryProvider = Provider<TableRepository>((ref) {
  final firestoreProvider = ref.watch(firestoreInstanceProvider);
  return TableRepository(firestoreProvider: firestoreProvider);
});

class TableRepository {
  final FirebaseFirestore _firestoreProvider;

  TableRepository({required FirebaseFirestore firestoreProvider})
    : _firestoreProvider = firestoreProvider;

  // Mesa: Crear
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

  // Mesa: Leer
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

  // Mesa: Actualizar
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

  // Mesa: Listar todas
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
}
