import 'package:fit_progressor/features/clients/domain/entities/client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fit_progressor/core/widgets/country_code_picker.dart';
import '../bloc/client_bloc.dart';
import '../bloc/client_event.dart';
import '../bloc/client_state.dart';
import 'package:fit_progressor/shared/widgets/base_form_modal.dart';
import 'package:fit_progressor/core/theme/app_spacing.dart';

class ClientFormModal extends StatefulWidget {
  final Client? client;

  const ClientFormModal({Key? key, this.client}) : super(key: key);

  @override
  State<ClientFormModal> createState() => _ClientFormModalState();
}

class _ClientFormModalState extends State<ClientFormModal> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  CountryCodeData _selectedCountry = CountryCodes.defaultCountry;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.client?.name ?? '');

    // Парсим существующий телефон клиента
    _parseExistingPhone(widget.client?.phone);

    // Слушаем изменения для обновления character counter
    _nameController.addListener(() {
      setState(() {});
    });
  }

  void _parseExistingPhone(String? phone) {
    if (phone == null || phone.isEmpty) {
      _selectedCountry = CountryCodes.defaultCountry;
      _phoneController = TextEditingController();
      return;
    }

    // Извлекаем только цифры
    final digits = phone.replaceAll(RegExp(r'\D'), '');

    // Пробуем найти код страны
    // Популярные коды стран из региона
    final countryCodes = [
      ('373', 'MD'), // Молдова
      ('380', 'UA'), // Украина
      ('40', 'RO'),  // Румыния
      ('7', 'RU'),   // Россия
      ('375', 'BY'), // Беларусь
    ];

    String? localNumber;
    String countryCodeStr = 'MD';

    for (final (code, country) in countryCodes) {
      if (digits.startsWith(code)) {
        countryCodeStr = country;
        localNumber = digits.substring(code.length);
        break;
      }
    }

    _selectedCountry = CountryCodes.findByCode(countryCodeStr) ?? CountryCodes.defaultCountry;
    _phoneController = TextEditingController(text: localNumber ?? digits);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ClientBloc, ClientState>(
      listener: (context, state) {
        if (state is ClientOperationSuccess) {
          setState(() {
            _isLoading = false;
          });
          Navigator.pop(context);
        } else if (state is ClientError) {
          setState(() {
            _isLoading = false;
          });
        }
      },
      child: BaseFormModal(
        titleIcon: Icon(widget.client == null ? Icons.person_add : Icons.edit),
        titleText: widget.client == null
            ? 'Новый клиент'
            : 'Редактировать клиента',
        formKey: _formKey,
        showDragHandle: true,
        centeredTitle: true,
        isLoading: _isLoading,
        formFields: [
          // Name field with character counter
          TextFormField(
            controller: _nameController,
            maxLength: 50,
            decoration: InputDecoration(
              labelText: 'Имя клиента',
              helperText: 'Минимум 2 символа',
              prefixIcon: const Icon(Icons.person),
              counterText: '${_nameController.text.length}/50',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Введите имя';
              }
              if (value.trim().length < 2) {
                return 'Имя должно содержать минимум 2 символа';
              }
              return null;
            },
          ),
          SizedBox(height: AppSpacing.lg),
          // Phone field with inline country code picker
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(12),
            ],
            decoration: InputDecoration(
              labelText: 'Телефон',
              hintText: '77712345',
              prefixIcon: InkWell(
                onTap: () async {
                  final picked = await showCountryCodePicker(
                    context: context,
                    selectedCountry: _selectedCountry,
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedCountry = picked;
                    });
                  }
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _selectedCountry.flag,
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _selectedCountry.dialCode,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Icon(
                        Icons.arrow_drop_down,
                        size: 18,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            ),
            validator: (value) {
              // Телефон необязателен, но если заполнен, должен быть валидным
              if (value != null && value.isNotEmpty) {
                final digits = value.replaceAll(RegExp(r'\D'), '');
                if (digits.length < 6) {
                  return 'Минимум 6 цифр';
                }
              }
              return null;
            },
          ),
        ],
        onSubmit: _submitForm,
        submitButtonText: widget.client == null ? 'Добавить' : 'Сохранить',
      ),
    );
  }

  /// Формирует полный номер телефона с кодом страны
  String _getFullPhoneNumber() {
    final localNumber = _phoneController.text.trim();
    if (localNumber.isEmpty) return '';

    // Убираем + из кода страны для хранения
    final cleanDialCode = _selectedCountry.dialCode.replaceAll('+', '');
    return '$cleanDialCode$localNumber';
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final phone = _getFullPhoneNumber();

      if (widget.client == null) {
        context.read<ClientBloc>().add(
          AddClientEvent(
            name: _nameController.text.trim(),
            phone: phone,
          ),
        );
      } else {
        context.read<ClientBloc>().add(
          UpdateClientEvent(
            client: Client(
              id: widget.client!.id,
              name: _nameController.text.trim(),
              phone: phone,
              createdAt: widget.client!.createdAt,
            ),
          ),
        );
      }
    }
  }
}
