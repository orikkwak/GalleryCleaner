// 파일 위치: lib/services/category_service.dart

import 'package:get/get.dart';
import 'package:getlery_client/models/category_model.dart';
import 'package:getlery_client/utils/network_helper.dart';

class CategoryService extends GetConnect {
  final networkHelper = NetworkHelper();

  // 서버에서 카테고리 목록 가져오기
  Future<List<Category>> fetchCategories() async {
    final response = await get('${networkHelper.categoryApiUrl}/all');
    if (response.status.hasError) {
      return Future.error(response.statusText!);
    } else {
      return (response.body as List)
          .map((json) => Category.fromJson(json))
          .toList();
    }
  }

  // 카테고리 이름 업데이트
  Future<void> updateCategoryName(String id, String newName) async {
    await networkHelper.putRequest(
      '${networkHelper.categoryApiUrl}/$id',
      {'name': newName}, // name 필드를 업데이트
    );
  }

  // 카테고리에 이미지 추가
  Future<void> addImageToCategory(String categoryId, String imageUrl) async {
    await networkHelper.postRequest(
      '${networkHelper.categoryApiUrl}/$categoryId/add-image',
      {'imageUrl': imageUrl},
    );
  }
}
