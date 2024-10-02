// lib/controllers/photo_controller.dart

import 'package:get/get.dart';
import '../models/photo_model.dart';
import '../services/photo_service.dart';

class PhotoController extends GetxController {
  var photos = <Photo>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    fetchPhotos();
    super.onInit();
  }

  void fetchPhotos() async {
    isLoading(true);
    try {
      photos.value = await PhotoService.fetchPhotos();
    } finally {
      isLoading(false);
    }
  }
}
