import 'dart:io';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:getlery/models/group_model.dart';
import 'package:getlery/models/image_model.dart';
import 'package:photo_manager/photo_manager.dart';

class GroupController extends GetxController {
  RxBool isLoading = false.obs;
  final RxList<ImageModel> _images = RxList<ImageModel>([]);
  List<ImageModel> get images => _images.toList();

  final Rx<List<GroupModel>> _minuteGroups = Rx<List<GroupModel>>([]);
  List<GroupModel> get minuteGroups => _minuteGroups.value;

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
      final filterOptionGroup = FilterOptionGroup(
        imageOption: const FilterOption(
          sizeConstraint: SizeConstraint(ignoreSize: true),
        ),
        createTimeCond: DateTimeCond(
          min: startDate.value,
          max: endDate.value,
        ),
      );

      final assetEntities = await PhotoManager.getAssetListRange(
        start: 0,
        end: 1000,
        filterOption: filterOptionGroup,
      ).then((result) => result.cast<AssetEntity>());

      _images.value = await Future.wait(assetEntities.map((assetEntity) async {
        return ImageModel(
          id: assetEntity.id,
          assetEntity: assetEntity,
          createdAt: assetEntity.createDateTime ?? DateTime.now(),
        );
      }));
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch images');
    } finally {
      isLoading.value = false;
    }
  }
}
