import 'dart:io';

import 'package:chat_app_test/models/chat_user_model.dart';
import 'package:chat_app_test/providers/auth_provider.dart';
import 'package:chat_app_test/providers/permission_providers.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class AlertWidgets {

  ///mostrar el dialog para elegir entre galeria o camara.
  static Future showDialogImage({
    required BuildContext context,
    required ChatUserModel chatUserModel,
  }) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: Column(
              children: [
                MaterialButton(
                  onPressed: (() async{
                    final permissionsProvider = Provider.of<PermissionsProvider>(context,listen: false);
                    await permissionsProvider.initPermissions();

                    await permissionsProvider.requestPermissionCamera().then((value) {
                      if (permissionsProvider.cameraPermissionStatus == PermissionStatus.granted) {
                        //inizialedCamera();
                        
                      } else {
                        //mostrar una alerta dialog
                        print("permisos status denegados: ${permissionsProvider.galleryPermissionStatus}");
                        const  snackBar =  SnackBar(
                          content: Text('Por favor ir a configraciones a\ngestionar permisos de camara.'),
                          duration: Duration(seconds: 3),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                    });

                    Navigator.pop(context);
                  }),
                  child: const Row(
                    children:  [
                       Icon(Icons.camera_alt), 
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Tomar Foto'  , 
                        style: TextStyle(fontSize: 15 , color: Colors.black, fontWeight: FontWeight.w500) ,),
                      ),
                    ],
                  )
                ),
                MaterialButton(
                  onPressed: () async{
                    final permissionsProvider = Provider.of<PermissionsProvider>(context,listen: false);
                    await permissionsProvider.initPermissions();

                    await permissionsProvider.requestPermissionPhotos().then((value) {
                      if (permissionsProvider.galleryPermissionStatus == PermissionStatus.granted) {
                        initializeGalery(context: context, chatUserModel: chatUserModel);
                        //Navigator.pop(context);
                      } else {
                        //mostrar una alerta dialog
                        print("permisos status denegados: ${permissionsProvider.galleryPermissionStatus}");
                        const  snackBar =  SnackBar(
                          content: Text('Por favor ir a configraciones a\ngestionar permisos de galeria.'),
                          duration: Duration(seconds: 2),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                    });
                    Navigator.pop(context);
                  },
                  child: const Row(
                    children:  [
                      Icon(Icons.photo_camera_back_rounded), 
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Abrir Galeria' , 
                        style: TextStyle(fontSize: 15 , color: Colors.black, fontWeight: FontWeight.w500)),
                      ),
                    ],
                  )
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  //enviar la imagen selecionada.
  static Future initializeGalery({
    required BuildContext context,
    required ChatUserModel chatUserModel,
  })async{
    final authProviders = Provider.of<AuthProviders>(context, listen: false);
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if(image != null){
      await authProviders.sendImageChat(chatUserModel, File(image.path));
    }
    
  }




}
