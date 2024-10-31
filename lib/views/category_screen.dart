import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getlery_client/controllers/category_controller.dart';
import 'package:getlery_client/models/category_model.dart';
import 'package:getlery_client/services/category_service.dart';
import 'package:getlery_client/views/category_detail_screen.dart';

class CategoryScreen extends StatefulWidget {
  final List<Category> categories;
  const CategoryScreen({super.key, required this.categories});

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  late TextEditingController _nameController;
  late CategoryService categoryService;
  bool isEditing = false;
  Category? editingCategory;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _editCategoryName(Category category) {
    setState(() {
      isEditing = true;
      editingCategory = category;
      _nameController.text = category.name; // 사용자에게 보여지는 이름을 수정
    });
  }

  Future<void> _saveCategoryName() async {
    if (editingCategory != null &&
        _nameController.text != editingCategory!.name) {
      setState(() {
        editingCategory!.updateName(_nameController.text);
        isEditing = false;
        editingCategory = null;
      }); // 서버에 업데이트 요청
      // `CategoryController`를 찾아서 `updateCategoryName` 호출
      final categoryController = Get.find<CategoryController>();
      categoryController.updateCategoryName(
          editingCategory!.id, _nameController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('카테고리 목록'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 두 개의 열
          mainAxisSpacing: 8.0,
          crossAxisSpacing: 8.0,
          childAspectRatio: 1, // 카드가 정사각형에 가까운 비율로 유지
        ),
        itemCount: widget.categories.length,
        itemBuilder: (context, index) {
          final category = widget.categories[index];
          final latestImage =
              category.images.isNotEmpty ? category.images.last : null;

          return GestureDetector(
            onTap: () {
              // 썸네일 클릭 시 카테고리 상세 화면으로 이동
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      CategoryDetailScreen(category: category),
                ),
              );
            },
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  // 이미지 표시
                  if (latestImage != null &&
                      File(latestImage.filePath).existsSync())
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(latestImage.filePath),
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey.shade300,
                      ),
                      child: const Icon(Icons.image, size: 60),
                    ),
                  // 카테고리 이름과 사진 수 표시
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      color: Colors.black.withOpacity(0.5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          isEditing && editingCategory == category
                              ? TextField(
                                  controller: _nameController,
                                  onSubmitted: (_) => _saveCategoryName(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: category.name,
                                    hintStyle:
                                        const TextStyle(color: Colors.white),
                                  ),
                                )
                              : GestureDetector(
                                  onTap: () => _editCategoryName(category),
                                  child: Text(
                                    category.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                          Text(
                            '${category.images.length}장',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // 편집 확인 버튼
                  if (isEditing && editingCategory == category)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: const Icon(Icons.check, color: Colors.white),
                        onPressed: _saveCategoryName,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
