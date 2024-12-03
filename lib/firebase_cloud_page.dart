import 'package:flutter/material.dart';
import 'firebase_service.dart';

class FirebaseCloudPage extends StatelessWidget {
  const FirebaseCloudPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FirebaseService service = FirebaseService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Cloud Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                await service.saveUserConfig('user123', {
                  "preferencias": {"tema": "oscuro", "notificaciones": true},
                  "permisos": ["admin", "editor"]
                });
              },
              child: const Text('Guardar Configuración'),
            ),
            ElevatedButton(
              onPressed: () async {
                await service.saveUserInfo('user123', {
                  "perfil": {"nombre": "Juan Pérez", "email": "juan@example.com"},
                  "roles": ["admin", "editor"]
                });
              },
              child: const Text('Guardar Información del Usuario'),
            ),
            ElevatedButton(
              onPressed: () async {
                final config = await service.getUserConfig('user123');
                print("Configuración: $config");
              },
              child: const Text('Recuperar Configuración'),
            ),
            ElevatedButton(
              onPressed: () async {
                final userInfo = await service.getUserInfo('user123');
                print("Información del Usuario: $userInfo");
              },
              child: const Text('Recuperar Información del Usuario'),
            ),
            ElevatedButton(
              onPressed: () async {
                await service.testWritePerformance();
              },
              child: const Text('Prueba de Escritura (100)'),
            ),
            ElevatedButton(
              onPressed: () async {
                await service.testReadPerformance();
              },
              child: const Text('Prueba de Lectura (100)'),
            ),
          ],
        ),
      ),
    );
  }
}
