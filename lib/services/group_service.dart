// 파일 위치: lib/services/group_service.dart
import 'package:getlery_client/models/group_model.dart';
import 'package:getlery_client/models/image_model.dart';
import 'package:getlery_client/utils/grouping_algorithm.dart';

class GroupService {
  // 로컬에서 이미지 그룹화 생성
  Future<List<GroupModel>> generateGroups(List<ImageModel> images) async {
    final groupingAlgorithm = GroupingAlgorithm(images);
    return await groupingAlgorithm.executeGrouping();
  }
}
