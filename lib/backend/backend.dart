import 'package:appwrite/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appwrite/appwrite.dart';

// lib to access environment variables
import 'dart:io' show Platform;

class AppwriteWrapper extends StateNotifier<Client> {
  // create an appwrite client instance
  Client client = Client();

  Future<bool> isLoggedIn() {
    final account = Account(client);
    return account.get().then((value) => true).catchError((e) => false);
  }

  Future<User> getUser() {
    final account = Account(client);
    return account.get();
  }

  init() {
    client
        .setEndpoint('https://cloud.appwrite.io/v1')
        .setProject(Platform.environment['APPWRITE_PROJECT_ID']!)
        .setSelfSigned(
            status:
                true); // For self signed certificates, only use for development

    return client;
  }

  // create an appwrite account instance
  register({required String email, required String password}) async {
    Account account = Account(client);
    try {
      final user = await account.create(
          userId: ID.unique(), email: email, password: password);
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future<Session> login(
      {required String email, required String password}) async {
    Account account = Account(client);
    try {
      final session =
          await account.createEmailSession(email: email, password: password);
      return session;
    } catch (e) {
      print(e);
      throw e;
    }
  }

  logout() async {
    Account account = Account(client);
    try {
      await account.deleteSession(sessionId: 'current');
    } catch (e) {
      print(e);
      throw e;
    }
  }

  // constructor
  AppwriteWrapper() : super(Client()) {
    init();
  }
}

final appwriteProvider = Provider((ref) => AppwriteWrapper());
