import 'package:get/get.dart';
import 'package:getlery/models/group_model.dart';
import 'package:getlery/models/image_model.dart';
import 'package:getlery/services/nima_score_service.dart';
import 'package:getlery/repositories/image_repository.dart';

class GroupController extends GetxController {
  final ImageRepository imageRepository = ImageRepository();
  final NimaScoreService nimaScoreService = NimaScoreService();

  RxBool isLoading = false.obs;
  final RxList<ImageModel> _images = RxList<ImageModel>([]);
  List<ImageModel> get images => _images.toList();

  final Rx<List<GroupModel>> _minuteGroups = Rx<List<GroupModel>>([]);
  List<GroupModel> get minuteGroups => _minuteGroups.value;

  // 날짜 필터
  Rx<DateTime> startDate =
      (DateTime.now().subtract(const Duration(days: 10))).obs;
  Rx<DateTime> endDate = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    fetchImages();
  }

  Future<void> fetchImages() async {
    isLoading.value = true;
    try {
      // 서버에서 이미지 불러오기
      _images.value = await imageRepository.fetchImagesFromServer(
          startDate.value as int, endDate.value);

      // 캐시된 NIMA 점수 적용
      await nimaScoreService.applyCachedNimaScores(_images);

      // 그룹별 대표 이미지 업데이트
      _updateMinuteGroups();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch images');
    } finally {
      isLoading.value = false;
    }
  }

  // 그룹별 대표 이미지 업데이트
  Future<void> _updateMinuteGroups() async {
    _minuteGroups.value = _groupByMinute(_images);

    // NIMA 점수 업데이트 후 대표 이미지 선정
    await nimaScoreService.updateNimaScores(
        _minuteGroups.value.expand((group) => group.images).toList());

    for (var group in _minuteGroups.value) {
      group.representativeImage = _selectRepresentativeImage(group.images);
    }

    _minuteGroups.refresh();
  }

  // 그룹화: 1분 단위로 그룹을 묶음
  List<GroupModel> _groupByMinute(List<ImageModel> images) {
    final Map<DateTime, List<ImageModel>> groupedImages = {};

    for (var image in images) {
      final DateTime minute = DateTime(
          image.createdAt.year,
          image.createdAt.month,
          image.createdAt.day,
          image.createdAt.hour,
          image.createdAt.minute);
      if (!groupedImages.containsKey(minute)) {
        groupedImages[minute] = [];
      }
      groupedImages[minute]!.add(image);
    }

    return groupedImages.entries.map((entry) {
      return GroupModel(
        groupKey: entry.key,
        images: entry.value,
      );
    }).toList();
  }

  // NIMA 점수를 기준으로 대표 이미지 선택
  ImageModel _selectRepresentativeImage(List<ImageModel> images) {
    images.sort((a, b) => b.nimaScore!.compareTo(a.nimaScore!));
    return images.first;
  }

  // 그룹 정렬 기능
  void sortGroups(bool newestFirst) {
    _minuteGroups.value.sort((a, b) {
      if (newestFirst) {
        return b.groupKey.compareTo(a.groupKey);
      } else {
        return a.groupKey.compareTo(b.groupKey);
      }
    });
    _minuteGroups.refresh();
  }
}
