import 'package:flutter/material.dart';


class FunctionHelpersChat {


  static String getFormatTime({
    required BuildContext context , required String time, 
  }){
    final date  = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    return TimeOfDay.fromDateTime(date).format(context);
  }


}