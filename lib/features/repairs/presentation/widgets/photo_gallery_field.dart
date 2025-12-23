import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PhotoGalleryField extends StatefulWidget {
  final List<String> initialPhotoPaths;
  final ValueChanged<List<String>> onPhotosChanged;

  const PhotoGalleryField({
    Key? key,
    this.initialPhotoPaths = const [],
    required this.onPhotosChanged,
  }) : super(key: key);

  @override
  State<PhotoGalleryField> createState() => _PhotoGalleryFieldState();
}

class _PhotoGalleryFieldState extends State<PhotoGalleryField> {
  late List<String> _photoPaths;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _photoPaths = List.from(widget.initialPhotoPaths);
  }

  Future<void> _addPhoto(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _photoPaths.add(image.path);
        widget.onPhotosChanged(_photoPaths);
      });
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _photoPaths.removeAt(index);
      widget.onPhotosChanged(_photoPaths);
    });
  }

  void _showSourceSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Камера'),
              onTap: () {
                Navigator.pop(context);
                _addPhoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Галерея'),
              onTap: () {
                Navigator.pop(context);
                _addPhoto(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Фотографии',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: _photoPaths.length + 1,
          itemBuilder: (context, index) {
            if (index < _photoPaths.length) {
              return PhotoThumbnail(
                photoPath: _photoPaths[index],
                onDelete: () => _removePhoto(index),
              );
            } else {
              return AddPhotoButton(onAdd: _showSourceSelector);
            }
          },
        ),
      ],
    );
  }
}

class PhotoThumbnail extends StatelessWidget {
  final String photoPath;
  final VoidCallback onDelete;

  const PhotoThumbnail({
    Key? key,
    required this.photoPath,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            File(photoPath),
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: IconButton(
            icon: const Icon(Icons.close, size: 20, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: Colors.black54,
              padding: const EdgeInsets.all(4),
              minimumSize: const Size(28, 28),
            ),
            onPressed: onDelete,
          ),
        ),
      ],
    );
  }
}

class AddPhotoButton extends StatelessWidget {
  final VoidCallback onAdd;

  const AddPhotoButton({
    Key? key,
    required this.onAdd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onAdd,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate,
              size: 32,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 4),
            Text(
              'Фото',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
