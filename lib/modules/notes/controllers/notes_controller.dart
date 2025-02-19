import 'package:get/get.dart';

class NotesController extends GetxController{
  var selectedFilter = "All".obs;

  void setFilter(String filter) {
    selectedFilter.value = filter;
    update();
  }

}