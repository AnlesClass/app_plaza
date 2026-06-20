abstract class FirebaseExceptions {
  // Traducir excepciones de FirebaseAuthentication
  static String translateFirebaseAuthException(String errorCode) {
    switch (errorCode) {
      // ERROR EN REGISTRO
      case "email-already-in-use":
        return "Este correo electrónico ya está registrado. Intenta iniciar sesión.";
      case "weak-password":
        return "La contraseña es muy débil. Debe tener al menos 6 caracteres.";
      // ERROR EN LOGIN
      case "invalid-credential":
      case "INVALID_LOGIN_CREDENTIALS": // Formato de Firebase Emulator
        return "El correo o la contraseña son incorrectos.";
      case "user-not-found": // Obsoleta. Puesto por seguridad.
      case "wrong-password": // Obsoleta. Puesto por seguridad.
        return "Credenciales inválidas.";
      // ERROR EN CUENTA
      case "invalid-email":
        return "El correo electrónico ingresado no es válido.";
      case "user-disabled":
        return "Esta cuenta de usuario ha sido inhabilitada.";
      case "user-token-expired":
        return "La sesión ha expirado. Por favor, inicia sesión nuevamente.";
      // ERROR EN SISTEMA O INTERNET
      case "network-request-failed":
        return "Error de red. Verifica tu conexión a internet e intenta de nuevo.";
      case "operation-not-allowed":
        return "El servicio de autenticación no está habilitado en el servidor.";
      case "too-many-requests":
        return "Demasiados intentos fallidos. Por seguridad, espera un momento antes de reintentar.";
      default:
        return "Ocurrió un error inesperado en la autenticación ($errorCode).";
    }
  }

  // Traducir excepciones de Firestore
  static String translateFirestoreException(String errorCode) {
    switch (errorCode) {
      case "permission-denied":
        return "No tienes permisos suficientes para realizar esta acción. Revisa las reglas de seguridad.";
      case "not-found":
        return "El registro solicitado no existe o ha sido eliminado.";
      case "already-exists":
        return "No fue posible el registro. Ya existe uno con características similares.";
      case "resource-exhausted":
        return "Se ha agotado la cuota de la base de datos o el almacenamiento está lleno.";
      case "failed-precondition":
        return "La operación falló (posiblemente falta un índice en Firestore o el estado del documento no es válido).";
      case "unavailable":
        return "El servicio de base de datos no está disponible temporalmente. Intenta de nuevo más tarde.";
      case "deadline-exceeded":
        return "La conexión con la base de datos tardó demasiado. Revisa tu internet.";
      case "unauthenticated":
        return "Usuario no autenticado. Por favor, inicia sesión para continuar.";
      case "aborted":
        return "La operación fue abortada por un conflicto en el sistema. Intenta de nuevo.";
      case "invalid-argument":
        return "Uno de los datos enviados a la base de datos es inválido.";
      case "internal":
        return "Error interno del servidor.";
      default:
        return "Error inesperado en la base de datos ($errorCode).";
    }
  }
}
