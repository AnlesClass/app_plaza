import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider de Instancia de Firestore
final firestoreInstanceProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// Provider de Instancia de Firebase Authenticator
final firebaseAuthInstanceProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

// Provider de Instancia de Firebase Functions
final firebaseFunctionsInstanceProvider = Provider<FirebaseFunctions>((ref) {
  return FirebaseFunctions.instance;
});
