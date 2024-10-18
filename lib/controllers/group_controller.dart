// 파일 위치: lib/controllers/group_controller.dart

import 'package:get/get.dart';
import 'package:getlery/models/group_model.dart';
import 'package:getlery/services/group_service.dart';

class GroupController extends GetxController {
  final GroupService _groupService = GroupService();

  RxList<GroupModel> groups = <GroupModel>[].obs;
  RxBool isLoading = false.obs;
  Rx<DateTime> startDate =
      DateTime.now().subtract(const Duration(days: 10)).obs;
  Rx<DateTime> endDate = DateTime.now().obs;

  // 선택된 그룹화 방식
  RxString groupType = 'date'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchGroups();
  }

  @override
  void onClose() {
    // 리소스 해제 (리스트 정리)
    groups.clear(); // 그룹 리스트 해제
    super.onClose();
  }

  // 서버 연결 여부에 따라 그룹화 방식 결정
  Future<void> fetchGroups() async {
    isLoading.value = true;
    try {
      if (await _groupService.isServerConnected()) {
        // 서버 연결된 경우: 유사도 기반 그룹화
        groups.value = await _groupService.fetchGroupsBySimilarity();
      } else {
        // 서버 연결 실패: 연속촬영 그룹화
        groups.value = await _groupService.fetchGroupsByDate(
            startDate.value, endDate.value);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch groups: $e');
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
    groups.sort((a, b) {
      if (newestFirst) {
        return b.groupKey.compareTo(a.groupKey);
      } else {
        return a.groupKey.compareTo(b.groupKey);
      }
    });
    groups.refresh();
  }

  // 날짜 필터 설정
  void setDateRange(DateTime start, DateTime end) {
    startDate.value = start;
    endDate.value = end;
    fetchGroups(); // 날짜 필터 변경 시 그룹 목록 갱신
  }
}
