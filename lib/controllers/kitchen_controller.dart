import 'package:app_plaza_flutter/collections/roles_collections.dart';
import 'package:app_plaza_flutter/utils/order_states.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_plaza_flutter/models/models.dart' as models;
import 'package:app_plaza_flutter/providers/providers.dart';
import 'package:app_plaza_flutter/collections/firestore_collections.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Escucha órdenes pendientes de la cocina para el local actual
final kitchenOrdersStreamProvider = StreamProvider<List<models.Order>>((ref) {
  // Obtenemos la instancia Firestore desde el provider
  final firestore = ref.watch(firestoreInstanceProvider);
  // Obtenemos el LocalId del usuario actual
  final sessionAsync = ref.watch(sessionDataProvider);
  final currentLocalId = sessionAsync.value?.user.idLocal ?? '';
  final currentRoleId = sessionAsync.value?.user.idRole ?? '';

  // Filtramos desde el inicio del día actual
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);

  return firestore
      .collection(FirestoreCollections.orders)
      .where('localId', isEqualTo: currentLocalId)
      .where(
        'status',
        whereIn:
            (RolesCollections.chefId == currentRoleId ||
                RolesCollections.adminId == currentRoleId)
            ? [OrderStates.cooking.value, OrderStates.pending.value]
            : [OrderStates.pending.value],
      )
      .where(
        'createdAt',
        isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
      )
      .orderBy('createdAt', descending: false) // Antiguas a Nuevas
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) => models.Order.fromMap(doc.data(), doc.id))
            .toList(),
      );
});
