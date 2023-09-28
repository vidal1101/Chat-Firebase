
import 'package:chat_app_test/app.dart';
import 'package:chat_app_test/providers/custom_notification.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async{

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  //inicializar el serviocio de las notificaciones
  await PushNotificationService.initializedApp();
  
  SharedPreferences prefs = await SharedPreferences.getInstance();


  runApp( MyApp(prefs: prefs,));
}