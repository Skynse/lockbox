import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

final authProvider =
    Provider((ref) => FirebaseAuth.instanceFor(app: Firebase.app()));
