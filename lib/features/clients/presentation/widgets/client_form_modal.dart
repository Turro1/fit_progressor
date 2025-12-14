import 'package:fit_progressor/features/clients/domain/entities/client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/client_bloc.dart';
import '../bloc/client_event.dart';
import 'package:fit_progressor/shared/widgets/base_form_modal.dart'; // Import BaseFormModal

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

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.client?.name ?? '');
    _phoneController = TextEditingController(text: widget.client?.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseFormModal(
      titleIcon: Icon(
        widget.client == null ? Icons.person_add : Icons.edit,
      ),
      titleText:
      widget.client == null ? 'Новый клиент' : 'Редактировать клиента',
      formKey: _formKey,
      formFields: [
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Имя',
            prefixIcon: Icon(Icons.person),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Введите имя';
            }
            if (value.length < 2) {
              return 'Имя должно содержать минимум 2 символа';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Телефон',
            hintText: '+7 (999) 123-45-67',
            prefixIcon: Icon(Icons.phone),
          ),
        ),
      ],
      onSubmit: _submitForm,
      submitButtonText: widget.client == null ? 'Добавить' : 'Сохранить',
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
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
      Navigator.pop(context);
    }
  }
}
