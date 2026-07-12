// widgets/product_card.dart
import 'package:app_plaza_flutter/models/models.dart';
import 'package:app_plaza_flutter/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProductCard extends StatelessWidget {
  final LocalProduct item;

  const ProductCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final bool isCurrentlyBlocked = item.isBlocked;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isCurrentlyBlocked
              ? Colors.grey.shade300
              : AppTheme.secondaryColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showProductDetails(context, item),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Avatar Lateral
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  color: isCurrentlyBlocked
                      ? Colors.grey.shade200
                      : AppTheme.secondaryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: FaIcon(
                    isCurrentlyBlocked
                        ? FontAwesomeIcons.ban
                        : FontAwesomeIcons.utensils,
                    color: isCurrentlyBlocked
                        ? Colors.grey.shade500
                        : AppTheme.primaryColor,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Información del Producto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.productName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: isCurrentlyBlocked
                            ? Colors.grey
                            : AppTheme.primaryColor,
                        decoration: isCurrentlyBlocked
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'S/. ${item.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isCurrentlyBlocked
                            ? Colors.grey
                            : AppTheme.secondaryColor,
                      ),
                    ),
                    if (isCurrentlyBlocked &&
                        item.blockLimit.isAfter(DateTime.now())) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const FaIcon(
                            FontAwesomeIcons.clock,
                            size: 11,
                            color: Colors.redAccent,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              "Hasta: ${_formatDate(item.blockLimit)}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.redAccent,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Indicador de Estado
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isCurrentlyBlocked
                      ? Colors.red.shade50
                      : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FaIcon(
                      isCurrentlyBlocked
                          ? FontAwesomeIcons.circleXmark
                          : FontAwesomeIcons.circleCheck,
                      size: 13,
                      color: isCurrentlyBlocked
                          ? Colors.red.shade700
                          : Colors.green.shade700,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isCurrentlyBlocked ? "Bloq." : "Disp.",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isCurrentlyBlocked
                            ? Colors.red.shade700
                            : Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showProductDetails(BuildContext context, LocalProduct item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.quaternaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const FaIcon(
              FontAwesomeIcons.circleInfo,
              color: AppTheme.primaryColor,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                item.productName,
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _dialogRow(
              FontAwesomeIcons.tag,
              "Precio:",
              "S/. ${item.price.toStringAsFixed(2)}",
            ),
            const SizedBox(height: 10),
            _dialogRow(
              item.isBlocked ? FontAwesomeIcons.ban : FontAwesomeIcons.check,
              "Estado:",
              item.isBlocked
                  ? "Bloqueado temporalmente"
                  : "Disponible para venta",
            ),
            if (item.isBlocked && item.blockLimit.isAfter(DateTime.now())) ...[
              const SizedBox(height: 10),
              _dialogRow(
                FontAwesomeIcons.clock,
                "Desbloqueo:",
                _formatDate(item.blockLimit),
                iconColor: Colors.redAccent,
              ),
            ],
            const Divider(height: 24),
            Text(
              "Detalles técnicos",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "ID Producto: ${item.idProduct}",
              style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
            ),
            Text(
              "Categoría: ${item.idCategory}",
              style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cerrar",
              style: TextStyle(
                color: AppTheme.secondaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dialogRow(
    FaIconData icon,
    String title,
    String value, {
    Color? iconColor,
  }) {
    return Row(
      children: [
        FaIcon(icon, size: 14, color: iconColor ?? AppTheme.secondaryColor),
        const SizedBox(width: 8),
        Text("$title ", style: const TextStyle(fontWeight: FontWeight.w600)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w400),
          ),
        ),
      ],
    );
  }
}
