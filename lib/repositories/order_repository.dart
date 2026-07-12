import 'package:app_plaza_flutter/collections/firestore_collections.dart';
import 'package:app_plaza_flutter/models/models.dart' as models;
import 'package:app_plaza_flutter/providers/firebase_providers.dart';
import 'package:app_plaza_flutter/utils/firebase_exceptions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  final firestoreProvider = ref.watch(firestoreInstanceProvider);
  return OrderRepository(firestoreProvider: firestoreProvider);
});

class OrderRepository {
  final FirebaseFirestore _firestoreProvider;

  OrderRepository({required FirebaseFirestore firestoreProvider})
    : _firestoreProvider = firestoreProvider;

  // Leer: Una orden desde la base de datos
  Future<models.Order> readOrder(String uid) async {
    try {
      final doc = await _firestoreProvider
          .collection(FirestoreCollections.orders)
          .doc(uid)
          .get();

      if (doc.exists) {
        return models.Order.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      } else {
        throw "La órden solicitada no existe.";
      }
    } on FirebaseException catch (e) {
      throw FirebaseExceptions.translateFirestoreException(e.code);
    } catch (e) {
      throw "Error al obtener la información de la orden.";
    }
  }
}
