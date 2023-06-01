import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockbox/pages/auth/auth_gate.dart';
import 'package:lockbox/pages/auth/login.dart';
import 'package:lockbox/pages/auth/register.dart';
import 'package:lockbox/pages/home.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ProviderScope(
      child: App(),
    ),
  );
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  int counter = 0;
  final auth = FirebaseAuth.instanceFor(app: Firebase.app());

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/home': (context) => Home(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/authGate': (context) => const AuthGate(),
      },
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        buttonTheme: const ButtonThemeData(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
      ),
      home: Scaffold(
        body: AuthGate(),
      ),
    );
  }
}
