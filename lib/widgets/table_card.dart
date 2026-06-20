import 'package:app_plaza_flutter/models/table.dart';
import 'package:flutter/material.dart' hide Table;

class TableCard extends StatelessWidget {
  final Table table;

  const TableCard({super.key, required this.table});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color borderColor;
    Color textColor;

    if (table.isEnable) {
      backgroundColor = Colors.grey[200]!;
      borderColor = Colors.grey[400]!;
      textColor = Colors.grey[600]!;
    } else if (table.isOccupied) {
      backgroundColor = Colors.red[50]!;
      borderColor = Colors.red[400]!;
      textColor = Colors.red[700]!;
    } else {
      backgroundColor = Colors.green[50]!;
      borderColor = Colors.green[400]!;
      textColor = Colors.green[700]!;
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor, width: 2),
      ),
      color: backgroundColor,
      child: InkWell(
        onTap: table.isEnable
            ? null
            : () {
                // TODO: Navegar a la vista de pedido de la mesa
                if (table.isOccupied) {
                  // TODO: Ver pedido actual
                  // Enviar UID.
                  table.uid;
                } else {
                  // TODO: Crear nuevo pedido
                }
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
