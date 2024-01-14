import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:music_player_personal/controllers/home_page_controller.dart';
import 'package:on_audio_query/on_audio_query.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        // App is visible and running in the foreground
        log("App resumed");
        break;
      case AppLifecycleState.inactive:
        // App is in an inactive state (e.g., on a phone call)
        log("App inactive");
        break;
      case AppLifecycleState.paused:
        // App is in the background
        log("App paused");
        break;
      case AppLifecycleState.detached:
        // App is detached from the Flutter engine (rarely used)
        controller.player.stop();
        log("App detached");
        break;

      case AppLifecycleState.hidden:
        log("hidden");
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  final controller = Get.find<HomePageController>();
  @override
  Widget build(BuildContext context) {
    return Obx(()=>
       Scaffold(
        bottomNavigationBar: controller.isBottomBannerAdLoaded.value
            ?  SizedBox(
                height: controller.bottomBannerAd.size.height.toDouble(),
                width: controller.bottomBannerAd.size.width.toDouble(),
                child: AdWidget(ad: controller.bottomBannerAd),
              )
            : null,
        appBar: AppBar( 
          backgroundColor: const Color.fromARGB(255, 181, 88, 228),
          title: const Text("Music Player"),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Badge(
                label: Obx(() => Text(controller.data.length.toString())),
                child: const Icon(Icons.music_note),
              ),
            ),
            PopupMenuButton(
                // add icon, by default "3 dot" icon
                offset: const Offset(0, 40),
                icon: const Icon(Icons.sort),
                itemBuilder: (context) {
                  return [
                    const PopupMenuItem<int>(
                      value: 0,
                      child: Text("Sort by date added"),
                    ),
                    const PopupMenuItem<int>(
                      value: 1,
                      child: Text("sort by song name"),
                    ),
                    const PopupMenuItem<int>(
                      value: 2,
                      child: Text("sort by artist"),
                    ),
                  ];
                },
                onSelected: (value) {
                  if (value == 0) {
                    controller.player.stop();
                    controller.sortSongByAlphaDec(SongSortType.DATE_ADDED);
                  } else if (value == 1) {
                    controller.player.stop();
                    controller.sortSongByAlphaDec(SongSortType.TITLE);
                  } else if (value == 2) {
                    controller.player.stop();
                    controller.sortSongByAlphaDec(SongSortType.ARTIST);
                  }
                }),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all()),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: TextField(
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Search songs",
                        suffixIcon: Icon(Icons.search)),
                    onChanged: (val) {
                      controller.searchSongs(val);
                    },
                  ),
                ),
              ),
            ),
            Obx(() => controller.hasPermission.value
                ? controller.dataFetched.value
                    ? Expanded(
                        child: ListView.builder(
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                controller.playSong(
                                    controller.data[index].uri, index);
                              },
                              child: Obx(
                                () => ListTile(
                                  title: Text(controller.data[index].title),
                                  subtitle: Text(controller.data[index].artist!),
                                  trailing: controller.isSongTapped.value
                                      ? controller.currentPlaySong.value == index
                                          ? const Icon(Icons.pause)
                                          : const Icon(Icons.play_arrow)
                                      : const Icon(Icons.play_arrow),
                                  leading: QueryArtworkWidget(
                                    // controller: _audioQuery,
                                    id: controller.data[index].id,
                                    type: ArtworkType.AUDIO,
                                  ),
                                ),
                              ),
                            );
                          },
                          itemCount: controller.data.length,
                        ),
                      )
                    : const Center(child: CircularProgressIndicator())
                : noAccessToLibraryWidget()),
          ],
        ),
      ),
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
