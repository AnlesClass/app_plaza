import 'package:flutter/material.dart';

/// Clase auxiliar. Guarda los datos de un Drawer Tile.
/// Elemento: REUTILIZABLE
class DrawerItemData {
  final String title;
  final IconData icon;
  final String route;

  const DrawerItemData({
    required this.title,
    required this.icon,
    required this.route,
  });
}
