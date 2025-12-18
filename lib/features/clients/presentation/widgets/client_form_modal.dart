import 'package:fit_progressor/features/clients/domain/entities/client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.client?.name ?? '');
    _phoneController = TextEditingController(text: widget.client?.phone ?? '');

    // Слушаем изменения для обновления character counter
    _nameController.addListener(() {
      setState(() {});
    });
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
          // Phone field
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Телефон',
              helperText: 'Формат: +7 (XXX) XXX-XX-XX',
              hintText: '+7 (999) 123-45-67',
              prefixIcon: Icon(Icons.phone),
            ),
            validator: (value) {
              // Телефон необязателен, но если заполнен, должен быть валидным
              if (value != null && value.isNotEmpty) {
                final digits = value.replaceAll(RegExp(r'\D'), '');
                if (digits.length < 10) {
                  return 'Введите корректный номер телефона';
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

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      if (widget.client == null) {
        context.read<ClientBloc>().add(
          AddClientEvent(
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
          ),
        );
      } else {
        context.read<ClientBloc>().add(
          UpdateClientEvent(
            client: Client(
              id: widget.client!.id,
              name: _nameController.text.trim(),
              phone: _phoneController.text.trim(),
              createdAt: widget.client!.createdAt,
            ),
          ),
        );
      }
    }
  }
}
