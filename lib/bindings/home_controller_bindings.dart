import 'package:get/get.dart';
import 'package:music_player_personal/controllers/home_page_controller.dart';

class HomeControllerBindings extends Bindings{
  @override
  void dependencies() {
    
    Get.put(HomePageController());
  }

}