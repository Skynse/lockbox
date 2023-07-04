import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockbox/pages/auth/auth_gate.dart';
import 'package:lockbox/pages/auth/login.dart';
import 'package:lockbox/pages/auth/register.dart';
import 'package:lockbox/pages/home.dart';
import 'package:lockbox/backend/backend.dart';

import 'package:appwrite/appwrite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
