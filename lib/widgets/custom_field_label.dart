import 'package:app_plaza_flutter/themes/app_theme.dart';
import 'package:flutter/material.dart';

class CustomFieldLabel extends StatelessWidget {
  final String text;

  const CustomFieldLabel({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          color: AppTheme.primaryColor,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
