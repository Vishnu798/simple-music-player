import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:just_audio_background/just_audio_background.dart';
class HomePageController extends GetxController {
  RxBool hasPermission = false.obs;
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final AudioPlayer player = AudioPlayer();
  RxBool dataFetched = false.obs;
  RxInt currentPlaySong = 100000.obs;
  RxBool isSongTapped = false.obs;
  List data = [].obs;
  RegExp numericPattern = RegExp(r'^[0-9]+$');
  @override
  void onInit() async {
    super.onInit();
    await checkAndRequestPermissions();
    playerStatesmethod();
  }
  
  checkAndRequestPermissions({bool retry = false}) async {
    // The param 'retryRequest' is false, by default.
    hasPermission.value = await _audioQuery.checkAndRequest(
      retryRequest: retry,
    );
    if (hasPermission.value) {
      final localSongs = await _audioQuery.querySongs(
        sortType: SongSortType.DATE_ADDED,
        orderType: OrderType.DESC_OR_GREATER,
        uriType: UriType.EXTERNAL,
        ignoreCase: false,
      );

      for (int i = 0; i < localSongs.length; i++) {
        if (localSongs[i].fileExtension == "mp3" &&
            !isNumeric(localSongs[i].title) &&
            localSongs[i].album != "Standard Recordings") {
          data.add(localSongs[i]);
        }
      }
      
     // data.sort((a,b)=>b.dateAdded!.compareTo(a.dateAdded!));
      dataFetched.value = true;
      return;
    }
    // Only call update the UI if application has all required permissions.
    //  checkAndRequestPermissions(retry: true);
  }

  playerStatesmethod(){
   
    player.playerStateStream.listen((state) {
  if (state.playing) {
    isSongTapped.value = true;
    print("Audio is playing");
  } else if (state.processingState == ProcessingState.completed) {
    print("Audio has finished");
  } else if (state.processingState == ProcessingState.buffering) {
    print("Audio is buffering");
  }
  else{
    isSongTapped.value = false;
    print("player stop in stream player listen");
  } 
});
  }

  bool isNumeric(String str) {
    return numericPattern.hasMatch(str);
  }

  playSong(String? uri, int index) async {
    try {
      isSongTapped.value = !isSongTapped.value;

      if (isSongTapped.value) {
        if(currentPlaySong.value!=index){
        currentPlaySong.value = index;
 player.setAudioSource(AudioSource.uri(Uri.parse(uri!),
        tag: MediaItem(
        id: data[index].id.toString(),
        album: data[index].album,
        title: data[index].title,
        artUri: Uri.parse(uri),
      ),
        ));
        }
      
       
        // final dur = await player.load();
        player.play();
        player.setLoopMode(LoopMode.one);
      } else {
        if (currentPlaySong.value != index) {
          isSongTapped.value = !isSongTapped.value;
          currentPlaySong.value = index;
          player.setAudioSource(AudioSource.uri(Uri.parse(uri!),tag: MediaItem(
        id: data[index].id.toString(),
        album: "Science Friday",
        title: "From Cat Rheology To Operatic Incompetence",
        artUri: Uri.parse(uri),
      ),));
          // final dur = await player.load();
          player.play();
          print("player already played");
          
        } else {
          player.pause();
          
        }
      }

      // await player.seek(Duration(minutes: 3));
    } on Exception {
      debugPrint("exception occur on playing song");
    }
  }
  

}
