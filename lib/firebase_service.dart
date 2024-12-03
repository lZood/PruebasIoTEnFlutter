import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveUserConfig(String uid, Map<String, dynamic> config) async {
    try {
      await _firestore.collection('configuraciones').doc(uid).set(config);
      print("Configuración guardada.");
    } catch (e) {
      print("Error al guardar configuración: $e");
    }
  }

  Future<void> saveUserInfo(String uid, Map<String, dynamic> userInfo) async {
    try {
      await _firestore.collection('usuarios').doc(uid).set(userInfo);
      print("Información del usuario guardada.");
    } catch (e) {
      print("Error al guardar información del usuario: $e");
    }
  }

  Future<Map<String, dynamic>?> getUserConfig(String uid) async {
    try {
      DocumentSnapshot snapshot =
      await _firestore.collection('configuraciones').doc(uid).get();
      return snapshot.data() as Map<String, dynamic>?;
    } catch (e) {
      print("Error al recuperar configuración: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserInfo(String uid) async {
    try {
      DocumentSnapshot snapshot =
      await _firestore.collection('usuarios').doc(uid).get();
      return snapshot.data() as Map<String, dynamic>?;
    } catch (e) {
      print("Error al recuperar información del usuario: $e");
      return null;
    }
  }

  Future<void> testWritePerformance() async {
    final stopwatch = Stopwatch()..start();
    try {
      for (int i = 0; i < 100; i++) {
        await saveUserConfig('test_user_$i', {
          "preferencias": {"tema": "oscuro", "notificaciones": false},
          "permisos": ["usuario"]
        });
      }
      stopwatch.stop();
      print("Tiempo total para 100 escrituras: ${stopwatch.elapsedMilliseconds} ms");
    } catch (e) {
      print("Error en la prueba de escritura: $e");
    }
  }

  Future<void> testReadPerformance() async {
    final stopwatch = Stopwatch()..start();
    try {
      for (int i = 0; i < 100; i++) {
        await getUserConfig('test_user_$i');
      }
      stopwatch.stop();
      print("Tiempo total para 100 lecturas: ${stopwatch.elapsedMilliseconds} ms");
    } catch (e) {
      print("Error en la prueba de lectura: $e");
    }
  }
}
