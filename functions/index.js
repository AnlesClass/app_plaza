const { setGlobalOptions } = require("firebase-functions/v2");
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger"); // Recomendado para v2
const admin = require("firebase-admin");

// Inicializa el SDK de Administración
admin.initializeApp();

// Configuración global para ahorrar costos
setGlobalOptions({ maxInstances: 10 });

exports.createUser = onCall(async (request) => {
    logger.info("----- EJECUTANDO FUNCIÓN: createUser -----");

    // Verifica la autenticación del usuario que solicita
    if (!request.auth) {
        logger.warn("[AUTH ERROR]: Intento de llamada sin token de autenticación.");
        throw new HttpsError(
            'unauthenticated',
            'Debes iniciar sesión para crear usuarios'
        );
    }

    // Guardamos el UID del usuario solicitante
    const callerUid = request.auth.uid;
    logger.info(`[AUTH SUCCESS]: Usuario autenticado invocando la función. UID: ${callerUid}`);

    // Verificar el rol de administrador en Firestore
    try {
        logger.info(`[FIRESTORE]: Buscando rol para el usuario: ${callerUid}`);

        // Buscamos el documento de usuario
        const callerDoc = await admin.firestore()
            .collection('users')
            .doc(callerUid)
            .get();

        // Si el documento no existe lanzamos una excepción
        if (!callerDoc.exists) {
            logger.warn(`[FIRESTORE ERROR]: No existe documento en la colección 'users' para el UID: ${callerUid}`);
            throw new HttpsError(
                'permission-denied',
                'Solo los administradores pueden crear usuarios'
            );
        }

        // Guardamos los datos del documento consultado
        const callerData = callerDoc.data();
        logger.info(`[FIRESTORE DATA]: Datos del solicitante recuperados. Rol actual: ${callerData?.idRole}`);

        // Ahora consultamos el valor del ID Rol y lo comparamos con el destinado para el Administrador
        // Si no coinciden, lanzamos una excepción.
        if (callerData.idRole !== '9XdXQXJ903I5htOPofSU') {
            logger.warn(`[PERMISOS DENEGADOS]: El usuario ${callerUid} con rol ${callerData.idRole} intentó crear un usuario sin ser Admin.`);
            throw new HttpsError(
                'permission-denied',
                'Solo los administradores pueden crear usuarios'
            );
        }

        logger.info("[PERMISOS OK]: El usuario es Administrador válido.");
    } catch (firestoreError) {
        // Error: En caso de caída de Firestore
        if (firestoreError instanceof HttpsError) throw firestoreError;

        logger.error("[FIRESTORE CRASH]: Error inesperado al leer Firestore:", firestoreError);
        throw new HttpsError(
            'internal',
            'Error al verificar los permisos del usuario administrador.'
        );
    }

    // Obtener datos desde Flutter: Log Inicial
    logger.info("[VALIDACIÓN]: Procesando parámetros recibidos desde Flutter...");
    const { email, password, username, name, lastname, idLocal, idRole, isActive } = request.data;
    // Mostrar datos desde Flutter: Log Final
    logger.info(`[DATA RECIBIDA]: email: ${email}, username: ${username}, name: ${name}, idLocal: ${idLocal}, idRole: ${idRole}, isActive: ${isActive}`);

    // Si todos los datos existen, proseguimos. Caso contrario, se lanza una excepción
    if (!email || !password || !username || !name || !lastname || !idLocal || !idRole) {
        logger.warn("[VALIDACIÓN ERROR]: Faltan campos obligatorios en request.data");
        throw new HttpsError(
            'invalid-argument',
            'Todos los campos son requeridos.'
        );
    }

    // Crear usuario en Auth y registrar en Firestore
    try {
        // Guardar usuario en Auth
        logger.info(`[FIREBASE AUTH]: Intentando crear usuario con email: ${email}`);
        const userRecord = await admin.auth().createUser({
            email: email,
            password: password,
            displayName: username,
        });

        // Guardar usuario en Firestore
        logger.info(`[FIRESTORE]: Registrando datos adicionales para el nuevo UID: ${userRecord.uid}`);
        await admin.firestore()
            .collection('users')
            .doc(userRecord.uid)
            .set({
                email: email,
                username: username,
                name: name,
                lastname: lastname,
                idLocal: idLocal,
                idRole: idRole,
                isActive: isActive ?? true
            });

        logger.info(`[ÉXITO TOTAL]: Transacción completada para el usuario ${userRecord.uid}. Enviando respuesta a Flutter.`);

        // Devolver respuesta a la aplicación
        return {
            success: true,
            uid: userRecord.uid,
            message: "Usuario creado correctamente",
            user: {
                uid: userRecord.uid,
                email: email,
                name: name,
                lastname: lastname,
            }
        };

    } catch (error) {
        logger.error("[ERROR CRÍTICO EN PROCESO]: Falló la creación.", error);

        // TODO: Ante fallos considerar los siguientes errores. (X) Hecho ( ) Sin hacer
        // unauthenticated ( )
        // permission-denied ( )
        // invalid-argument (X)
        // internal (X)

        // Mapeamos errores de un formato a otro para que los gestione la app
        // Error: Correo ya existente
        if (error.code === 'auth/email-already-exists') {
            throw new HttpsError(
                'already-exists',
                'El correo electrónico ya está registrado.'
            );
        }

        // Error: Correo inválido
        if (error.code === 'auth/invalid-email') {
            throw new HttpsError(
                'invalid-argument',
                'El formato del correo es inválido.'
            );
        }

        // Error: Contraseña débil
        if (error.code === 'auth/weak-password') {
            throw new HttpsError(
                'invalid-argument',
                'La contraseña es muy débil.'
            );
        }

        // Cualquier otro error
        const errorMessage = error instanceof Error ? error.message : String(error);
        throw new HttpsError(
            'internal',
            `Error interno: ${errorMessage}`
        );
    }
});