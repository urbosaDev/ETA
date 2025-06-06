import 'package:get/get.dart';

class SelectTimeViewModel extends GetxController {
  final RxInt selectedYear = DateTime.now().year.obs;
  final RxInt selectedMonth = DateTime.now().month.obs;
  final RxInt selectedDay = DateTime.now().day.obs;
  final RxInt selectedHour = DateTime.now().hour.obs;
  final RxInt selectedMinute = DateTime.now().minute.obs;

  DateTime get selectedDateTime => DateTime(
    selectedYear.value,
    selectedMonth.value,
    selectedDay.value,
    selectedHour.value,
    selectedMinute.value,
  );

  void setDate(DateTime date) {
    selectedYear.value = date.year;
    selectedMonth.value = date.month;
    selectedDay.value = date.day;
  }

  void setHour(int hour) {
    selectedHour.value = hour;
  }

  void setMinute(int minute) {
    selectedMinute.value = minute;
  }

  void saveTime() {
    Get.back(result: selectedDateTime);
  }
}
