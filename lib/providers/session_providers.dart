import 'package:app_plaza_flutter/models/models.dart';
import 'package:app_plaza_flutter/providers/firebase_providers.dart';
import 'package:app_plaza_flutter/repositories/repositories.dart';
import 'package:firebase_auth/firebase_auth.dart' as fba;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Constantemente provee el estado de la instancia Auth.
final firebaseAuthUserProvider = StreamProvider<fba.User?>((ref) {
  final auth = ref.read(firebaseAuthInstanceProvider);
  return auth.authStateChanges();
});

/// Provee datos de la sesión activa, cargados de la base de datos cada vez que
/// cambia el valor de "FirebaseAuthUserProvider".
final sessionDataProvider = FutureProvider<SessionData?>((ref) async {
  final firebaseUser = await ref.watch(firebaseAuthUserProvider.future);
  if (firebaseUser == null) return null;
  final userRepo = ref.read(userRepositoryProvider);
  final appUser = await userRepo.readUser(firebaseUser.uid);
  return SessionData(firebaseUid: firebaseUser.uid, user: appUser);
});

/// Modelo del usuario. Solo modelo, para datos completos consultar el provider
/// `sessionDataProvider`.
final activeUserProvider = FutureProvider<User?>((ref) async {
  final firebaseUser = await ref.watch(firebaseAuthUserProvider.future);
  if (firebaseUser == null) return null;

  final userRepo = ref.read(userRepositoryProvider);
  return userRepo.readUser(firebaseUser.uid);
});

/// UID del usuario activo. Solo UID, para datos completos consultar el provider
/// `sessionDataProvider`.
final activeFirebaseUidProvider = FutureProvider<String?>((ref) async {
  final firebaseUser = await ref.watch(firebaseAuthUserProvider.future);
  return firebaseUser?.uid;
});
