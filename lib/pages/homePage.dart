import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player_personal/controllers/home_page_controller.dart';
import 'package:on_audio_query/on_audio_query.dart';

class HomePage extends GetWidget<HomePageController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 181, 88, 228),
        title:const Text("Music Player"),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal:20.0),
            child: Badge(
              
              label: Obx(()=> Text(controller.data.length.toString())),
              child:const Icon(Icons.music_note) ,
            ),
          )
        ],
      ),
      body: Obx(
          () => controller.hasPermission.value

              ? controller.dataFetched.value?ListView.builder(itemBuilder: (context, index) {
                  return  GestureDetector(
                    onTap: (){
                      controller.playSong(controller.data[index].uri,index);
                    },
                    child: Obx(()=>
                       ListTile(
                        title: Text(controller.data[index].title),
                        subtitle: Text(controller.data[index].artist!),
                        trailing:controller.isSongTapped.value?controller.currentPlaySong.value == index? const Icon(Icons.pause):
                         const Icon(Icons.play_arrow):const Icon(Icons.play_arrow),
                      
                        leading: QueryArtworkWidget(
                         // controller: _audioQuery,
                          id: controller.data[index].id,
                          type: ArtworkType.AUDIO,
                        ),
                      ),
                    ),
                  );

                },itemCount: controller.data.length,):const Center(child: CircularProgressIndicator())
              : noAccessToLibraryWidget()),
    );
  }

  Widget noAccessToLibraryWidget() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.redAccent.withOpacity(0.5),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Application doesn't have access to the library"),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => controller.checkAndRequestPermissions(retry: true),
            child: const Text("Allow"),
          ),
        ],
      ),
    );
  }
}
