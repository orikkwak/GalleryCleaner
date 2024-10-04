// getlery/lib/routes/app_routes.dart
import 'package:get/get.dart';
import 'package:getlery/views/photo_view.dart';
import 'package:getlery/controllers/image_controller.dart';

final List<GetPage> appRoutes = [
  GetPage(
    name: '/photo',
    page: () => const PhotoViewScreen(),
    binding: BindingsBuilder(() {
      Get.lazyPut(() => ImageController());
    }),
  ),
];
