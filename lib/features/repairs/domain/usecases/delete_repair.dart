import 'package:dartz/dartz.dart';
import 'package:fit_progressor/core/error/failures/failure.dart';
import 'package:fit_progressor/core/usecases/usecase.dart';
import '../repositories/repair_repository.dart';
import '../../data/services/repair_image_service.dart';
import 'get_repair_by_id.dart';

class DeleteRepair implements UseCase<void, String> {
  final RepairRepository repairRepository;
  final GetRepairById getRepairById;
  final RepairImageService imageService;

  DeleteRepair({
    required this.repairRepository,
    required this.getRepairById,
    required this.imageService,
  });

  @override
  Future<Either<Failure, void>> call(String repairId) async {
    // 1. Получить repair для доступа к photoPaths
    final repairResult = await getRepairById(repairId);

    // 2. Удалить изображения если repair найден
    await repairResult.fold(
      (failure) async {
        // Если не удалось получить repair, продолжаем удаление
      },
      (repair) async {
        // Удаляем все фото ремонта
        await imageService.deleteImages(repair.photoPaths);
      },
    );

    // 3. Удалить запись из БД
    return await repairRepository.deleteRepair(repairId);
  }
}
