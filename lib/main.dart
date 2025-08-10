import 'dart:async'; // for unawaited (optional)
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app/app.dart';
import 'services/auth_warmup.dart'; // make sure you create this file

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Pre-warm Google, Apple, and Phone sign-in
  unawaited(AuthWarmup.run()); // you can also just do: AuthWarmup.run();

  runApp(AmalayUserApp());
}