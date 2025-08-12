import 'package:flutter/material.dart';
import 'package:amalay_user/screens/home/home_screen.dart';

class AppRoutes {
  static const home = '/home';

  static final routes = <String, WidgetBuilder>{home: (_) => HomeScreen()};
}
