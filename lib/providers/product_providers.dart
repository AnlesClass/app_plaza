// providers/product_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_plaza_flutter/models/local_product_with_details.dart';
import 'package:app_plaza_flutter/repositories/local_product_repository.dart';
import 'package:app_plaza_flutter/repositories/product_repository.dart';
import 'session_providers.dart';

/// StreamProvider que combina LocalProducts con sus Products
final localProductsWithDetailsStreamProvider =
    StreamProvider<List<LocalProductWithDetails>>((ref) {
      final sessionDataAsync = ref.watch(sessionDataProvider);

      return sessionDataAsync.when(
        data: (sessionData) async* {
          if (sessionData == null) {
            yield [];
            return;
          }

          final localId = sessionData.user.idLocal;
          final localProductRepo = ref.watch(localProductRepositoryProvider);
          final productRepo = ref.watch(productRepositoryProvider);

          // Escuchamos los cambios en local_products
          await for (final localProducts
              in localProductRepo.streamLocalProductsByLocal(localId)) {
            if (localProducts.isEmpty) {
              yield [];
              continue;
            }

            // Obtenemos los IDs de los productos
            final productIds = localProducts.map((lp) => lp.idProduct).toList();

            // Obtenemos los detalles de los productos
            final products = await productRepo.readProductsByIds(productIds);

            // Creamos un mapa para acceso rápido
            final productMap = {for (var p in products) p.uid: p};

            // Combinamos los datos
            final combined = localProducts
                .where((lp) => productMap.containsKey(lp.idProduct))
                .map(
                  (lp) => LocalProductWithDetails(
                    localProduct: lp,
                    product: productMap[lp.idProduct]!,
                  ),
                )
                .toList();

            yield combined;
          }
        },
        loading: () => Stream.value([]),
        error: (_, _) => Stream.value([]),
      );
    });

/// FutureProvider para obtener productos de una sola vez
final localProductsWithDetailsFutureProvider =
    FutureProvider<List<LocalProductWithDetails>>((ref) async {
      final sessionData = await ref.watch(sessionDataProvider.future);
      if (sessionData == null) return [];

      final localId = sessionData.user.idLocal;
      final localProductRepo = ref.watch(localProductRepositoryProvider);
      final productRepo = ref.watch(productRepositoryProvider);

      // Obtenemos los local_products
      final localProducts = await localProductRepo.getLocalProductsByLocal(
        localId,
      );
      if (localProducts.isEmpty) return [];

      // Obtenemos los productos
      final productIds = localProducts.map((lp) => lp.idProduct).toList();
      final products = await productRepo.readProductsByIds(productIds);

      // Creamos mapa para acceso rápido
      final productMap = {for (var p in products) p.uid: p};

      // Combinamos
      return localProducts
          .where((lp) => productMap.containsKey(lp.idProduct))
          .map(
            (lp) => LocalProductWithDetails(
              localProduct: lp,
              product: productMap[lp.idProduct]!,
            ),
          )
          .toList();
    });
