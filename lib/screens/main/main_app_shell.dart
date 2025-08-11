import 'package:flutter/material.dart';

class MainAppShell extends StatelessWidget {
  const MainAppShell({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('You’re in! (Main app goes here)'),
      ),
    );
  }
}