import 'package:dartz/dartz.dart';
import 'package:fit_progressor/features/cars/domain/entities/car.dart';
import 'package:fit_progressor/features/cars/domain/repositories/car_repository.dart';
import 'package:fit_progressor/features/clients/data/datasources/client_local_data_source.dart';
import 'package:fit_progressor/features/clients/data/repositories/client_repository_impl.dart';
import 'package:fit_progressor/features/clients/domain/entities/client.dart';
import 'package:fit_progressor/features/repairs/domain/entities/repair.dart';
import 'package:fit_progressor/features/repairs/domain/repositories/repair_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'client_repository_cascade_delete_test.mocks.dart';

@GenerateMocks([
  ClientLocalDataSource,
  CarRepository,
  RepairRepository,
])
void main() {
  late ClientRepositoryImpl repository;
  late MockClientLocalDataSource mockLocalDataSource;
  late MockCarRepository mockCarRepository;
  late MockRepairRepository mockRepairRepository;

  setUp(() {
    mockLocalDataSource = MockClientLocalDataSource();
    mockCarRepository = MockCarRepository();
    mockRepairRepository = MockRepairRepository();
    repository = ClientRepositoryImpl(
      localDataSource: mockLocalDataSource,
      carRepository: mockCarRepository,
      repairRepository: mockRepairRepository,
    );
  });

  group('Cascade Delete Tests', () {
    const testClientId = 'client-1';
    final testClient = Client(
      id: testClientId,
      name: 'Test Client',
      phone: '+1234567890',
    );

    final testCars = [
      Car(
        id: 'car-1',
        clientId: testClientId,
        make: 'Toyota',
        model: 'Camry',
        plate: 'ABC123',
      ),
      Car(
        id: 'car-2',
        clientId: testClientId,
        make: 'Honda',
        model: 'Civic',
        plate: 'XYZ789',
      ),
    ];

    final testRepairsCar1 = [
      Repair(
        id: 'repair-1',
        carId: 'car-1',
        name: 'Oil Change',
        description: 'Regular oil change',
        date: DateTime.now(),
        cost: 50.0,
      ),
      Repair(
        id: 'repair-2',
        carId: 'car-1',
        name: 'Brake Repair',
        description: 'Replace brake pads',
        date: DateTime.now(),
        cost: 150.0,
      ),
    ];

    final testRepairsCar2 = [
      Repair(
        id: 'repair-3',
        carId: 'car-2',
        name: 'Engine Check',
        description: 'Diagnostic check',
        date: DateTime.now(),
        cost: 100.0,
      ),
    ];

    test('should cascade delete all cars and repairs when deleting a client',
        () async {
      // Arrange
      when(mockCarRepository.getCarsByClient(testClientId))
          .thenAnswer((_) async => Right(testCars));

      when(mockRepairRepository.getRepairs(carId: 'car-1'))
          .thenAnswer((_) async => Right(testRepairsCar1));

      when(mockRepairRepository.getRepairs(carId: 'car-2'))
          .thenAnswer((_) async => Right(testRepairsCar2));

      when(mockRepairRepository.deleteRepair(any))
          .thenAnswer((_) async => const Right(null));

      when(mockCarRepository.deleteCar(any))
          .thenAnswer((_) async => const Right(null));

      when(mockLocalDataSource.deleteClient(testClientId))
          .thenAnswer((_) async => Future.value());

      // Act
      final result = await repository.deleteClient(testClientId);

      // Assert
      expect(result, equals(const Right(null)));

      // Verify all repairs for car-1 were deleted
      verify(mockRepairRepository.deleteRepair('repair-1')).called(1);
      verify(mockRepairRepository.deleteRepair('repair-2')).called(1);

      // Verify all repairs for car-2 were deleted
      verify(mockRepairRepository.deleteRepair('repair-3')).called(1);

      // Verify all cars were deleted
      verify(mockCarRepository.deleteCar('car-1')).called(1);
      verify(mockCarRepository.deleteCar('car-2')).called(1);

      // Verify client was deleted
      verify(mockLocalDataSource.deleteClient(testClientId)).called(1);

      // Verify order: repairs deleted first, then cars, then client
      verifyInOrder([
        mockCarRepository.getCarsByClient(testClientId),
        mockRepairRepository.getRepairs(carId: 'car-1'),
        mockRepairRepository.deleteRepair('repair-1'),
        mockRepairRepository.deleteRepair('repair-2'),
        mockCarRepository.deleteCar('car-1'),
        mockRepairRepository.getRepairs(carId: 'car-2'),
        mockRepairRepository.deleteRepair('repair-3'),
        mockCarRepository.deleteCar('car-2'),
        mockLocalDataSource.deleteClient(testClientId),
      ]);
    });

    test('should still delete client even if no cars exist', () async {
      // Arrange
      when(mockCarRepository.getCarsByClient(testClientId))
          .thenAnswer((_) async => const Right([]));

      when(mockLocalDataSource.deleteClient(testClientId))
          .thenAnswer((_) async => Future.value());

      // Act
      final result = await repository.deleteClient(testClientId);

      // Assert
      expect(result, equals(const Right(null)));

      // Verify client was deleted even with no cars
      verify(mockLocalDataSource.deleteClient(testClientId)).called(1);

      // Verify no car or repair deletions were attempted
      verifyNever(mockCarRepository.deleteCar(any));
      verifyNever(mockRepairRepository.deleteRepair(any));
    });

    test('should still delete client and cars even if no repairs exist',
        () async {
      // Arrange
      when(mockCarRepository.getCarsByClient(testClientId))
          .thenAnswer((_) async => Right(testCars));

      when(mockRepairRepository.getRepairs(carId: 'car-1'))
          .thenAnswer((_) async => const Right([]));

      when(mockRepairRepository.getRepairs(carId: 'car-2'))
          .thenAnswer((_) async => const Right([]));

      when(mockCarRepository.deleteCar(any))
          .thenAnswer((_) async => const Right(null));

      when(mockLocalDataSource.deleteClient(testClientId))
          .thenAnswer((_) async => Future.value());

      // Act
      final result = await repository.deleteClient(testClientId);

      // Assert
      expect(result, equals(const Right(null)));

      // Verify cars were deleted
      verify(mockCarRepository.deleteCar('car-1')).called(1);
      verify(mockCarRepository.deleteCar('car-2')).called(1);

      // Verify client was deleted
      verify(mockLocalDataSource.deleteClient(testClientId)).called(1);

      // Verify no repair deletions were attempted
      verifyNever(mockRepairRepository.deleteRepair(any));
    });
  });
}
