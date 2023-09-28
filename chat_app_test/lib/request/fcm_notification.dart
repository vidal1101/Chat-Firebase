import 'dart:convert';
import 'dart:io';

import 'package:chat_app_test/models/chat_user_model.dart';
import 'package:http/http.dart' as http;


//clave del servido de cloudMessaging
String KeyServer = "key=AAAAB99tkWY:APA91bGT3Ziwzn_WVrY4z9-ipTQVidLYyJwGlKQFf6FSf-ECXt5JV5RXPbPCiiefAdxD7T2cNpETLWubb30HjBx1V5IC617vAKOosc1R8mEVllre8RfBTnfajSFGl2YlDvq3nTLvso7_";
//api de fcm para servicio de notificaciones
String UrlFcm = "https://fcm.googleapis.com/fcm/send";
//header de auturizacion y tipo.
final HeadersFcm = {
  HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
  HttpHeaders.authorizationHeader: KeyServer,
};


class FcmNotificationRequest {


  Future<void> sendNotification({
    required ChatUserModel chatUserModel, 
    required String msg,
  })async{
    //body de la request.
   try {

    final body = {
        "to": chatUserModel.pushToken, 
        "notification": {
          "title" : chatUserModel.nickname,
          "body" : msg,
        }
    };

    final response = await http.post(
      Uri.parse(UrlFcm), 
      headers: HeadersFcm, 
      body:  jsonEncode(body),
    );

    print("${response.statusCode}");

   } catch (e) {
     print(e); 
   }

  }



}

