import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fit_progressor/shared/widgets/app_search_bar.dart';
import '../../domain/entities/material.dart' as material_entity;
import '../bloc/material_bloc.dart';
import '../bloc/material_event.dart';
import '../bloc/material_state.dart' as m_state;
import '../widgets/material_card.dart';
import '../widgets/material_form_modal.dart';

class MaterialsPage extends StatefulWidget {
  const MaterialsPage({Key? key}) : super(key: key);

  @override
  State<MaterialsPage> createState() => _MaterialsPageState();
}

class _MaterialsPageState extends State<MaterialsPage> {
  @override
  void initState() {
    super.initState();
    // Load materials on init
    context.read<MaterialBloc>().add(LoadMaterials());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showMaterialModal(context),
        backgroundColor: theme.colorScheme.secondary,
        foregroundColor: theme.colorScheme.onSecondary,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.inventory_2,
                        color: theme.colorScheme.onSurface,
                        size: 28,
                      ),
                      const SizedBox(width: 10),
                      Text('Склад', style: theme.textTheme.headlineMedium),
                    ],
                  ),
                  const SizedBox(height: 20),
                  AppSearchBar(
                    onSearch: (query) {
                      context.read<MaterialBloc>().add(
                        SearchMaterialsEvent(query: query),
                      );
                    },
                    hintText: 'Поиск материалов...',
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocConsumer<MaterialBloc, m_state.MaterialState>(
                listener: (context, state) {
                  if (state is m_state.MaterialError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: theme.colorScheme.error,
                      ),
                    );
                  }
                  if (state is m_state.MaterialOperationSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: theme.colorScheme.secondary,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is m_state.MaterialLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is m_state.MaterialLoaded) {
                    if (state.materials.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: () async {
                          context.read<MaterialBloc>().add(LoadMaterials());
                        },
                        child: ListView(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.5,
                              child: Center(
                                child: Text(
                                  'Нажмите "+" для добавления материала',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<MaterialBloc>().add(LoadMaterials());
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        itemCount: state.materials.length,
                        itemBuilder: (context, index) {
                          final material = state.materials[index];
                          return MaterialCard(
                            material: material,
                            onEdit: () => _showMaterialModal(context, material),
                            onDelete: () => _confirmDelete(context, material),
                          );
                        },
                      ),
                    );
                  }

                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMaterialModal(
    BuildContext context, [
    material_entity.Material? material,
  ]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BlocProvider.value(
        value: BlocProvider.of<MaterialBloc>(context),
        child: MaterialFormModal(material: material),
      ),
    );
  }

  void _confirmDelete(BuildContext context, material_entity.Material material) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить материал?'),
        content: Text(
          'Это действие нельзя отменить.',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              context.read<MaterialBloc>().add(
                DeleteMaterialEvent(materialId: material.id),
              );
              Navigator.pop(context);
            },
            child: Text(
              'Удалить',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
