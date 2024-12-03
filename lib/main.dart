import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_service.dart';
import 'firebase_cloud_page.dart';
import 'dashboard_page.dart';
import 'firebase_options.dart';
import 'influxdb_page.dart'; // Importa la nueva página de InfluxDB


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Asegúrate de inicializar Firebase solo si no está inicializado
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AuthWrapper(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Web Example'),
      ),
      body: const Center(
        child: Text('Firebase configurado correctamente'),
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  Future<void> signInWithGoogle() async {
    try {
      // Google Sign-In
      GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      // Credenciales para Firebase
      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Inicia sesión en Firebase
      await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      print("Error al iniciar sesión con Google: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: signInWithGoogle,
          child: const Text('Login with Google'),
        ),
      ),
    );
  }
}


class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Escucha los cambios en el estado de autenticación
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(); // Muestra un loader mientras verifica
        }
        if (snapshot.hasData) {
          return HomePage(); // Usuario autenticado, redirige al HomePage
        }
        return const LoginPage(); // No autenticado, muestra la página de login
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              await GoogleSignIn().signOut();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FirebaseCloudPage()),
                );
              },
              child: const Text('Ir a Firebase Cloud Page'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DashboardPage()),
                );
              },
              child: const Text('Ir a Dashboard de Gráficas'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => InfluxDBPage()),
                );
              },
              child: const Text('Ir a InfluxDB Page'),
            ),
          ],
        ),
      ),
    );
  }
}
