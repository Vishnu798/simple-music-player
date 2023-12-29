import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

class HomePageController extends GetxController {
  RxBool hasPermission = false.obs;
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final AudioPlayer _player = AudioPlayer();
  RxBool dataFetched = false.obs;
  RxInt currentPlaySong = 100000.obs;
  RxBool isSongTapped = false.obs;
  List data = [].obs;
  RegExp numericPattern = RegExp(r'^[0-9]+$');
  @override
  void onInit() async {
    super.onInit();
    await checkAndRequestPermissions();
  }

  checkAndRequestPermissions({bool retry = false}) async {
    // The param 'retryRequest' is false, by default.
    hasPermission.value = await _audioQuery.checkAndRequest(
      retryRequest: retry,
    );
    if (hasPermission.value) {
      final localSongs = await _audioQuery.querySongs(
        sortType: null,
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

      dataFetched.value = true;
      return;
    }
    // Only call update the UI if application has all required permissions.
    //  checkAndRequestPermissions(retry: true);
  }

  bool isNumeric(String str) {
    return numericPattern.hasMatch(str);
  }

  playSong(String? uri, int index) async {
    try {
      isSongTapped.value = !isSongTapped.value;

      if (isSongTapped.value) {
        currentPlaySong.value = index;
        _player.stop();
        _player.setAudioSource(AudioSource.uri(Uri.parse(uri!)));
        // final dur = await _player.load();
        _player.play();
        _player.setLoopMode(LoopMode.one);
      } else {
        if (currentPlaySong.value != index) {
          isSongTapped.value = !isSongTapped.value;
          currentPlaySong.value = index;
          _player.stop();
          _player.setAudioSource(AudioSource.uri(Uri.parse(uri!)));
          // final dur = await _player.load();
          _player.play();
          _player.setLoopMode(LoopMode.one);
        } else {
          _player.stop();
        }
      }

      // await _player.seek(Duration(minutes: 3));
    } on Exception {
      debugPrint("exception occur on playing song");
    }
  }
}
