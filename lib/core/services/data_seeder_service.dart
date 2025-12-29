import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import 'package:fit_progressor/features/clients/domain/entities/client.dart';
import 'package:fit_progressor/features/clients/domain/repositories/client_repository.dart';
import 'package:fit_progressor/features/cars/domain/entities/car.dart';
import 'package:fit_progressor/features/cars/domain/repositories/car_repository.dart';
import 'package:fit_progressor/features/repairs/domain/entities/repair.dart';
import 'package:fit_progressor/features/repairs/domain/entities/repair_status.dart';
import 'package:fit_progressor/features/repairs/domain/entities/part_types.dart';
import 'package:fit_progressor/features/repairs/domain/repositories/repair_repository.dart';
import 'package:fit_progressor/features/materials/domain/entities/material.dart';
import 'package:fit_progressor/features/materials/domain/repositories/material_repository.dart';

/// Сервис для заполнения базы тестовыми данными
/// Доступен только в debug режиме
class DataSeederService {
  final ClientRepository _clientRepository;
  final CarRepository _carRepository;
  final RepairRepository _repairRepository;
  final MaterialRepository _materialRepository;

  final _uuid = const Uuid();
  final _random = Random();

  DataSeederService({
    required ClientRepository clientRepository,
    required CarRepository carRepository,
    required RepairRepository repairRepository,
    required MaterialRepository materialRepository,
  })  : _clientRepository = clientRepository,
        _carRepository = carRepository,
        _repairRepository = repairRepository,
        _materialRepository = materialRepository;

  /// Проверка доступности сидера (только debug)
  bool get isAvailable => kDebugMode;

  /// Заполнить базу тестовыми данными
  Future<SeederResult> seedAll() async {
    if (!isAvailable) {
      return SeederResult(
        success: false,
        message: 'Сидер доступен только в debug режиме',
      );
    }

    try {
      int clientsCreated = 0;
      int carsCreated = 0;
      int repairsCreated = 0;
      int materialsCreated = 0;

      // 1. Создаём материалы
      final materials = await _seedMaterials();
      materialsCreated = materials.length;

      // 2. Создаём клиентов
      final clients = await _seedClients();
      clientsCreated = clients.length;

      // 3. Создаём автомобили для клиентов
      final cars = await _seedCars(clients);
      carsCreated = cars.length;

      // 4. Создаём ремонты для автомобилей
      final repairs = await _seedRepairs(cars);
      repairsCreated = repairs.length;

      return SeederResult(
        success: true,
        message: 'Создано: $clientsCreated клиентов, $carsCreated авто, '
            '$repairsCreated ремонтов, $materialsCreated материалов',
        clientsCreated: clientsCreated,
        carsCreated: carsCreated,
        repairsCreated: repairsCreated,
        materialsCreated: materialsCreated,
      );
    } catch (e) {
      return SeederResult(
        success: false,
        message: 'Ошибка: $e',
      );
    }
  }

  // ============== Клиенты ==============

  Future<List<Client>> _seedClients() async {
    final clients = <Client>[];

    for (final data in _clientsData) {
      final client = Client(
        id: _uuid.v4(),
        name: data['name']!,
        phone: data['phone']!,
        createdAt: _randomPastDate(days: 365),
      );

      final result = await _clientRepository.addClient(client);
      result.fold(
        (failure) => debugPrint('Ошибка создания клиента: $failure'),
        (created) => clients.add(created),
      );
    }

    return clients;
  }

  // ============== Автомобили ==============

  Future<List<Car>> _seedCars(List<Client> clients) async {
    final cars = <Car>[];

    for (final client in clients) {
      // 1-3 автомобиля на клиента
      final carCount = _random.nextInt(3) + 1;

      for (var i = 0; i < carCount; i++) {
        final carData = _carsData[_random.nextInt(_carsData.length)];

        final car = Car(
          id: _uuid.v4(),
          clientId: client.id,
          make: carData['make']!,
          model: carData['model']!,
          plate: _generatePlate(),
          clientName: client.name,
          createdAt: _randomPastDate(days: 300),
        );

        final result = await _carRepository.addCar(car);
        result.fold(
          (failure) => debugPrint('Ошибка создания авто: $failure'),
          (created) => cars.add(created),
        );
      }
    }

    return cars;
  }

  // ============== Ремонты ==============

  Future<List<Repair>> _seedRepairs(List<Car> cars) async {
    final repairs = <Repair>[];

    for (final car in cars) {
      // 0-5 ремонтов на автомобиль
      final repairCount = _random.nextInt(6);

      for (var i = 0; i < repairCount; i++) {
        final partType = PartTypes.all[_random.nextInt(PartTypes.all.length)];
        final partPosition =
            PartPositions.all[_random.nextInt(PartPositions.all.length)];
        final status = _randomStatus();
        final date = status == RepairStatus.pending || status == RepairStatus.inProgress
            ? _randomFutureDate(days: 30)
            : _randomPastDate(days: 180);

        final repair = Repair(
          id: _uuid.v4(),
          partType: partType,
          partPosition: partPosition,
          description: _randomDescription(),
          date: date,
          cost: _randomCost(),
          clientId: car.clientId,
          carId: car.id,
          carMake: car.make,
          carModel: car.model,
          status: status,
          createdAt: DateTime.now().subtract(Duration(days: _random.nextInt(200))),
        );

        final result = await _repairRepository.addRepair(repair);
        result.fold(
          (failure) => debugPrint('Ошибка создания ремонта: $failure'),
          (created) => repairs.add(created),
        );
      }
    }

    return repairs;
  }

  // ============== Материалы ==============

  Future<List<Material>> _seedMaterials() async {
    final materials = <Material>[];

    for (final data in _materialsData) {
      final material = Material(
        id: _uuid.v4(),
        name: data['name'] as String,
        quantity: (data['quantity'] as num).toDouble(),
        unit: data['unit'] as MaterialUnit,
        minQuantity: (data['minQuantity'] as num).toDouble(),
        cost: (data['cost'] as num).toDouble(),
        createdAt: _randomPastDate(days: 100),
      );

      final result = await _materialRepository.addMaterial(material);
      result.fold(
        (failure) => debugPrint('Ошибка создания материала: $failure'),
        (created) => materials.add(created),
      );
    }

    return materials;
  }

  // ============== Helpers ==============

  DateTime _randomPastDate({required int days}) {
    return DateTime.now().subtract(Duration(days: _random.nextInt(days)));
  }

  DateTime _randomFutureDate({required int days}) {
    return DateTime.now().add(Duration(days: _random.nextInt(days) + 1));
  }

  String _generatePlate() {
    const letters = 'АВЕКМНОРСТУХ';
    final l1 = letters[_random.nextInt(letters.length)];
    final l2 = letters[_random.nextInt(letters.length)];
    final l3 = letters[_random.nextInt(letters.length)];
    final num = (_random.nextInt(900) + 100).toString();
    final region = (_random.nextInt(199) + 1).toString().padLeft(2, '0');
    return '$l1$num$l2$l3 $region';
  }

  RepairStatus _randomStatus() {
    final weights = [3, 2, 8, 1]; // pending, inProgress, completed, cancelled
    final total = weights.reduce((a, b) => a + b);
    var random = _random.nextInt(total);

    for (var i = 0; i < weights.length; i++) {
      if (random < weights[i]) {
        return RepairStatus.values[i];
      }
      random -= weights[i];
    }
    return RepairStatus.completed;
  }

  double _randomCost() {
    // 3000 - 50000 рублей
    return ((_random.nextInt(470) + 30) * 100).toDouble();
  }

  String _randomDescription() {
    final descriptions = [
      'Замена сальников и втулок',
      'Полная переборка',
      'Замена штока',
      'Ремонт клапана',
      'Замена пневмобаллона',
      'Диагностика и ремонт',
      'Устранение течи масла',
      'Замена опорного подшипника',
      '',
      '',
    ];
    return descriptions[_random.nextInt(descriptions.length)];
  }

  // ============== Test Data ==============

  static const _clientsData = [
    {'name': 'Иванов Сергей Петрович', 'phone': '+7 (916) 123-45-67'},
    {'name': 'Петров Алексей Николаевич', 'phone': '+7 (926) 234-56-78'},
    {'name': 'Сидоров Михаил Андреевич', 'phone': '+7 (903) 345-67-89'},
    {'name': 'Козлов Дмитрий Владимирович', 'phone': '+7 (985) 456-78-90'},
    {'name': 'Новиков Артём Игоревич', 'phone': '+7 (977) 567-89-01'},
    {'name': 'Морозов Евгений Сергеевич', 'phone': '+7 (915) 678-90-12'},
    {'name': 'Волков Андрей Александрович', 'phone': '+7 (925) 789-01-23'},
    {'name': 'Соколов Илья Дмитриевич', 'phone': '+7 (909) 890-12-34'},
    {'name': 'Лебедев Максим Олегович', 'phone': '+7 (965) 901-23-45'},
    {'name': 'Кузнецов Роман Викторович', 'phone': '+7 (929) 012-34-56'},
    {'name': 'ООО "АвтоТранс"', 'phone': '+7 (495) 111-22-33'},
    {'name': 'ИП Смирнов А.В.', 'phone': '+7 (499) 222-33-44'},
  ];

  static const _carsData = [
    {'make': 'Mercedes-Benz', 'model': 'S-Class W222'},
    {'make': 'Mercedes-Benz', 'model': 'E-Class W213'},
    {'make': 'Mercedes-Benz', 'model': 'GLE W167'},
    {'make': 'BMW', 'model': '7 Series G11'},
    {'make': 'BMW', 'model': '5 Series G30'},
    {'make': 'BMW', 'model': 'X5 G05'},
    {'make': 'Audi', 'model': 'A8 D5'},
    {'make': 'Audi', 'model': 'A6 C8'},
    {'make': 'Audi', 'model': 'Q7 4M'},
    {'make': 'Porsche', 'model': 'Cayenne E3'},
    {'make': 'Porsche', 'model': 'Panamera 971'},
    {'make': 'Land Rover', 'model': 'Range Rover L405'},
    {'make': 'Land Rover', 'model': 'Range Rover Sport L494'},
    {'make': 'Lexus', 'model': 'LS 500'},
    {'make': 'Lexus', 'model': 'LX 570'},
    {'make': 'Toyota', 'model': 'Land Cruiser 300'},
    {'make': 'Volkswagen', 'model': 'Touareg CR'},
    {'make': 'Bentley', 'model': 'Continental GT'},
    {'make': 'Rolls-Royce', 'model': 'Ghost'},
  ];

  static const _materialsData = [
    {
      'name': 'Масло для амортизаторов SAE 5W',
      'quantity': 25.0,
      'unit': MaterialUnit.l,
      'minQuantity': 5.0,
      'cost': 850.0,
    },
    {
      'name': 'Масло для амортизаторов SAE 10W',
      'quantity': 18.0,
      'unit': MaterialUnit.l,
      'minQuantity': 5.0,
      'cost': 920.0,
    },
    {
      'name': 'Сальник шток 22мм',
      'quantity': 45.0,
      'unit': MaterialUnit.pcs,
      'minQuantity': 10.0,
      'cost': 320.0,
    },
    {
      'name': 'Сальник шток 25мм',
      'quantity': 32.0,
      'unit': MaterialUnit.pcs,
      'minQuantity': 10.0,
      'cost': 350.0,
    },
    {
      'name': 'Втулка направляющая 22мм',
      'quantity': 28.0,
      'unit': MaterialUnit.pcs,
      'minQuantity': 8.0,
      'cost': 480.0,
    },
    {
      'name': 'Втулка направляющая 25мм',
      'quantity': 3.0,
      'unit': MaterialUnit.pcs,
      'minQuantity': 8.0,
      'cost': 520.0,
    },
    {
      'name': 'Пневмобаллон универсальный',
      'quantity': 12.0,
      'unit': MaterialUnit.pcs,
      'minQuantity': 4.0,
      'cost': 4500.0,
    },
    {
      'name': 'Газ азот (баллон)',
      'quantity': 8.0,
      'unit': MaterialUnit.pcs,
      'minQuantity': 2.0,
      'cost': 1200.0,
    },
    {
      'name': 'Комплект уплотнителей Mercedes',
      'quantity': 6.0,
      'unit': MaterialUnit.kit,
      'minQuantity': 3.0,
      'cost': 2800.0,
    },
    {
      'name': 'Комплект уплотнителей BMW',
      'quantity': 8.0,
      'unit': MaterialUnit.kit,
      'minQuantity': 3.0,
      'cost': 2650.0,
    },
    {
      'name': 'Комплект уплотнителей Audi',
      'quantity': 5.0,
      'unit': MaterialUnit.kit,
      'minQuantity': 3.0,
      'cost': 2750.0,
    },
    {
      'name': 'Шток амортизатора (заготовка)',
      'quantity': 4.0,
      'unit': MaterialUnit.pcs,
      'minQuantity': 2.0,
      'cost': 3200.0,
    },
    {
      'name': 'Поршень амортизатора',
      'quantity': 15.0,
      'unit': MaterialUnit.pcs,
      'minQuantity': 5.0,
      'cost': 1800.0,
    },
    {
      'name': 'Клапан отбоя',
      'quantity': 20.0,
      'unit': MaterialUnit.pcs,
      'minQuantity': 8.0,
      'cost': 650.0,
    },
    {
      'name': 'Клапан сжатия',
      'quantity': 18.0,
      'unit': MaterialUnit.pcs,
      'minQuantity': 8.0,
      'cost': 720.0,
    },
  ];
}

/// Результат работы сидера
class SeederResult {
  final bool success;
  final String message;
  final int clientsCreated;
  final int carsCreated;
  final int repairsCreated;
  final int materialsCreated;

  const SeederResult({
    required this.success,
    required this.message,
    this.clientsCreated = 0,
    this.carsCreated = 0,
    this.repairsCreated = 0,
    this.materialsCreated = 0,
  });
}
