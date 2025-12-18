import 'package:dartz/dartz.dart';
import 'package:fit_progressor/features/cars/data/datasources/car_local_data_source.dart';
import 'package:fit_progressor/features/cars/data/repositories/car_repository_impl.dart';
import 'package:fit_progressor/features/repairs/domain/entities/repair.dart';
import 'package:fit_progressor/features/repairs/domain/repositories/repair_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'car_repository_cascade_delete_test.mocks.dart';

@GenerateMocks([
  CarLocalDataSource,
  RepairRepository,
])
void main() {
  late CarRepositoryImpl repository;
  late MockCarLocalDataSource mockLocalDataSource;
  late MockRepairRepository mockRepairRepository;

  setUp(() {
    mockLocalDataSource = MockCarLocalDataSource();
    mockRepairRepository = MockRepairRepository();
    repository = CarRepositoryImpl(
      localDataSource: mockLocalDataSource,
      repairRepository: mockRepairRepository,
    );
  });

  group('Car Cascade Delete Tests', () {
    const testCarId = 'car-1';

    final testRepairs = [
      Repair(
        id: 'repair-1',
        carId: testCarId,
        name: 'Oil Change',
        description: 'Regular oil change',
        date: DateTime.now(),
        cost: 50.0,
      ),
      Repair(
        id: 'repair-2',
        carId: testCarId,
        name: 'Brake Repair',
        description: 'Replace brake pads',
        date: DateTime.now(),
        cost: 150.0,
      ),
    ];

    test('should cascade delete all repairs when deleting a car', () async {
      // Arrange
      when(mockRepairRepository.getRepairs(carId: testCarId))
          .thenAnswer((_) async => Right(testRepairs));

      when(mockRepairRepository.deleteRepair(any))
          .thenAnswer((_) async => const Right(null));

      when(mockLocalDataSource.deleteCar(testCarId))
          .thenAnswer((_) async => Future.value());

      // Act
      final result = await repository.deleteCar(testCarId);

      // Assert
      expect(result, equals(const Right(null)));

      // Verify all repairs were deleted
      verify(mockRepairRepository.deleteRepair('repair-1')).called(1);
      verify(mockRepairRepository.deleteRepair('repair-2')).called(1);

      // Verify car was deleted
      verify(mockLocalDataSource.deleteCar(testCarId)).called(1);

      // Verify order: repairs deleted first, then car
      verifyInOrder([
        mockRepairRepository.getRepairs(carId: testCarId),
        mockRepairRepository.deleteRepair('repair-1'),
        mockRepairRepository.deleteRepair('repair-2'),
        mockLocalDataSource.deleteCar(testCarId),
      ]);
    });

    test('should still delete car even if no repairs exist', () async {
      // Arrange
      when(mockRepairRepository.getRepairs(carId: testCarId))
          .thenAnswer((_) async => const Right([]));

      when(mockLocalDataSource.deleteCar(testCarId))
          .thenAnswer((_) async => Future.value());

      // Act
      final result = await repository.deleteCar(testCarId);

      // Assert
      expect(result, equals(const Right(null)));

      // Verify car was deleted even with no repairs
      verify(mockLocalDataSource.deleteCar(testCarId)).called(1);

      // Verify no repair deletions were attempted
      verifyNever(mockRepairRepository.deleteRepair(any));
    });
  });
}
