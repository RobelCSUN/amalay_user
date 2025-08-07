import 'package:flutter/material.dart';
import '../screens/home/home_screen.dart';
import 'app_routes.dart';

class AmalayUserApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Amalay User',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: HomeScreen(),
      routes: AppRoutes.routes,
    );
  }
}
