import 'package:app_plaza_flutter/models/models.dart';

class SessionData {
  final String firebaseUid;
  final User user;

  const SessionData({required this.firebaseUid, required this.user});
}
