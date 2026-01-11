import 'dart:io';
import 'dart:isolate';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class RepairImageService {
  /// Максимальная ширина изображения после сжатия
  static const int maxWidth = 1920;
  /// Максимальная высота изображения после сжатия
  static const int maxHeight = 1920;
  /// Качество JPEG сжатия (0-100)
  static const int jpegQuality = 85;

  Future<String> saveImage(String sourcePath, String repairId) async {
    try {
      // 1. Получить documents directory
      final docsDir = await getApplicationDocumentsDirectory();

      // 2. Создать папку для ремонта
      final repairDir = Directory('${docsDir.path}/repairs/$repairId');
      await repairDir.create(recursive: true);

      // 3. Сгенерировать имя файла (всегда сохраняем как jpg после сжатия)
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'photo_$timestamp.jpg';
      final targetPath = '${repairDir.path}/$fileName';

      // 4. Сжать и сохранить изображение
      await _compressAndSaveImage(sourcePath, targetPath);

      return targetPath;
    } catch (e) {
      throw Exception('Ошибка сохранения изображения: $e');
    }
  }

  /// Сжимает изображение и сохраняет в указанный путь.
  /// Выполняется в отдельном изоляте для избежания блокировки UI.
  Future<void> _compressAndSaveImage(String sourcePath, String targetPath) async {
    await Isolate.run(() {
      // Читаем исходное изображение
      final sourceFile = File(sourcePath);
      final bytes = sourceFile.readAsBytesSync();
      final image = img.decodeImage(bytes);

      if (image == null) {
        // Если не удалось декодировать, просто копируем файл
        sourceFile.copySync(targetPath);
        return;
      }

      // Вычисляем новые размеры с сохранением пропорций
      img.Image resizedImage;
      if (image.width > maxWidth || image.height > maxHeight) {
        // Определяем соотношение для масштабирования
        final widthRatio = maxWidth / image.width;
        final heightRatio = maxHeight / image.height;
        final ratio = widthRatio < heightRatio ? widthRatio : heightRatio;

        final newWidth = (image.width * ratio).round();
        final newHeight = (image.height * ratio).round();

        resizedImage = img.copyResize(
          image,
          width: newWidth,
          height: newHeight,
          interpolation: img.Interpolation.linear,
        );
      } else {
        resizedImage = image;
      }

      // Сохраняем как JPEG с заданным качеством
      final compressedBytes = img.encodeJpg(resizedImage, quality: jpegQuality);
      File(targetPath).writeAsBytesSync(compressedBytes);
    });
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
