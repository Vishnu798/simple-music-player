import 'dart:io';

class AdHelper{
  static String get getBannerId{
    if(Platform.isAndroid){
      return "ca-app-pub-3940256099942544/6300978111";
    }
    else if(Platform.isIOS){
      return "ca-app-pub-3940256099942544/6300978111";
    }
    else{
      throw UnsupportedError("unsupported platform");
    }
  }

  static String get getInteristialId{
    if(Platform.isAndroid){
      return "ca-app-pub-3940256099942544/1033173712";
    }
    else if(Platform.isIOS){
      return "ca-app-pub-3940256099942544/1033173712";
    }
    else{
      throw UnsupportedError("unsupported platform");
    }
  }
}