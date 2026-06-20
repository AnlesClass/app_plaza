// repositories/product_repository.dart
import 'package:app_plaza_flutter/collections/firestore_collections.dart';
import 'package:app_plaza_flutter/models/product.dart';
import 'package:app_plaza_flutter/providers/firebase_providers.dart';
import 'package:app_plaza_flutter/utils/firebase_exceptions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider del Repositorio del Producto
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final firestoreProvider = ref.watch(firestoreInstanceProvider);
  return ProductRepository(firestoreProvider: firestoreProvider);
});

class ProductRepository {
  final FirebaseFirestore _firestoreProvider;

  ProductRepository({required FirebaseFirestore firestoreProvider})
    : _firestoreProvider = firestoreProvider;

  // Producto: Crear
  Future<void> createProduct(Product product) async {
    try {
      await _firestoreProvider
          .collection(FirestoreCollections.products)
          .add(product.toMap());
    } on FirebaseException catch (e) {
      throw FirebaseExceptions.translateFirestoreException(e.code);
    } catch (e) {
      throw "Error desconocido al registrar el producto.";
    }
  }

  // Producto: Leer por ID
  Future<Product?> readProduct(String uid) async {
    try {
      final doc = await _firestoreProvider
          .collection(FirestoreCollections.products)
          .doc(uid)
          .get();

      if (doc.exists) {
        return Product.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } on FirebaseException catch (e) {
      throw FirebaseExceptions.translateFirestoreException(e.code);
    } catch (e) {
      throw "Error al obtener la información del producto.";
    }
  }

  // Producto: Leer múltiples por IDs
  Future<List<Product>> readProductsByIds(List<String> productIds) async {
    if (productIds.isEmpty) return [];

    try {
      final querySnapshot = await _firestoreProvider
          .collection(FirestoreCollections.products)
          .where(FieldPath.documentId, whereIn: productIds)
          .get();

      return querySnapshot.docs
          .map((doc) => Product.fromMap(doc.data(), doc.id))
          .toList();
    } on FirebaseException catch (e) {
      throw FirebaseExceptions.translateFirestoreException(e.code);
    } catch (e) {
      throw "Error al cargar los productos.";
    }
  }

  // Producto: Actualizar
  Future<void> updateProduct(Product product) async {
    if (product.uid == null) throw "No se puede actualizar un producto sin ID.";
    try {
      await _firestoreProvider
          .collection(FirestoreCollections.products)
          .doc(product.uid)
          .update(product.toMap());
    } on FirebaseException catch (e) {
      throw FirebaseExceptions.translateFirestoreException(e.code);
    } catch (e) {
      throw "Error desconocido al actualizar el producto.";
    }
  }

  // Producto: Listar todos
  Future<List<Product>> getAllProducts() async {
    try {
      final querySnapshot = await _firestoreProvider
          .collection(FirestoreCollections.products)
          .get();

      return querySnapshot.docs
          .map((doc) => Product.fromMap(doc.data(), doc.id))
          .toList();
    } on FirebaseException catch (e) {
      throw FirebaseExceptions.translateFirestoreException(e.code);
    } catch (e) {
      throw "Error al cargar el listado de productos.";
    }
  }

  // Producto: Stream por categoría
  Stream<List<Product>> streamProductsByCategory(String idCategory) {
    try {
      return _firestoreProvider
          .collection(FirestoreCollections.products)
          .where('idCategory', isEqualTo: idCategory)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => Product.fromMap(doc.data(), doc.id))
                .toList(),
          );
    } catch (e) {
      throw "Error al obtener stream de productos: $e";
    }
  }
}
