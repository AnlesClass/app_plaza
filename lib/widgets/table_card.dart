import 'package:app_plaza_flutter/collections/routes_collections.dart';
import 'package:app_plaza_flutter/models/table.dart';
import 'package:app_plaza_flutter/router/app_router.dart';
import 'package:flutter/material.dart' hide Table;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TableCard extends ConsumerWidget {
  final Table table;

  const TableCard({super.key, required this.table});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Definición de paleta de colores para la tarjeta
    Color backgroundColor;
    Color borderColor;
    Color textColor;

    // Casos: Habilitado y Libre, Habilitado y Ocupado, Deshabilitado.
    if (table.isEnable & table.isOccupied) {
      backgroundColor = Colors.red[50]!;
      borderColor = Colors.red[400]!;
      textColor = Colors.red[700]!;
    } else if (table.isEnable & !table.isOccupied) {
      backgroundColor = Colors.green[50]!;
      borderColor = Colors.green[400]!;
      textColor = Colors.green[700]!;
    } else {
      backgroundColor = Colors.grey[200]!;
      borderColor = Colors.grey[400]!;
      textColor = Colors.grey[600]!;
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor, width: 2),
      ),
      color: backgroundColor,
      child: InkWell(
        onTap: (!table.isEnable || table.uid == null)
            ? null
            : () {
                ref
                    .read(appRouterProvider)
                    .push(
                      RoutesCollections.buildShowTableDetailUrl(
                        table.uid!,
                      ), // # /show-table-detail/:tableId
                    );
              },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                table.isOccupied
                    ? Icons.restaurant_outlined
                    : Icons.table_restaurant_outlined,
                size: 48,
                color: textColor,
              ),
              const SizedBox(height: 12),
              Text(
                table.name,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.people_outline,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "${table.capacity} personas",
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: textColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  table.isOccupied ? "Ocupado" : "Libre",
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
