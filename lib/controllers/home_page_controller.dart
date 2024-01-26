import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_player_personal/helper/ad_helper.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:just_audio_background/just_audio_background.dart';
class HomePageController extends GetxController {
  late BannerAd bottomBannerAd;

  RxBool hasPermission = false.obs;
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final AudioPlayer player = AudioPlayer();
  RxBool dataFetched = false.obs;
  RxInt currentPlaySong = 100000.obs;
  RxBool isSongTapped = false.obs;
  RxList data = [].obs;
  List allSongs = [].obs;
  TextEditingController searchController = TextEditingController();
  RegExp numericPattern = RegExp(r'^[0-9]+$');
  RxBool isBottomBannerAdLoaded = false.obs;
  @override
  void onInit() async {
    super.onInit();
    await checkAndRequestPermissions();
    createBottomBannerAd();
    playerStatesmethod();
  }
  
  checkAndRequestPermissions({bool retry = false}) async {
    hasPermission.value = await _audioQuery.checkAndRequest(
      retryRequest: retry,
    );
    if (hasPermission.value) {
     fetchSongsFromLocal();
    }
  }

  playerStatesmethod(){
   
    player.playerStateStream.listen((state) {
  if (state.playing) {
    isSongTapped.value = true;
    log("Audio is playing");
  } else if (state.processingState == ProcessingState.completed) {
    log("Audio has finished");
  } else if (state.processingState == ProcessingState.buffering) {
    log("Audio is buffering");
  }
  else{
    isSongTapped.value = false;
    log("player stop in stream player listen");
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
        player.play();
        player.setLoopMode(LoopMode.one);
      } else {
        if (currentPlaySong.value != index) {
          isSongTapped.value = !isSongTapped.value;
          currentPlaySong.value = index;
          player.setAudioSource(AudioSource.uri(Uri.parse(uri!),tag: MediaItem(
        id: data[index].id.toString(),
        album: data[index].album,
        title: data[index].title,
        artUri: Uri.parse(uri),
      ),));
          player.play();
          log("player already played");
          
        } else {
          player.pause();
          
        }
      }

    } on Exception {
      debugPrint("exception occur on playing song");
    }
  }
  
  fetchSongsFromLocal({sortType =SongSortType.DATE_ADDED})async{
    
    try {
      final localSongs = await _audioQuery.querySongs(
        
        sortType: sortType==SongSortType.TITLE? null:sortType,
        orderType: OrderType.DESC_OR_GREATER,
        uriType: UriType.EXTERNAL,
        ignoreCase: false,
      );
      List filterSongs=[].obs;
      for (int i = 0; i < localSongs.length; i++) {
        if (localSongs[i].fileExtension == "mp3" &&
            !isNumeric(localSongs[i].title) &&
            localSongs[i].album != "Standard Recordings") {
            filterSongs.add(localSongs[i]);
        }
      }
      
     data.value = filterSongs;     
     allSongs = filterSongs;
      dataFetched.value = true;
      return;
    } on Exception {
      debugPrint("error on fetching data from local");
    }
     
  }

  sortSongByAlphaDec(type){
    dataFetched.value=false;      
    fetchSongsFromLocal(sortType: type);
  }

  searchSongs(String searchVal){
    if(searchVal==""){
    return  data.value = allSongs;

    }
    RxList d = [].obs;
    for(int i=0;i<allSongs.length;i++){
      if(allSongs[i].title.toLowerCase().contains(searchVal.toLowerCase())){
        d.add(allSongs[i]);
      }
    }
    data.value = d;
    
  }

  void createBottomBannerAd(){
    bottomBannerAd = BannerAd(size: AdSize.banner, adUnitId: AdHelper.getBannerId, listener: BannerAdListener(
        onAdLoaded: (_){
          log("banner ad loaded successfully");
           isBottomBannerAdLoaded.value = true;
        },
        onAdFailedToLoad: (ad,error){
          log("Error loading banner ad");
          bottomBannerAd.dispose();
        }
    ), request:const AdRequest());

    bottomBannerAd.load();
  }
  @override
  void onClose() {
    super.onClose();
    bottomBannerAd.dispose();
  }
}
