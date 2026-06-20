import 'package:flutter/material.dart';
import '../config/configs.dart';

class AppVersionLabel extends StatelessWidget {
  const AppVersionLabel({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Text(
        "${AppConfig.appName} ${AppConfig.appVersion}",
        style: TextStyle(color: Colors.grey, fontSize: 12),
      ),
    );
  }
}
