//C:\Users\Jenog\getlery\getlery_client\lib\utils\grouping_algorithm.dart
import 'package:getlery_client/models/group_model.dart';
import 'package:getlery_client/models/image_model.dart';
import 'package:getlery_client/models/image_similarity.dart';

class GroupingAlgorithm {
  final List<ImageModel> images;
  final double similarityThreshold;

  GroupingAlgorithm(this.images, {this.similarityThreshold = 0.7});

  // 1차 시간 기반 그룹 생성 (+-10분 내의 이미지 그룹화)
  List<GroupModel> timeBasedGrouping() {
    images.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    List<GroupModel> timeGroups = [];
    List<ImageModel> currentGroup = [];

    for (var i = 0; i < images.length; i++) {
      if (currentGroup.isEmpty ||
          images[i]
                  .createdAt
                  .difference(currentGroup.last.createdAt)
                  .inMinutes <=
              10) {
        currentGroup.add(images[i]);
      } else {
        if (currentGroup.length > 1) {
          timeGroups.add(GroupModel(
              groupKey: currentGroup.first.createdAt,
              images: List.from(currentGroup)));
        }
        currentGroup = [images[i]];
      }
    }
    if (currentGroup.length > 1) {
      timeGroups.add(GroupModel(
          groupKey: currentGroup.first.createdAt,
          images: List.from(currentGroup)));
    }
    return timeGroups;
  }

  // 2차 유사도 기반 그룹화
  Future<List<GroupModel>> similarityBasedGrouping(
      List<GroupModel> timeGroups) async {
    List<GroupModel> finalGroups = [];
    for (var group in timeGroups) {
      if (group.images.isEmpty) continue;
      List<ImageModel> currentFinalGroup = [group.images.first];
      for (int i = 1; i < group.images.length; i++) {
        double similarity = await ImageSimilarity.comparePixels(
            currentFinalGroup.last.assetEntity, group.images[i].assetEntity);

        if (similarity >= similarityThreshold) {
          currentFinalGroup.add(group.images[i]);
        } else {
          if (currentFinalGroup.length > 1) {
            finalGroups.add(GroupModel(
                groupKey: currentFinalGroup.first.createdAt,
                images: List.from(currentFinalGroup)));
          }
          currentFinalGroup = [group.images[i]];
        }
      }
      if (currentFinalGroup.length > 1) {
        finalGroups.add(GroupModel(
            groupKey: currentFinalGroup.first.createdAt,
            images: List.from(currentFinalGroup)));
      }
    }
    return finalGroups;
  }

  Future<List<GroupModel>> executeGrouping() async {
    List<GroupModel> timeGroups = timeBasedGrouping();
    List<GroupModel> finalGroups = await similarityBasedGrouping(timeGroups);
    return finalGroups;
  }
}
