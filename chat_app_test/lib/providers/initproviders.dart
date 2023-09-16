import 'package:chat_app_test/providers/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';


class MultiProviders {

  final SharedPreferences prefs; 
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  MultiProviders({required this.prefs});


  static List<SingleChildWidget> initProviders(){
    return <SingleChildWidget> [
      //
    ];
  }


}