import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockbox/backend/backend.dart';
import 'package:lockbox/pages/auth/auth_gate.dart';

class SettingsPage extends ConsumerStatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: FutureBuilder(
          future: ref.read(appwriteProvider).getUser(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ListTile(
                    leading: Icon(Icons.person),
                    title: Text(snapshot.data!.email),
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        await ref.read(appwriteProvider).logout();
                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (_) => AuthGate()));
                      },
                      child: const Center(child: Text('Sign Out')))
                ],
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    ));
  }
}
