

import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
//sha1: 32:88:79:71:6E:D6:51:C4:A7:14:37:EE:39:9F:01:E5:23:BE:AF:C8


class PushNotificationService {

  static FirebaseMessaging messaging= FirebaseMessaging.instance;// instancia de firebase messagging 

  static String? token ;

  static StreamController<String> _messagestreamController = new StreamController.broadcast();
  //obtener la informacion y navegar a otra pantalla


  static Stream<String> get getmessageStream {
    return _messagestreamController.stream;
  }


  //handler
  /**
   * cuando la app esta cerrada pero en memoria ram 
   */
  static Future _backgroundHandler(RemoteMessage message )async{ 
    //print( 'en background handler: ${message.messageId}');
    _messagestreamController.add(message.data['producto'] ?? 'not data' );
  }

/**
 * cuando la app esta en uso
 */
  static Future _onMessageHandler(RemoteMessage message )async{
    //print( 'en mensaje handler: ${message.messageId}');
    //_messagestreamController.add(message.notification?.body ?? 'not title' );
    //print(message.data['producto']);
    _messagestreamController.add(message.data['producto'] ?? 'not data' );

  }

/**
 * cuando esta cerrada y quitada de memoria
 */
  static Future _onMessageOpenApp(RemoteMessage message )async{
    //print( 'en open app handler: ${message.messageId}');
    print(message.data);
    _messagestreamController.add(message.data['producto'] ?? 'not data' );

  }



  static Future initializedApp()async{
    //push notifications 
    await Firebase.initializeApp();

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print(settings);

    token = await FirebaseMessaging.instance.getToken();

    print('token del dispositivo:  ${token}');

    //handler
    FirebaseMessaging.onBackgroundMessage( _backgroundHandler );
    FirebaseMessaging.onMessage.listen( _onMessageHandler );
    FirebaseMessaging.onMessageOpenedApp.listen( _onMessageOpenApp );


    //local notifications
  }

  static closestream (){
    _messagestreamController.close();
  }


}