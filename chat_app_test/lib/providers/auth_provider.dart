
import 'package:chat_app_test/helper/constanst.dart';
import 'package:chat_app_test/models/chat_user_model.dart';
import 'package:chat_app_test/models/message_model.dart';
import 'package:chat_app_test/models/user_chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
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


enum EnumLoadUser {
  init, 
  loading, 
  load, 
  error,
}

class AuthProviders extends ChangeNotifier {

  late final GoogleSignIn googleSignIn;
  late final FirebaseAuth firebaseAuth;
  late final FirebaseStorage firebaseStorage;
  late final SharedPreferences sharedPreferences;


   AuthProviders({
    required this.googleSignIn, 
    required this.firebaseAuth, 
    required this.firebaseStorage, 
    required this.sharedPreferences,
  });


  static FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  User? get firebaseUserCurrent  => firebaseAuth.currentUser;

  //lista de chat en homepage
  List<ChatUserModel> _listChat = [];

  //usuario actual y su informacion
  ChatUserModel? _userCurrentInfo ;


  List<ChatUserModel> get listChat => _listChat;

  ChatUserModel get userCurrentInfo => _userCurrentInfo!;

  set listChat(List<ChatUserModel> chatUserModel){
    _listChat = chatUserModel;
    notifyListeners();
  }
  
  
  Status _status = Status.uninitialized;
  EnumLoadUser _enumLoadUser = EnumLoadUser.init;

  Status get status => _status;
  EnumLoadUser get enumLoadUser => _enumLoadUser;


 
  String? getUserFirebaseId(){
    return sharedPreferences.getString(FirestoneConstants.id);
  }


  //revisar el login y autenticacion a firebase
  Future<bool> isLoggedIn()async{
    bool isloggin  = await googleSignIn.isSignedIn();
    if(isloggin && sharedPreferences.getString(FirestoneConstants.id)!.isNotEmpty == true) return true;
    return false;
  }


  ///cerrar la session actual del usuario
  Future<void> handlesingOut()async{
    _status = Status.uninitialized;
    await firebaseAuth.signOut();
    await googleSignIn.disconnect();
    await googleSignIn.signOut();
  }


  //obtener la lista de usuarios, menos el usuario actual con session,
  Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(){
    final uid = sharedPreferences.getString(FirestoneConstants.id);
    return firebaseFirestore
      .collection(FirestoneConstants.pathUsercolection)
      .where(FirestoneConstants.id , isNotEqualTo: firebaseUserCurrent!.uid )
      .snapshots();
  }


  //getting the inform user current; 
  Future<void> getSelfInfo()async{
    _enumLoadUser = EnumLoadUser.loading;
    await firebaseFirestore.collection(FirestoneConstants.pathUsercolection)
    .doc(firebaseUserCurrent!.uid).get().then((user)async{
      if(user.exists){
        _userCurrentInfo = ChatUserModel.fromJson(user.data()!);
        _enumLoadUser = EnumLoadUser.load;
        notifyListeners();
      }else{
        await handleSignIn().then((value) => getSelfInfo());
      }
    });
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

      

      User? firebaseUser = (await firebaseAuth.signInWithCredential(authCredential)).user;
      //firebaseUserCurrent = (await firebaseAuth.signInWithCredential(authCredential)).user;

      print(firebaseUserCurrent.toString());


      if(firebaseUser != null){
        //consultamos datos
        final QuerySnapshot query = await FirebaseFirestore.instance
          .collection(FirestoneConstants.pathUsercolection)
          .where(FirestoneConstants.id ,isEqualTo:  firebaseUser.uid)
          .get();

        final List<DocumentSnapshot> documentSnapshot = query.docs;


        if(documentSnapshot.length == 0 ){


          final time = DateTime.now().millisecondsSinceEpoch.toString();
          //crear el usuario a nivel de firabase.
          FirebaseFirestore.instance.collection(FirestoneConstants.pathUsercolection).doc(firebaseUser.uid).set({
            FirestoneConstants.nickName : firebaseUser.displayName, 
            FirestoneConstants.photoUrl : firebaseUser.photoURL, 
            FirestoneConstants.id : firebaseUser.uid, 
            'createdAt' : time, 
            //datos extras por agregar. 
            FirestoneConstants.lastActive : time,
            FirestoneConstants.isOnline : false , 
            FirestoneConstants.pushToken : '',
            FirestoneConstants.chattingWith : null,

          });

          User? currentUser = firebaseUser;

          //guardamos en local.
          await sharedPreferences.setString(FirestoneConstants.id, currentUser.uid);
          await sharedPreferences.setString(FirestoneConstants.nickName, currentUser.displayName ?? '');
          await sharedPreferences.setString(FirestoneConstants.photoUrl, currentUser.photoURL ?? '');
          await sharedPreferences.setString(FirestoneConstants.phoneNumber, currentUser.phoneNumber ?? ''  );
          ///
          // await sharedPreferences.setString(FirestoneConstants.lastActive, currentUser. ?? ''  );
          // await sharedPreferences.setString(FirestoneConstants.pushToken, currentUser.phoneNumber ?? ''  );
          // await sharedPreferences.setBool(FirestoneConstants.isOnline, currentUser.phoneNumber ?? ''  );



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

  /**
   * 
   * seccion de chat.
   * 
  */

  //obtener la conversacion segun el id pasado por parametros. 
  String getConversationID(String id){
    return firebaseUserCurrent!.uid.hashCode <= id.hashCode ?
    '${firebaseUserCurrent!.uid}_$id' : '${id}_${firebaseUserCurrent!.uid}';
  }

  //
  Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages({
    required ChatUserModel chatUserModel,
  }){
    return firebaseFirestore
      .collection(
        "chats/${getConversationID(firebaseUserCurrent!.uid)}/messages/"
      )
      .snapshots();
  }

 
  //enviar el mensaje.
  Future<void> sendMessage({
    required ChatUserModel chatUserModel, 
    required String msgs,
  })async{
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    //enviando el mensaje
    final MessageModel messageModel = MessageModel(
      msg: msgs,
      read: '',
      told: chatUserModel.id, 
      type: 'text',
      fromId: firebaseUserCurrent!.uid,
      sent: time,
    );

    final ref = firebaseFirestore.collection("chats/${getConversationID(chatUserModel.id)}/messages/");
    await ref.doc(time).set(messageModel.toJson());

  }

  


}