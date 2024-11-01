import 'package:getlery_client/models/group_model.dart';
import 'package:getlery_client/models/image_model.dart';
import 'package:getlery_client/utils/grouping_algorithm.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:getlery_client/repositories/group_repository.dart'; // 그룹 리포지토리 추가

class GroupService {
  final GroupRepository _repository = GroupRepository();

  // 로컬에서 이미지 그룹화 생성
  Future<List<GroupModel>> generateGroups(List<ImageModel> images) async {
    final groupingAlgorithm = GroupingAlgorithm(images);
    return await groupingAlgorithm.executeGrouping();
  }

  // 그룹을 캐시에 저장
  Future<void> saveGroupsToCache(List<GroupModel> groups) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> groupsJson =
        groups.map((group) => group.toJson()).toList();
    await prefs.setString('cached_groups', jsonEncode(groupsJson));
  }

  // 캐시에서 그룹 불러오기
  Future<List<GroupModel>> loadGroupsFromCache() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cachedData = prefs.getString('cached_groups');
    if (cachedData == null) return [];
    List<dynamic> cachedGroupsJson = jsonDecode(cachedData);
    return cachedGroupsJson.map((json) => GroupModel.fromJson(json)).toList();
  }

  // 서버와 그룹 동기화
  Future<void> syncGroupsWithServer(List<GroupModel> groups) async {
    for (var group in groups) {
      if (!(await _repository.isGroupExistsOnServer(group.uniqueID))) {
        await _repository.uploadGroupToServer(group);
      }
    }
  }
}
