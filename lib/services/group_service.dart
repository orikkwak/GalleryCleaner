// 파일 위치: lib/services/group_service.dart
import 'dart:convert';
import 'package:getlery_client/models/group_model.dart';
import 'package:getlery_client/models/image_model.dart';
import 'package:getlery_client/models/image_similarity.dart';
import 'package:getlery_client/utils/network_helper.dart';
import 'package:http/http.dart' as http;

class GroupService {
  final NetworkHelper _networkHelper = NetworkHelper();

  // 서버에 그룹 리스트 업데이트
  Future<void> updateGroupsOnServer(List<GroupModel> groups) async {
    if (await _networkHelper.isServerConnected()) {
      try {
        final response = await http.post(
          Uri.parse('${_networkHelper.serverUrl}/groups/update'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(groups.map((group) => group.toJson()).toList()),
        );

        if (response.statusCode != 200) {
          throw Exception('Failed to update groups on the server');
        }
      } catch (e) {
        throw Exception('Error updating groups on server: $e');
      }
    } else {
      throw Exception('No server connection available');
    }
  }

  // 로컬에서 유사도와 시간 차이를 기준으로 그룹 생성
  Future<List<GroupModel>> generateGroups(List<ImageModel> images) async {
    List<GroupModel> groups = [];

    for (var image in images) {
      bool addedToGroup = false;

      for (var group in groups) {
        // 그룹의 대표 이미지와 시간 비교
        final representativeImage = group.representativeImage;
        if (representativeImage == null) continue;

        final timeDiff =
            image.createdAt.difference(representativeImage.createdAt).inMinutes;
        if (timeDiff.abs() <= 5) {
          // 시간 차이 5분 이내
          final similarity = await ImageSimilarity.comparePixels(
              image.assetEntity, representativeImage.assetEntity);

          if (similarity >= 0.7) {
            // 유사도 70% 이상
            group.images.add(image);
            addedToGroup = true;
            break;
          }
        }
      }

      // 기존 그룹에 추가되지 않았다면 새로운 그룹 생성
      if (!addedToGroup) {
        groups.add(GroupModel(
            groupKey: image.createdAt,
            images: [image],
            representativeImage: image));
      }
    }

    return groups;
  }
}
