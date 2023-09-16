import 'package:chat_app_test/providers/auth_provider.dart';
import 'package:chat_app_test/providers/initproviders.dart';
import 'package:chat_app_test/routes/routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';



class MyApp extends StatelessWidget {

  final SharedPreferences prefs; 
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {

    return  MultiProvider(
      providers: [
        //providers
        ChangeNotifierProvider<AuthProviders>(create: (context) => AuthProviders(
          googleSignIn: GoogleSignIn(),
          firebaseAuth: FirebaseAuth.instance,
          firebaseStorage: firebaseStorage, 
          sharedPreferences: prefs),
        ), 
      ], 
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        routes: RoutesPages.getRoutes() ,
        initialRoute: RoutesPages.initialRoute,
      ),
    );
  }
}