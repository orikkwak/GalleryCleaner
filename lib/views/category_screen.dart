import 'dart:io';
import 'package:flutter/material.dart';
import 'package:getlery_client/models/category_model.dart';
import 'package:getlery_client/views/category_detail_screen.dart';

class CategoryScreen extends StatefulWidget {
  final List<Category> categories; // 여러 카테고리를 받도록 수정
  const CategoryScreen({super.key, required this.categories});

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  late TextEditingController _nameController;
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
      _nameController.text = category.name;
    });
  }

  Future<void> _saveCategoryName() async {
    if (editingCategory != null &&
        _nameController.text != editingCategory!.name) {
      setState(() {
        editingCategory!.updateName(_nameController.text);
        isEditing = false;
        editingCategory = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('카테고리 목록'),
      ),
      body: ListView.builder(
        itemCount: widget.categories.length,
        itemBuilder: (context, index) {
          final category = widget.categories[index];
          final latestImage =
              category.images.isNotEmpty ? category.images.last : null;

          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: GestureDetector(
                onTap: () {
                  // 썸네일을 클릭하면 카테고리 상세 화면으로 이동
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          CategoryDetailScreen(category: category),
                    ),
                  );
                },
                child: latestImage != null &&
                        File(latestImage.filePath).existsSync()
                    ? Image.file(
                        File(latestImage.filePath),
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      )
                    : const Icon(Icons.image, size: 60),
              ),
              title: isEditing && editingCategory == category
                  ? TextField(
                      controller: _nameController,
                      onSubmitted: (_) => _saveCategoryName(),
                      decoration: const InputDecoration(hintText: '카테고리 이름'),
                    )
                  : GestureDetector(
                      onTap: () => _editCategoryName(category),
                      child: Text(
                        category.name,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
              trailing: isEditing && editingCategory == category
                  ? IconButton(
                      icon: const Icon(Icons.check),
                      onPressed: _saveCategoryName,
                    )
                  : IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _editCategoryName(category),
                    ),
            ),
          );
        },
      ),
    );
  }
}
