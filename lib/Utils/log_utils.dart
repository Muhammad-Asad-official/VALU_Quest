import 'package:flutter/foundation.dart';

class LogUtils {
  static void log(String title,Object msg){
    if (kDebugMode) {
      print(" $title: $msg");
    }
  }
}
