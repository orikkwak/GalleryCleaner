// lib/services/category_service.dart
import 'package:get/get.dart';
import 'package:getlery_client/models/category_model.dart';
import 'package:getlery_client/utils/network_helper.dart';

class CategoryService extends GetConnect {
  final networkHelper = NetworkHelper();

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

  Future<void> updateCategoryName(String id, String newName) async {
    await put('${networkHelper.categoryApiUrl}/$id', {'name': newName});
  }
}
