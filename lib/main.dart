import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:music_player_personal/bindings/home_controller_bindings.dart';
import 'package:music_player_personal/pages/homePage.dart';


void main() {
  runApp(
    const MyApp()
  );
}

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

// class Songs extends StatefulWidget {
//   const Songs({Key? key}) : super(key: key);

//   @override
//   _SongsState createState() => _SongsState();
// }

// class _SongsState extends State<Songs> {
//   // Main method.
//   final OnAudioQuery _audioQuery = OnAudioQuery();
//   final AudioPlayer _player = AudioPlayer();
//   // Indicate if application has permission to the library.
//   bool _hasPermission = false;

//   @override
//   void initState() {
//     super.initState();
//     // // (Optinal) Set logging level. By default will be set to 'WARN'.
//     // //
//     // // Log will appear on:
//     // //  * XCode: Debug Console
//     // //  * VsCode: Debug Console
//     // //  * Android Studio: Debug and Logcat Console
//     // LogConfig logConfig = LogConfig(logType: LogType.DEBUG);
//     // _audioQuery.setLogConfig(logConfig);

//     // // Check and request for permission.
//     checkAndRequestPermissions();
//   }

//   checkAndRequestPermissions({bool retry = false}) async {
//     // The param 'retryRequest' is false, by default.
//     _hasPermission = await _audioQuery.checkAndRequest(
//       retryRequest: retry,
//     );

//     // Only call update the UI if application has all required permissions.
//     _hasPermission ? setState(() {}) : null;
//   }

  
//   playSong(String? uri)async{
//     try {
//       await _player.stop();
//      _player.setAudioSource(AudioSource.uri(Uri.parse(uri!)));
//     final dur = await _player.load();
//     print("time here ${dur}");
//     await  _player.setLoopMode(LoopMode.one);
//     await _player.seek(Duration(minutes: 3)); 
//     await _player.play();
      
//     } on Exception {
//       print("exception occur");
//     }
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("OnAudioQueryExample"),
//         elevation: 2,
//       ),
//       body: Center(
//         child: !_hasPermission
//             ? noAccessToLibraryWidget()
//             : FutureBuilder<List<SongModel>>(
//                 // Default values:
//                 future: _audioQuery.querySongs(
//                   sortType: null,
//                   orderType: OrderType.DESC_OR_GREATER,
//                   uriType: UriType.EXTERNAL,
//                   ignoreCase: true,
//                 ),
//                 builder: (context, item) {
                  
//                   if (item.hasError) {
//                     return Text(item.error.toString());
//                   }

                  
//                   if (item.data == null) {
//                     return const CircularProgressIndicator();
//                   }

                  
//                   if (item.data!.isEmpty) return const Text("Nothing found!");

                 
//                   return ListView.builder(
//                     itemCount: item.data!.length,
//                     itemBuilder: (context, index) {
//                       return GestureDetector(
//                         onTap: (){
//                           playSong(item.data![index].uri);
//                         },
//                         child: ListTile(
//                           title: Text(item.data![index].title),
//                           subtitle: Text(item.data![index].artist ?? "No Artist"),
//                           trailing: const Icon(Icons.arrow_forward_rounded),
                        
//                           leading: QueryArtworkWidget(
//                            // controller: _audioQuery,
//                             id: item.data![index].id,
//                             type: ArtworkType.AUDIO,
//                           ),
//                         ),
//                       );
//                     },
//                   );
//                 },
//               ),
//       ),
//     );
//   }

//   Widget noAccessToLibraryWidget() {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(10),
//         color: Colors.redAccent.withOpacity(0.5),
//       ),
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           const Text("Application doesn't have access to the library"),
//           const SizedBox(height: 10),
//           ElevatedButton(
//             onPressed: () => checkAndRequestPermissions(retry: true),
//             child: const Text("Allow"),
//           ),
//         ],
//       ),
//     );
//   }
// }