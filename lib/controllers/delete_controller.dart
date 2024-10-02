// lib/controllers/delete_controller.dart
import 'package:get/get.dart';

class DeleteController extends GetxController {
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _getData();
  }

  void onRefresh() {
    _getData();
  }

  Future<void> _getData() async {
    isLoading(true);
    // 데이터 로딩 로직
    isLoading(false);
  }
}
