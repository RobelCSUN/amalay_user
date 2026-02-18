// lib/app/app.dart
import 'package:flutter/material.dart';
import 'package:amalay_user/app/app_routes.dart';
import 'package:amalay_user/app/app_scope.dart';
import 'package:amalay_user/theme/app_theme.dart';

class AmalayUserApp extends StatelessWidget {
  final AppScope scope;

  const AmalayUserApp({super.key, required this.scope});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Amalay',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRoutes.home,
      onGenerateRoute: (settings) => AppRoutes.onGenerateRoute(settings, scope),
    );
  }
}
