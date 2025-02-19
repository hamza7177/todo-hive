import 'package:get/get.dart';

class VoiceNoteController extends GetxController{
  var selectedFilter = "All".obs;

  void setFilter(String filter) {
    selectedFilter.value = filter;
    update();
  }
}