import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            signInWithGoogle();
          },
          child: const Text('Login with Google'),
        ),
      ),
    );
  }


  Future<void> signInWithGoogle() async {
    // Paso 1: Autenticar al usuario con Google
    GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Paso 2: Obtener la autenticación de Google
    GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    // Paso 3: Crear credenciales para Firebase
    AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Paso 4: Autenticar con Firebase utilizando las credenciales de Google
    UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

    // Paso 5: Imprimir el nombre del usuario autenticado
    print(userCredential.user?.displayName);
  }
}
