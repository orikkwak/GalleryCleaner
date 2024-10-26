// getlery/lib/common/translations_info.dart
import 'package:get/get.dart';

class TranslationsInfo extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': enUS,
        'ko': ko,
      };

  final Map<String, String> enUS = {
    'err.title.info': 'Info',
    'err.title.error': 'Error',
    'err.try': 'Please try again',
    'btn.close': 'Close',
    'title': 'Gallery Cleaner',
    'album.title': 'Album',
    'photo.title': 'Photo',
    'delete.title': 'Delete',
  };

  final Map<String, String> ko = {
    'err.title.info': '안내',
    'err.title.error': '오류',
    'err.try': '다시 시도해 주세요',
    'btn.close': '닫기',
    'title': '갤러리 클리너',
    'album.title': '앨범',
    'photo.title': '사진',
    'delete.title': '삭제',
  };
}
