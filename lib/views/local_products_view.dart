import 'package:app_plaza_flutter/providers/session_providers.dart';
import 'package:app_plaza_flutter/repositories/repositories.dart';
import 'package:app_plaza_flutter/router/app_router.dart';
import 'package:app_plaza_flutter/themes/app_theme.dart';
import 'package:app_plaza_flutter/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LocalProductsView extends ConsumerWidget {
  const LocalProductsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionData = ref.watch(sessionDataProvider).value;
    final productsAsync = ref.watch(
      getLocalProductsByLocalProvider(sessionData!.user.idLocal),
    );
    final appRouter = ref.watch(appRouterProvider);

    return Scaffold(
      backgroundColor: AppTheme.quaternaryColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppTheme.quaternaryColor,
          ),
          onPressed: () {
            if (appRouter.canPop()) {
              appRouter.pop();
            }
          },
        ),
        title: const Text("Catálogo de Productos"),
        actions: [
          IconButton(
            icon: const FaIcon(
              FontAwesomeIcons.rotate,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () {
              ref.invalidate(
                getLocalProductsByLocalProvider(sessionData.user.idLocal),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: productsAsync.when(
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppTheme.primaryColor),
              SizedBox(height: 16),
              Text(
                "Cargando catálogo...",
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const FaIcon(
                  FontAwesomeIcons.circleExclamation,
                  size: 60,
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Ocurrió un problema',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.primaryColor.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.invalidate(
                      getLocalProductsByLocalProvider(sessionData.user.idLocal),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  icon: const FaIcon(
                    FontAwesomeIcons.arrowRotateRight,
                    size: 16,
                  ),
                  label: const Text("Reintentar"),
                ),
              ],
            ),
          ),
        ),
        data: (products) {
          // En caso de que no haya productos
          if (products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(
                    FontAwesomeIcons.boxOpen,
                    size: 64,
                    color: AppTheme.secondaryColor.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "No hay productos en este local",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Asigna productos desde el panel administrativo.",
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.primaryColor.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            );
          }

          // En caso de que haya productos
          return RefreshIndicator(
            color: AppTheme.primaryColor,
            onRefresh: () async {
              ref.invalidate(
                getLocalProductsByLocalProvider(sessionData.user.idLocal),
              );
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final item = products[index];
                return ProductCard(item: item);
              },
            ),
          );
        },
      ),
    );
  }
}
