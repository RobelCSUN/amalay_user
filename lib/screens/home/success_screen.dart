/// /lib/screens/home/success_screen.dart
import 'package:flutter/material.dart';

class SuccessScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Amalay')),
      body: Center(
        child: Text(
          '🎉 You are logged in successfully! 🎉',
          style: TextStyle(fontSize: 20),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
