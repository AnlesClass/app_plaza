// providers/table_providers.dart (nuevo archivo)
import 'package:app_plaza_flutter/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_plaza_flutter/models/table.dart';
import 'package:app_plaza_flutter/repositories/table_repository.dart';

// StreamProvider de las mesas del local actual
final tablesByLocalStreamProvider = StreamProvider<List<Table>>((ref) {
  // Observamos los cambios en la sesión
  final sessionDataAsync = ref.watch(sessionDataProvider);
  // Cambiamos stream cuando la sesión cambie
  return sessionDataAsync.when(
    data: (sessionData) {
      if (sessionData == null) {
        return Stream.value([]);
      }
      final localId = sessionData.user.idLocal;
      final tableRepository = ref.watch(tableRepositoryProvider);
      return tableRepository.streamTablesByLocal(localId);
    },
    loading: () => Stream.value([]),
    error: (_, _) => Stream.value([]),
  );
});
