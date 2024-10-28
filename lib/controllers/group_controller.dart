// 파일 위치: lib/controllers/group_controller.dart

import 'package:get/get.dart';
import 'package:getlery_client/models/group_model.dart';
import 'package:getlery_client/models/image_model.dart';
import 'package:getlery_client/services/group_service.dart';
import 'package:getlery_client/services/image_service.dart';
import 'package:getlery_client/utils/network_helper.dart'; // 네트워크 유틸리티 추가

class GroupController extends GetxController {
  final GroupService _groupService = GroupService();
  final ImageService _imageService = ImageService(); // 이미지 서비스 추가
  final NetworkHelper _networkHelper = NetworkHelper(); // NetworkHelper 추가

  RxList<GroupModel> groups = <GroupModel>[].obs;
  RxBool isLoading = false.obs;
  RxBool isSnackbarShown = false.obs; // snackbar 중복 호출 방지

  @override
  void onInit() {
    super.onInit();
    fetchGroups();
  }

  @override
  void onClose() {
    groups.clear(); // 리소스 해제
    super.onClose();
  }

  // 그룹 목록 가져오기
  Future<void> fetchGroups() async {
    isLoading.value = true;
    try {
      // 로컬 이미지 불러오기
      List<ImageModel> localImages =
          await _imageService.fetchLocalImages(0); // 첫 번째 페이지만 예시로 가져옴

      // 로컬에서 그룹화 수행
      groups.value = await _groupService.generateGroups(localImages);

      // 서버에 연결되어 있는 경우에만 그룹을 서버에 저장 및 업데이트
      if (await _networkHelper.isServerConnected()) {
        // NetworkHelper 통해 연결 확인
        await _groupService.updateGroupsOnServer(groups);
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
