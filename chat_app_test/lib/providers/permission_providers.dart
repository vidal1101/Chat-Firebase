

import 'package:chat_app_test/helper/get_device_information.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

//solictar permisos de camara y galeria en ios / android
///**
/// implementacion:
///  final permissionsProvider =  Provider.of<PermissionsProvider>(context, listen: false);
///  await permissionsProvider.initPermissions();
///  await permissionsProvider.requestPermissionPhotos().
///
///
///
class PermissionsProvider with ChangeNotifier {

  ///variable 
  PermissionStatus? _cameraPermissionStatus = PermissionStatus.denied;
  PermissionStatus? _galleryPermissionStatus = PermissionStatus.denied;

  PermissionsProvider() {
    initPermissions();
  }

  PermissionStatus get cameraPermissionStatus => _cameraPermissionStatus!;
  PermissionStatus get galleryPermissionStatus => _galleryPermissionStatus!;

  //iniciliazar los permoisos
  Future<void> initPermissions() async {
    final String? getPlatform = await GetDeviceInformation.getPlatformName();
    (getPlatform!.contains('IOS'))
        ? _galleryPermissionStatus = await Permission.photos.status
        : _galleryPermissionStatus = await Permission.storage.status;
    //ambos plataformas
    _cameraPermissionStatus = await Permission.camera.status;
    notifyListeners();
  }

  Future<void> requestPermissionCamera() async {
    if (_cameraPermissionStatus != PermissionStatus.granted) {
      final status = await Permission.camera.request();
      _cameraPermissionStatus = status;
      notifyListeners();
    }
  }

  Future<void> requestPermissionPhotos() async {
    if (_galleryPermissionStatus != PermissionStatus.granted) {
      PermissionStatus status;

      final String? getPlatform = await GetDeviceInformation.getPlatformName();
      if (getPlatform!.contains('IOS')){
        status = await Permission.photos.request();
         _galleryPermissionStatus = status;
      } 
      if (getPlatform.contains('HUAWEI')) {
        status = await Permission.storage.request();
        _galleryPermissionStatus = status;
      }
      if (getPlatform.contains('ANDROID')) {
        status = await Permission.storage.request();
        _galleryPermissionStatus = status;
      }
      if (getPlatform.contains('GOOGLE')) {
        status = await Permission.storage.request();
        _galleryPermissionStatus = status;
      }

      notifyListeners();
    }
  }
}
