import 'dart:io';
import 'package:path_provider/path_provider.dart';

class RepairImageService {
  Future<String> saveImage(String sourcePath, String repairId) async {
    try {
      // 1. Получить documents directory
      final docsDir = await getApplicationDocumentsDirectory();

      // 2. Создать папку для ремонта
      final repairDir = Directory('${docsDir.path}/repairs/$repairId');
      await repairDir.create(recursive: true);

      // 3. Сгенерировать имя файла
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = sourcePath.split('.').last;
      final fileName = 'photo_$timestamp.$extension';

      // 4. Скопировать файл
      final sourceFile = File(sourcePath);
      final targetPath = '${repairDir.path}/$fileName';
      await sourceFile.copy(targetPath);

      return targetPath;
    } catch (e) {
      throw Exception('Ошибка сохранения изображения: $e');
    }
  }

  Future<void> deleteImages(List<String> photoPaths) async {
    for (final path in photoPaths) {
      try {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        // Игнорировать ошибки удаления отдельных файлов
      }
    }
  }

  Future<void> deleteImage(String photoPath) async {
    try {
      final file = File(photoPath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Игнорировать ошибки удаления
    }
  }
}
