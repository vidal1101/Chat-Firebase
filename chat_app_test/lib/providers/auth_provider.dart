
import 'dart:io';

import 'package:chat_app_test/helper/constanst.dart';
import 'package:chat_app_test/models/chat_user_model.dart';
import 'package:chat_app_test/models/message_model.dart';
import 'package:chat_app_test/models/user_chat.dart';
import 'package:chat_app_test/providers/custom_notification.dart';
import 'package:chat_app_test/request/fcm_notification.dart';
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

  //obtener el otoken del dispositivo despues de iniciar la app,
  // y setearlo al hacer login o registrar al usuario
  Future<void> getFirebaseMessagingToken()async{
    if(PushNotificationService.token != null ){
      userCurrentInfo.pushToken = PushNotificationService.token!;
    }
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
        await getFirebaseMessagingToken(); //setear el token del dispositivo. realizar un update.
        ///
        await updateActiveStatus(true);
        _enumLoadUser = EnumLoadUser.load;
        notifyListeners();
      }else{
        await handleSignIn().then((value) => getSelfInfo());
      }
    });
  }

  //cambiar el status del token y estado activo.
  Future<void> updateActiveStatus(bool isOnline)async{
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    await firebaseFirestore.collection(FirestoneConstants.pathUsercolection)
    .doc(firebaseUserCurrent!.uid).update({
      FirestoneConstants.isOnline : isOnline, 
      FirestoneConstants.lastActive : time, 
      FirestoneConstants.pushToken : userCurrentInfo.pushToken, 
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

          //obtener el token y asignarlo 
          //await getFirebaseMessagingToken();

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
        "chats/${getConversationID(chatUserModel.id)}/messages/"
      )
      .snapshots();
  }

 
  //enviar el mensaje.
  Future<void> sendMessage({
    required ChatUserModel chatUserModel, 
    required String msgs,
    required String type,
  })async{
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    //enviando el mensaje
    final MessageModel messageModel = MessageModel(
      msg: msgs,
      read: '',
      told: chatUserModel.id, 
      type: type,
      fromId: firebaseUserCurrent!.uid,
      sent: time,
    );

    final ref = firebaseFirestore.collection("chats/${getConversationID(chatUserModel.id)}/messages/");
    await ref.doc(time).set(messageModel.toJson()).then((value) async{
      //enviar la notificacion al otro usuario remitente. 
      await FcmNotificationRequest().sendNotification(chatUserModel: chatUserModel, msg: msgs);
    });

  }


  Future<void> updateMessageReadStatus(MessageModel messageModel)async{
    firebaseFirestore.collection("chats/${getConversationID(messageModel.fromId)}/messages/",)
      .doc(messageModel.sent)
      .update({'read': DateTime.now().millisecondsSinceEpoch.toString() });
  }

  //obtener el ultimo mensaje
  Stream<QuerySnapshot> getLastMessage(ChatUserModel chatUserModel){
    return firebaseFirestore
      .collection("chats/${getConversationID(chatUserModel.id)}/messages/")
      .orderBy('sent', descending: true)
      .limit(1)
      .snapshots();
  }



  Future<void> sendImageChat(ChatUserModel chatUserModel, File file)async{
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    //extraer extension de la imagen.
    final ext = file.path.split('.').last;

    //referencia del archivo a firebase Storage.
    final ref = firebaseStorage.ref().child(
      "images/${getConversationID(chatUserModel.id)}/$time.$ext"
    );

    //subiendo el archivo
    await ref.
      putFile(file, SettableMetadata(contentType: "image/$ext") )
      .then((p0){
        debugPrint('data tranfiriendo: ${p0.bytesTransferred / 1000} kb');
    });

    //obtener ruta absoluta de la imagen.
    final imageUrl = await ref.getDownloadURL();
    //enviar el mensaje con la imagen
    await sendMessage(chatUserModel: chatUserModel, msgs: imageUrl, type: 'image');

  }
  
}