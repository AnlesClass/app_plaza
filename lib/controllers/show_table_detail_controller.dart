import 'package:app_plaza_flutter/utils/order_states.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_plaza_flutter/models/models.dart' as models;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_plaza_flutter/collections/firestore_collections.dart';
import 'package:app_plaza_flutter/providers/firebase_providers.dart';

/// Provider dinámico que escucha la orden activa de una mesa específica
final activeOrderByTableProvider = StreamProvider.family<models.Order?, String>((
  ref,
  tableId,
) {
  final firestore = ref.watch(firestoreInstanceProvider);

  // Calculamos el inicio del día actual (sin hora, para que inicie a las 00:00)
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);

  return firestore
      .collection(FirestoreCollections.orders)
      .where('tableIds', arrayContains: tableId)
      .where(
        'status',
        whereIn: [
          OrderStates.pending.value,
          OrderStates.cooking.value,
          OrderStates.ready.value,
          OrderStates.served.value,
        ],
      )
      .where(
        'createdAt',
        isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
      )
      // .limit(1) // No es necesario en teoría, veremos en la práctica.
      .snapshots()
      .map((snapshot) {
        // Retorna null a la 'Snapshot' si no hay documentos que coincidan con la búsqueda
        if (snapshot.docs.isEmpty) return null;

        // Obtiene el primer documento y lo devolvemos.
        final doc = snapshot.docs.first;
        return models.Order.fromMap(doc.data(), doc.id);
      });
});
