import 'package:app_plaza_flutter/models/category.dart'; // Tu modelo de Categoría
import 'package:app_plaza_flutter/utils/firebase_exceptions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../collections/firestore_collections.dart';
import '../providers/providers.dart';

// Provider de Riverpod para exponer el repositorio
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final firestoreProvider = ref.watch(firestoreInstanceProvider);
  return CategoryRepository(firestoreProvider: firestoreProvider);
});

class CategoryRepository {
  final FirebaseFirestore _firestoreProvider;

  CategoryRepository({required FirebaseFirestore firestoreProvider})
    : _firestoreProvider = firestoreProvider;

  // Categoría: Crear
  Future<void> createCategory(Category category) async {
    try {
      await _firestoreProvider
          .collection(
            FirestoreCollections.categories,
          ) // Asegúrate de agregarlo a tus colecciones
          .add(category.toMap());
    } on FirebaseException catch (e) {
      throw FirebaseExceptions.translateFirestoreException(e.code);
    } catch (e) {
      throw "Error desconocido al crear la categoría.";
    }
  }

  // Categoría: Leer
  Future<Category> readCategory(String uid) async {
    try {
      final doc = await _firestoreProvider
          .collection(FirestoreCollections.categories)
          .doc(uid)
          .get();

      if (doc.exists) {
        return Category.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      } else {
        throw "La categoría solicitada no existe.";
      }
    } on FirebaseException catch (e) {
      throw FirebaseExceptions.translateFirestoreException(e.code);
    } catch (e) {
      throw "Error al obtener los datos de la categoría.";
    }
  }

  // Categoría: Listar todas
  Future<List<Category>> getCategories() async {
    try {
      final querySnapshot = await _firestoreProvider
          .collection(FirestoreCollections.categories)
          //.orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => Category.fromMap(doc.data(), doc.id))
          .toList();
    } on FirebaseException catch (e) {
      throw FirebaseExceptions.translateFirestoreException(e.code);
    } catch (e) {
      throw "Error al cargar el listado de categorías.";
    }
  }
}
