import 'package:chat_app_test/routes/routes.dart';
import 'package:flutter/material.dart';


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: RoutesPages.getRoutes() ,
      initialRoute: RoutesPages.initialRoute,
    );
  }
}