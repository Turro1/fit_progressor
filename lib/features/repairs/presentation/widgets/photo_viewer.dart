import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PhotoViewer extends StatefulWidget {
  final List<String> photoPaths;
  final int initialIndex;

  const PhotoViewer({
    Key? key,
    required this.photoPaths,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<PhotoViewer> createState() => _PhotoViewerState();
}

class _PhotoViewerState extends State<PhotoViewer>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late int _currentIndex;

  // Контроллеры для каждого изображения
  final Map<int, TransformationController> _transformControllers = {};

  // Состояние зума
  bool _isZoomed = false;
  double _currentScale = 1.0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final controller in _transformControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TransformationController _getController(int index) {
    if (!_transformControllers.containsKey(index)) {
      _transformControllers[index] = TransformationController();
    }
    return _transformControllers[index]!;
  }

  void _onDoubleTap(int index, TapDownDetails details) {
    final controller = _getController(index);
    final position = details.localPosition;

    HapticFeedback.lightImpact();

    if (_isZoomed) {
      // Сбросить зум
      _animateToIdentity(controller);
    } else {
      // Зумить в точку нажатия
      _animateToScale(controller, position, 2.5);
    }
  }

  void _animateToIdentity(TransformationController controller) {
    final animation = Matrix4Tween(
      begin: controller.value,
      end: Matrix4.identity(),
    ).animate(CurvedAnimation(
      parent: AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
      )..forward(),
      curve: Curves.easeOutCubic,
    ));

    animation.addListener(() {
      controller.value = animation.value;
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isZoomed = false;
          _currentScale = 1.0;
        });
      }
    });
  }

  void _animateToScale(
    TransformationController controller,
    Offset position,
    double scale,
  ) {
    // Создаем матрицу трансформации для зума в точку
    final matrix = Matrix4.identity();
    matrix.setEntry(0, 3, position.dx * (1 - scale));
    matrix.setEntry(1, 3, position.dy * (1 - scale));
    matrix.setEntry(0, 0, scale);
    matrix.setEntry(1, 1, scale);

    final animation = Matrix4Tween(
      begin: controller.value,
      end: matrix,
    ).animate(CurvedAnimation(
      parent: AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
      )..forward(),
      curve: Curves.easeOutCubic,
    ));

    animation.addListener(() {
      controller.value = animation.value;
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isZoomed = true;
          _currentScale = scale;
        });
      }
    });
  }

  void _onInteractionUpdate(ScaleUpdateDetails details) {
    setState(() {
      _currentScale = details.scale;
      _isZoomed = _currentScale > 1.1;
    });
  }

  void _onInteractionEnd(int index, ScaleEndDetails details) {
    final controller = _getController(index);
    final scale = controller.value.getMaxScaleOnAxis();

    setState(() {
      _currentScale = scale;
      _isZoomed = scale > 1.1;
    });

    // Если масштаб меньше 1, сбросить к исходному
    if (scale < 1.0) {
      _animateToIdentity(controller);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text(
          'Фото ${_currentIndex + 1} из ${widget.photoPaths.length}',
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Фото галерея
          PageView.builder(
            controller: _pageController,
            // Отключаем свайп страниц при зуме
            physics: _isZoomed
                ? const NeverScrollableScrollPhysics()
                : const PageScrollPhysics(),
            itemCount: widget.photoPaths.length,
            onPageChanged: (index) {
              // Сбросить зум предыдущего фото
              final prevController = _transformControllers[_currentIndex];
              if (prevController != null) {
                prevController.value = Matrix4.identity();
              }

              setState(() {
                _currentIndex = index;
                _isZoomed = false;
                _currentScale = 1.0;
              });
              HapticFeedback.selectionClick();
            },
            itemBuilder: (context, index) {
              return _ZoomablePhoto(
                photoPath: widget.photoPaths[index],
                controller: _getController(index),
                onDoubleTap: (details) => _onDoubleTap(index, details),
                onInteractionUpdate: _onInteractionUpdate,
                onInteractionEnd: (details) => _onInteractionEnd(index, details),
              );
            },
          ),

          // Индикатор зума
          if (_isZoomed)
            Positioned(
              top: MediaQuery.of(context).padding.top + 60,
              right: 16,
              child: _ZoomIndicator(scale: _currentScale),
            ),

          // Page indicators
          if (widget.photoPaths.length > 1)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: _buildPageIndicators(),
            ),

          // Подсказка
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              opacity: !_isZoomed ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.touch_app, size: 16, color: Colors.white70),
                      SizedBox(width: 8),
                      Text(
                        'Двойной тап для увеличения',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicators() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            widget.photoPaths.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentIndex == index ? 20 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentIndex == index ? Colors.white : Colors.white38,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Зумируемое фото с жестами
class _ZoomablePhoto extends StatelessWidget {
  final String photoPath;
  final TransformationController controller;
  final void Function(TapDownDetails) onDoubleTap;
  final void Function(ScaleUpdateDetails) onInteractionUpdate;
  final void Function(ScaleEndDetails) onInteractionEnd;

  const _ZoomablePhoto({
    required this.photoPath,
    required this.controller,
    required this.onDoubleTap,
    required this.onInteractionUpdate,
    required this.onInteractionEnd,
  });

  @override
  Widget build(BuildContext context) {
    final file = File(photoPath);

    return GestureDetector(
      onDoubleTapDown: onDoubleTap,
      child: InteractiveViewer(
        transformationController: controller,
        minScale: 0.5,
        maxScale: 5.0,
        onInteractionUpdate: onInteractionUpdate,
        onInteractionEnd: onInteractionEnd,
        child: Center(
          child: file.existsSync()
              ? Image.file(
                  file,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildErrorWidget();
                  },
                )
              : _buildErrorWidget(),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image, size: 64, color: Colors.white54),
          SizedBox(height: 16),
          Text(
            'Не удалось загрузить изображение',
            style: TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Индикатор уровня зума
class _ZoomIndicator extends StatelessWidget {
  final double scale;

  const _ZoomIndicator({required this.scale});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.zoom_in, size: 16, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            '${scale.toStringAsFixed(1)}x',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
