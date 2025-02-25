import 'package:get/get.dart';

class ScheduleController extends GetxController{
  var selectedFilter = "All".obs;
  void setFilter(String filter) {
    selectedFilter.value = filter;
    update();
  }
}