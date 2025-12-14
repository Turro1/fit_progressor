import 'dart:io';

import 'package:fit_progressor/core/theme/app_colors.dart';
import 'package:fit_progressor/features/repairs/domain/entities/car_photo.dart';
import 'package:fit_progressor/features/repairs/presentation/bloc/car_photo_bloc.dart';
import 'package:fit_progressor/features/repairs/presentation/bloc/car_photo_event.dart';
import 'package:fit_progressor/features/repairs/presentation/bloc/car_photo_state.dart';
import 'package:flutter/material.dart' as flutter_material; // Alias for Flutter's Material
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class CarPhotoViewerModal extends flutter_material.StatefulWidget {
  final String carId;
  final String carMakeModel;

  const CarPhotoViewerModal({
    flutter_material.Key? key,
    required this.carId,
    required this.carMakeModel,
  }) : super(key: key);

  @override
  flutter_material.State<CarPhotoViewerModal> createState() => _CarPhotoViewerModalState();
}

class _CarPhotoViewerModalState extends flutter_material.State<CarPhotoViewerModal> {
  @override
  void initState() {
    super.initState();
    context.read<CarPhotoBloc>().add(LoadCarPhotos(carId: widget.carId));
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      context.read<CarPhotoBloc>().add(AddCarPhotoEvent(
            carId: widget.carId,
            photoPath: image.path,
          ));
    }
  }

  void _confirmDelete(flutter_material.BuildContext context, CarPhoto photo) {
    flutter_material.showDialog(
      context: context,
      builder: (context) => flutter_material.AlertDialog(
        title: flutter_material.Text('Удалить фото?'),
        content: flutter_material.Text('Вы уверены, что хотите удалить эту фотографию?'),
        actions: [
          flutter_material.TextButton(
            onPressed: () => context.pop(),
            child: flutter_material.Text('Отмена'),
          ),
          flutter_material.ElevatedButton(
            onPressed: () {
              context.read<CarPhotoBloc>().add(DeleteCarPhotoEvent(
                    photoId: photo.id,
                    carId: widget.carId,
                  ));
              context.pop(); // Close dialog
            },
            style: flutter_material.ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: flutter_material.Text('Удалить'),
          ),
        ],
      ),
    );
  }

  @override
  flutter_material.Widget build(flutter_material.BuildContext context) {
    return BlocListener<CarPhotoBloc, CarPhotoState>(
      listener: (context, state) {
        if (state is CarPhotoError) {
          flutter_material.ScaffoldMessenger.of(context).showSnackBar(
            flutter_material.SnackBar(content: flutter_material.Text(state.message)),
          );
        } else if (state is CarPhotoOperationSuccess) {
          flutter_material.ScaffoldMessenger.of(context).showSnackBar(
            flutter_material.SnackBar(content: flutter_material.Text(state.message)),
          );
        }
      },
      child: flutter_material.Container(
        height: flutter_material.MediaQuery.of(context).size.height * 0.9,
        decoration: flutter_material.BoxDecoration(
          color: AppColors.background,
          borderRadius: flutter_material.BorderRadius.vertical(top: flutter_material.Radius.circular(20)),
        ),
        child: flutter_material.Column(
          children: [
            _buildHeader(),
            flutter_material.Expanded(
              child: BlocBuilder<CarPhotoBloc, CarPhotoState>(
                builder: (context, state) {
                  if (state is CarPhotoLoading) {
                    return const flutter_material.Center(
                      child: flutter_material.CircularProgressIndicator(
                          color: AppColors.accent),
                    );
                  } else if (state is CarPhotoLoaded) {
                    if (state.photos.isEmpty) {
                      return flutter_material.Center(
                        child: flutter_material.Text(
                          'Нет фотографий для этого автомобиля',
                          style: flutter_material.TextStyle(
                              color: AppColors.textSecondary, fontSize: 16),
                        ),
                      );
                    }
                    return flutter_material.GridView.builder(
                      padding: const flutter_material.EdgeInsets.all(15),
                      gridDelegate:
                          const flutter_material.SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: state.photos.length,
                      itemBuilder: (context, index) {
                        final photo = state.photos[index];
                        return flutter_material.GestureDetector(
                          onLongPress: () => _confirmDelete(context, photo),
                          child: flutter_material.ClipRRect(
                            borderRadius: flutter_material.BorderRadius.circular(8.0),
                            child: flutter_material.Image.file(
                              File(photo.photoPath),
                              fit: flutter_material.BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  flutter_material.Center(
                                child: flutter_material.Icon(flutter_material.Icons.broken_image,
                                    color: AppColors.textSecondary),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                  return flutter_material.Container();
                },
              ),
            ),
            flutter_material.Padding(
              padding: const flutter_material.EdgeInsets.all(15.0),
              child: flutter_material.ElevatedButton.icon(
                onPressed: _pickImage,
                icon: flutter_material.Icon(flutter_material.Icons.add_a_photo, color: AppColors.textPrimary),
                label: flutter_material.Text('Добавить фото',
                    style: flutter_material.TextStyle(color: AppColors.textPrimary)),
                style: flutter_material.ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  padding:
                      const flutter_material.EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: flutter_material.RoundedRectangleBorder(
                    borderRadius: flutter_material.BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  flutter_material.Widget _buildHeader() {
    return flutter_material.Container(
      padding: const flutter_material.EdgeInsets.all(15),
      decoration: flutter_material.BoxDecoration(
        color: AppColors.primary,
        borderRadius: flutter_material.BorderRadius.vertical(top: flutter_material.Radius.circular(20)),
      ),
      child: flutter_material.Row(
        mainAxisAlignment: flutter_material.MainAxisAlignment.spaceBetween,
        children: [
          flutter_material.Text(
            'Фото ${widget.carMakeModel}',
            style: flutter_material.TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: flutter_material.FontWeight.bold,
            ),
          ),
          flutter_material.IconButton(
            icon: flutter_material.Icon(flutter_material.Icons.close, color: AppColors.textPrimary),
            onPressed: () => context.pop(),
          ),
        ],
      ),
    );
  }
}
