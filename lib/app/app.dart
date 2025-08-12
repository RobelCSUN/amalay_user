// lib/app/app.dart
import 'package:flutter/material.dart';
import 'package:amalay_user/screens/home/home_screen.dart';

class AmalayUserApp extends StatelessWidget {
  const AmalayUserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Amalay',
      debugShowCheckedModeBanner: false,
      // IMPORTANT: go straight to HomeScreen
      home: const HomeScreen(),
      // No initialRoute / onGenerateRoute / splash wrappers
      // No FutureBuilder here either
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
    );
  }
}
