import 'package:flutter/material.dart';
import 'package:app_plaza_flutter/themes/app_theme.dart';

abstract class AppAlerts {
  // Modal de Confirmación
  /// Muestra un modal de confirmación con el título y mensaje deseado.
  static Future<bool> showConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    String textConfirm = "Confirmar",
    String textCancel = "Cancelar",
  }) async {
    final bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                textCancel,
                style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    AppTheme.primaryColor, // Usamos tu tema aquí también
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                textConfirm,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  // Snackbar de Información
  /// Muestra un snackbar genérico para informar sobre cualquier cambio general.
  static void showSnackbar(
    BuildContext context,
    String message, {
    IconData iconData = Icons.info_outline,
    Color backgroundColor = AppTheme.quaternaryColor,
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(iconData, color: AppTheme.primaryColor),
            const SizedBox(width: 10),
            Expanded(
              // Añadido por seguridad para textos largos
              child: Text(
                message,
                style: TextStyle(
                  color: isError ? Colors.red : AppTheme.secondaryColor,
                  fontWeight: isError ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
