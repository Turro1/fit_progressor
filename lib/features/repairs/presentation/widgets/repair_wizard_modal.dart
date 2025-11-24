import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../cars/domain/entities/car.dart';
import '../../../cars/presentation/bloc/car_bloc.dart';
import '../../../cars/presentation/bloc/car_state.dart';
import '../../../clients/domain/entities/client.dart';
import '../../../clients/presentation/bloc/client_bloc.dart';
import '../../../clients/presentation/bloc/client_state.dart';
import '../../domain/entities/repair_status.dart';
import '../bloc/repair_bloc.dart';
import '../bloc/repair_event.dart';

class RepairWizardModal extends StatefulWidget {
  const RepairWizardModal({Key? key}) : super(key: key);

  @override
  State<RepairWizardModal> createState() => _RepairWizardModalState();
}

class _RepairWizardModalState extends State<RepairWizardModal> {
  int _currentStep = 0;
  Car? _selectedCar;
  RepairStatus _selectedStatus = RepairStatus.inProgress;
  final _descriptionController = TextEditingController();
  final _costWorkController = TextEditingController(text: '0');
  final _searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _descriptionController.dispose();
    _costWorkController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      height: MediaQuery.of(context).size.height * 0.85,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _currentStep == 0 ? _buildStep1() : _buildStep2(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.borderColor),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.build_circle,
            color: AppColors.accentPrimary,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Новый ремонт: Шаг ${_currentStep + 1}/2',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: TextField(
            controller: _searchController,
            style: TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Поиск по гос. номеру, марке, клиенту...',
              hintStyle: TextStyle(color: AppColors.textSecondary),
              filled: true,
              fillColor: AppColors.bgMain,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.borderColor),
              ),
              prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        Expanded(
          child: BlocBuilder<CarBloc, CarState>(
            builder: (context, carState) {
              if (carState is! CarLoaded) {
                return Center(
                  child: CircularProgressIndicator(
                    color: AppColors.accentPrimary,
                  ),
                );
              }

              final searchTerm = _searchController.text.toLowerCase();
              final filteredCars = carState.cars.where((car) {
                if (searchTerm.isEmpty) return true;
                return car.make.toLowerCase().contains(searchTerm) ||
                    car.model.toLowerCase().contains(searchTerm) ||
                    (car.plate.toLowerCase().contains(searchTerm));
              }).toList();

              if (filteredCars.isEmpty) {
                return Center(
                  child: Text(
                    searchTerm.isEmpty
                        ? 'Нет автомобилей'
                        : 'Ничего не найдено',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                );
              }

              return BlocBuilder<ClientBloc, ClientState>(
                builder: (context, clientState) {
                  List<Client> clients = [];
                  if (clientState is ClientLoaded) {
                    clients = clientState.clients;
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: filteredCars.length,
                    itemBuilder: (context, index) {
                      final car = filteredCars[index];
                      final client = clients.firstWhere(
                        (c) => c.id == car.clientId,
                      );

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCar = car;
                            _currentStep = 1;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: AppColors.bgMain,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.borderColor),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${car.make} ${car.model}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${client.name} • ${car.plate}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.bgMain,
                borderRadius: BorderRadius.circular(8),
              ),
              child: BlocBuilder<ClientBloc, ClientState>(
                builder: (context, clientState) {
                  String clientName = 'N/A';
                  if (clientState is ClientLoaded && _selectedCar != null) {
                    try {
                      final client = clientState.clients.firstWhere(
                        (c) => c.id == _selectedCar!.clientId,
                      );
                      clientName = client.name;
                    } catch (_) {}
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_selectedCar?.make} ${_selectedCar?.model}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Владелец: $clientName',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Описание работ',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              style: TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Краткое описание проблемы или работ...',
                hintStyle: TextStyle(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.bgMain,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Введите описание';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            Text(
              'Статус',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<RepairStatus>(
              value: _selectedStatus,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.bgMain,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              dropdownColor: AppColors.bgHeader,
              style: TextStyle(color: AppColors.textPrimary),
              items: [
                RepairStatus.inProgress,
                RepairStatus.waitingParts,
              ].map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status.displayName),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedStatus = value);
                }
              },
            ),
            const SizedBox(height: 20),
            Text(
              'Стоимость работ (₽) - предварительно',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _costWorkController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.bgMain,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Icon(
                  Icons.attach_money,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      setState(() => _currentStep = 0);
                    },
                    child: Text(
                      'Назад',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentPrimary,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Создать ремонт',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() && _selectedCar != null) {
      context.read<RepairBloc>().add(
            AddRepairEvent(
              carId: _selectedCar!.id,
              status: _selectedStatus,
              description: _descriptionController.text,
              costWork: double.tryParse(_costWorkController.text) ?? 0,
            ),
          );
      Navigator.pop(context);
    }
  }
}