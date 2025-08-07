import 'package:flutter/material.dart';
import '../screens/home/home_screen.dart';

class AppRoutes {
  static const home = '/home';

  static final routes = <String, WidgetBuilder>{
    home: (_) => HomeScreen()
  };
}
