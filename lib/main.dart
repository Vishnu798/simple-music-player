import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'package:music_player_personal/bindings/home_controller_bindings.dart';
import 'package:music_player_personal/pages/homePage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() async {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    MobileAds.instance.initialize();
     await Firebase.initializeApp(
     options: DefaultFirebaseOptions.currentPlatform,);
    // The following lines are the same as previously explained in "Handling uncaught errors"
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
     await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
    preloadArtwork: true,
    androidNotificationClickStartsActivity: false
  );
    runApp(const MyApp());
  }, (error, stack) => FirebaseCrashlytics.instance.recordError(error, stack));
}
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
// );
// // FirebaseCrashlytics.instance.crash();
//   await JustAudioBackground.init(
//     androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
//     androidNotificationChannelName: 'Audio playback',
//     androidNotificationOngoing: true,
//     preloadArtwork: true,
//     androidNotificationClickStartsActivity: false
//   );
//   runApp(const MyApp());
// }

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
     getPages: [GetPage(name: '/', page: ()=>const HomePage(),binding: HomeControllerBindings())],
    );

  }
}

