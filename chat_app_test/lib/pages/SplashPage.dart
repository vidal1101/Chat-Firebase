
import 'package:chat_app_test/pages/pages.dart';
import 'package:chat_app_test/providers/auth_provider.dart';
import 'package:chat_app_test/providers/custom_notification.dart';
import 'package:chat_app_test/providers/permission_providers.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed( const Duration(seconds: 5),() async{
      await getAllPermission();
      await checkSignIn(context);
    },);
  }


  //obtener permisos de notificaciones, camara, galeria.
  Future<void> getAllPermission()async{
    //permisos de camara.
    final permissionsProvider = Provider.of<PermissionsProvider>(context,listen: false);
    await permissionsProvider.initPermissions();
    await permissionsProvider.requestPermissionCamera().then((value) {
        print("permisos de camara: ${permissionsProvider.cameraPermissionStatus}");
    });
    //permisos de galeria. 
    await permissionsProvider.initPermissions();
    await permissionsProvider.requestPermissionPhotos().then((value) {
      print("permisos de galeria: ${permissionsProvider.galleryPermissionStatus}");
    });

    //permisos de notificaciones
    NotificationSettings settings = await PushNotificationService.messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print(settings);
 
  }


  Future<void> checkSignIn(BuildContext context)async{
    final authProvider = Provider.of<AuthProviders>(context, listen:  false);

    bool isLogin = await authProvider.isLoggedIn();
    if(isLogin){
      Navigator.pushReplacement(context, MaterialPageRoute(builder:(context) => HomePage() ));
      return;
    }else{
      Navigator.pushReplacement(context, MaterialPageRoute(builder:(context) => LoginPage() ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Cargando, espere por favor ...', 
              style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
            CircularProgressIndicator(
              color: Colors.purpleAccent,
            ),
          ],
        ),
      ),
    );
  }
}