

///informacion del dispositivo para saber si es IOS o ANDROID , o HUAWEI 
///revisar los permisos a tiendas correspondientes
///

import 'dart:io';
import 'package:flutter/services.dart';
import 'package:google_api_availability/google_api_availability.dart';

class GetDeviceInformation {

  static const iosPlaform = "IOS";
  static const googlePlaform = "GOOGLE";
  static const huaweiPlaform = "HUAWEI";
  static const androidPlaform = "ANDROID";

  /// obtiene el sistema operativo del dispositivo que corre la aplicacion
  static Future<String?> getPlatformName() async {
    try {
      /// valida si el Sistema Operativo es iOS, si es asi, termina el flujo y retorna 'IOS'
      if (Platform.isIOS) {
        return iosPlaform;
        // valida si el Sistema Operativo es Android
      } else if (Platform.isAndroid) {
        /// valida si Servicios de Google estan disponibles en el dispositivo
        bool? reviewOS = await checkPlayServices();

        /// si retorna 'true' la funcion que ejecuta esta validacion, entonces retorna 'GOOGLE'
        if (reviewOS == true) {
          return googlePlaform;
        } else {
          /// caso contrario, si dispositivo no tiene disponible Servicios de Google, lo cataloga como dispositivo 'HUAWEI'
          return huaweiPlaform;
        }
      }
      return null;
    } on PlatformException {
      return null;
    }
  }

  /// valida Servicios de Google en dispositivos
  static Future<bool?> checkPlayServices() async {
    try {
      GooglePlayServicesAvailability availability = await GoogleApiAvailability
          .instance
          .checkGooglePlayServicesAvailability();

      if (availability.value == 0) {
        return true;
      } else {
        return false;
      }
    } on PlatformException {
      return null;
    }
  }

  /// obtiene el sistema operativo del dispositivo que corre la aplicacion
  static  String getOsName() {
    try {
      /// valida si el Sistema Operativo es iOS, si es asi, termina el flujo y retorna 'IOS'
      if (Platform.isIOS) {
        return iosPlaform;
        // valida si el Sistema Operativo es Android
      } else if (Platform.isAndroid) {
        return androidPlaform;
      }
      return "";
    } on PlatformException {
      return "";
    }
  }
}
