
import 'package:chat_app_test/helper/constanst.dart';
import 'package:chat_app_test/models/user_chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Status {
  uninitialized,
  authenticated, 
  authenticating, 
  authenticateError, 
  authenticateCanceled,
}

class AuthProviders extends ChangeNotifier {

  late final GoogleSignIn googleSignIn;
  late final FirebaseAuth firebaseAuth;
  late final FirebaseStorage firebaseStorage;
  late final SharedPreferences sharedPreferences;

  Status _status = Status.uninitialized;

  Status get status => _status;


  AuthProviders({
    required this.googleSignIn, 
    required this.firebaseAuth, 
    required this.firebaseStorage, 
    required this.sharedPreferences,
  });

  String? getUserFirebaseId(){
    return sharedPreferences.getString(FirestoneConstants.id);
  }

  Future<bool> isLoggedIn()async{
    bool isloggin  = await googleSignIn.isSignedIn();
    if(isloggin && sharedPreferences.getString(FirestoneConstants.id)!.isNotEmpty == true) return true;
    return false;
  }

  Future<bool> handleSignIn ()async{

    _status = Status.authenticating;
    notifyListeners();

    GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if(googleUser != null){
      GoogleSignInAuthentication? googleAuth = await googleUser.authentication;
      final AuthCredential authCredential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      User? firebaseUser = (await firebaseAuth..signInWithCredential(authCredential)).currentUser;

      if(firebaseUser != null){
        //consultamos datos
        final QuerySnapshot query = await FirebaseFirestore.instance
          .collection(FirestoneConstants.pathUsercolection)
          .where(FirestoneConstants.id ,isEqualTo:  firebaseUser.uid)
          .get();

        final List<DocumentSnapshot> documentSnapshot = query.docs;


        if(documentSnapshot.length == 0 ){
          
          //obtenemos instancia del usuario actual
          FirebaseFirestore.instance.collection(FirestoneConstants.pathUsercolection).doc(firebaseUser.uid).set({
            FirestoneConstants.nickName : firebaseUser.displayName, 
            FirestoneConstants.photoUrl : firebaseUser.photoURL, 
            FirestoneConstants.id : firebaseUser.uid, 
            'createdAt' : DateTime.now().millisecondsSinceEpoch.toString(), 
            FirestoneConstants.chattingWith : null,
          });

          User? currentUser = firebaseUser;

          //guardamos en local.
          await sharedPreferences.setString(FirestoneConstants.id, currentUser.uid);
          await sharedPreferences.setString(FirestoneConstants.nickName, currentUser.displayName ?? '');
          await sharedPreferences.setString(FirestoneConstants.photoUrl, currentUser.photoURL ?? '');
          await sharedPreferences.setString(FirestoneConstants.phoneNumber, currentUser.phoneNumber ?? ''  );


        }else{

          DocumentSnapshot docuSnapshot = documentSnapshot[0];
          UserChat userChat = UserChat.fromDocument(docuSnapshot);

          await sharedPreferences.setString(FirestoneConstants.id, userChat.id);
          await sharedPreferences.setString(FirestoneConstants.nickName, userChat.nickName);
          await sharedPreferences.setString(FirestoneConstants.photoUrl, userChat.photoURL);
          await sharedPreferences.setString(FirestoneConstants.aboutMe, userChat.aboutMe);
          await sharedPreferences.setString(FirestoneConstants.phoneNumber, userChat.phoneNumber );

        }


        _status = Status.authenticated; 

        notifyListeners();

        return true;


      }else{
        _status = Status.authenticateError; 
        notifyListeners();
        return false;
      }

    
    }else{
      _status = Status.authenticateCanceled; 
      notifyListeners();
      return false;
    }

  }

  ///cerrar la session actual del usuario
  Future<void> handlesingOut()async{
    _status = Status.uninitialized;
    await firebaseAuth.signOut();
    await googleSignIn.disconnect();
    await googleSignIn.signOut();
  }



}