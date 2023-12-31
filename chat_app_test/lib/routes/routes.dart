
import 'package:chat_app_test/pages/pages.dart';
import 'package:flutter/material.dart';

class RoutesPages {

  static String initialRoute = "splash";
  static String secondRoute  = "home";

  static Map<String, WidgetBuilder> getRoutes(){
    return <String, WidgetBuilder> {
      "home" :(context) => const HomePage(),
      "splash" : (context) => const SplashPage(),
    };
  }

}