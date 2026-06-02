// providers/table_providers.dart (nuevo archivo)
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_plaza_flutter/models/table.dart';
import 'package:app_plaza_flutter/repositories/table_repository.dart';

/// Provider para obtener el ID del local actual. No debería estar aquí.
final currentLocalIdProvider = Provider<String>((ref) {
  // TODO: Reemplazar con el ID real del local del usuario logueado
  // ref.read(authRepositoryProvider).currentUser?.idLocal
  return "id_local";
});

// StreamProvider de las mesas del local actual
final tablesByLocalStreamProvider = StreamProvider<List<Table>>((ref) {
  final localId = ref.watch(currentLocalIdProvider);
  final tableRepository = ref.watch(tableRepositoryProvider);
  return tableRepository.streamTablesByLocal(localId);
});
