// 파일 위치: lib/controllers/group_controller.dart

import 'package:get/get.dart';
import 'package:getlery_client/models/group_model.dart';
import 'package:getlery_client/services/group_service.dart';

class GroupController extends GetxController {
  final GroupService _groupService = GroupService();

  RxList<GroupModel> groups = <GroupModel>[].obs;
  RxBool isLoading = false.obs;
  Rx<DateTime> startDate =
      DateTime.now().subtract(const Duration(days: 10)).obs;
  Rx<DateTime> endDate = DateTime.now().obs;

  // 선택된 그룹화 방식
  RxString groupType = 'date'.obs;
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

  // 서버 연결 여부에 따라 그룹화 방식 결정
  Future<void> fetchGroups() async {
    isLoading.value = true;
    try {
      if (await _groupService.isServerConnected()) {
        groups.value = await _groupService.fetchGroupsBySimilarity();
      } else {
        groups.value = await _groupService.fetchGroupsByDate(
            startDate.value, endDate.value);
      }
    } catch (e) {
      // 중복된 snackbar 호출 방지
      if (!isSnackbarShown.value) {
        isSnackbarShown.value = true;
        isSnackbarShown.value = true;
        Get.snackbar('Error', 'Failed to fetch groups: $e');

        // 일정 시간 후에 플래그를 초기화
        Future.delayed(const Duration(seconds: 3), () {
          isSnackbarShown.value = false;
        });
      }
    } finally {
      isLoading.value = false;
    }
  }

  // 그룹화 방식 변경
  void changeGroupType(String type) {
    groupType.value = type;
    fetchGroups(); // 그룹화 방식에 따라 그룹 목록 새로 불러오기
  }

  // 그룹 정렬 기능
  void sortGroups(bool newestFirst) {
    groups.sort((a, b) => newestFirst
        ? b.groupKey.compareTo(a.groupKey)
        : a.groupKey.compareTo(b.groupKey));
    groups.refresh();
  }

  // 날짜 필터 설정
  void setDateRange(DateTime start, DateTime end) {
    startDate.value = start;
    endDate.value = end;
    fetchGroups(); // 날짜 필터 변경 시 그룹 목록 갱신
  }
}
