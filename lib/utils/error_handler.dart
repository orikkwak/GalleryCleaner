// utils/error_handler.dart
import 'package:get/get.dart';

class ErrorHandler {
  static void showErrorSnackbar(String title, String message) {
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
    Get.snackbar(title, message, snackPosition: SnackPosition.BOTTOM);
  }
}
