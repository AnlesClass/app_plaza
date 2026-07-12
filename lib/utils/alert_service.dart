import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Servicio para mostrar alertas. No depende del contexto.
class AlertService {
  // Clave global, vive dentro del servicio
  final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  // TODO: Considerar transferir todo "AppAlerts" a este servicio.
  /// Mostrar un Snackbar común
  void showSnackbar(String message, {bool isError = false}) {
    scaffoldMessengerKey.currentState?.clearSnackBars(); // Limpiar
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// Provider: Expone el Singleton del servicio de alertas.
final alertServiceProvider = Provider<AlertService>((ref) {
  return AlertService();
});
