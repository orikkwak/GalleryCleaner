// 파일 위치: lib/controllers/group_controller.dart

import 'package:get/get.dart';
import 'package:getlery_client/models/group_model.dart';
import 'package:getlery_client/models/image_model.dart';
import 'package:getlery_client/services/group_service.dart';
import 'package:getlery_client/services/image_service.dart';
import 'package:getlery_client/services/nima_score_service.dart';
import 'package:getlery_client/utils/network_helper.dart'; // 네트워크 유틸리티 추가

class GroupController extends GetxController {
  final GroupService _groupService = GroupService();
  final ImageService _imageService = ImageService(); // 이미지 서비스 추가
  final NimaScoreService _nimaScoreService = NimaScoreService();
  final NetworkHelper _networkHelper = NetworkHelper(); // NetworkHelper 추가

  RxList<GroupModel> groups = <GroupModel>[].obs;
  RxBool isLoading = false.obs;
  RxBool isSnackbarShown = false.obs; // snackbar 중복 호출 방지

  @override
  void onInit() {
    super.onInit();
    fetchGroups(); // 초기 로딩 시 그룹을 가져옴
  }

  Future<void> fetchGroups() async {
    isLoading.value = true;
    try {
      List<ImageModel> localImages = await _imageService.fetchLocalImages(0);
      groups.value = await _groupService.generateGroups(localImages);

      if (await _networkHelper.isServerConnected()) {
        await _nimaScoreService.updateNimaScores(localImages);
        for (var group in groups) {
          group.selectRepresentativeByNima();
        }
      } else {
        for (var group in groups) {
          group.selectRepresentativeByPixels();
        }
      }
    } catch (e) {
      if (!isSnackbarShown.value) {
        isSnackbarShown.value = true;
        Get.snackbar('Error', 'Failed to fetch groups: $e');
        Future.delayed(const Duration(seconds: 3), () {
          isSnackbarShown.value = false;
        });
      }
    } finally {
      isLoading.value = false;
    }
  }

  // 그룹 정렬 기능
  void sortGroups(bool newestFirst) {
    groups.sort((a, b) => newestFirst
        ? b.groupKey.compareTo(a.groupKey)
        : a.groupKey.compareTo(b.groupKey));
    groups.refresh();
  }
}
