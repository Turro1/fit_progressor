import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/add_car_photo.dart';
import '../../domain/usecases/delete_car_photo.dart';
import '../../domain/usecases/get_car_photos.dart';
import 'car_photo_event.dart';
import 'car_photo_state.dart';

class CarPhotoBloc extends Bloc<CarPhotoEvent, CarPhotoState> {
  final GetCarPhotos getCarPhotos;
  final AddCarPhoto addCarPhoto;
  final DeleteCarPhoto deleteCarPhoto;

  CarPhotoBloc({
    required this.getCarPhotos,
    required this.addCarPhoto,
    required this.deleteCarPhoto,
  }) : super(CarPhotoInitial()) {
    on<LoadCarPhotos>(_onLoadCarPhotos);
    on<AddCarPhotoEvent>(_onAddCarPhoto);
    on<DeleteCarPhotoEvent>(_onDeleteCarPhoto);
  }

  Future<void> _onLoadCarPhotos(
    LoadCarPhotos event,
    Emitter<CarPhotoState> emit,
  ) async {
    emit(CarPhotoLoading());
    final result = await getCarPhotos(event.carId);
    result.fold(
      (failure) => emit(const CarPhotoError(message: 'Не удалось загрузить фотографии автомобиля')),
      (photos) => emit(CarPhotoLoaded(photos: photos, carId: event.carId)),
    );
  }

  Future<void> _onAddCarPhoto(
    AddCarPhotoEvent event,
    Emitter<CarPhotoState> emit,
  ) async {
    emit(CarPhotoLoading());
    final params = AddCarPhotoParams(
      carId: event.carId,
      photoPath: event.photoPath,
      description: event.description,
    );
    final result = await addCarPhoto(params);
    result.fold(
      (failure) => emit(const CarPhotoError(message: 'Не удалось добавить фотографию автомобиля')),
      (photo) async {
        emit(const CarPhotoOperationSuccess(message: 'Фотография автомобиля успешно добавлена'));
        add(LoadCarPhotos(carId: event.carId)); // Reload photos for the car
      },
    );
  }

  Future<void> _onDeleteCarPhoto(
    DeleteCarPhotoEvent event,
    Emitter<CarPhotoState> emit,
  ) async {
    emit(CarPhotoLoading());
    final result = await deleteCarPhoto(event.photoId);
    result.fold(
      (failure) => emit(const CarPhotoError(message: 'Не удалось удалить фотографию автомобиля')),
      (_) async {
        emit(const CarPhotoOperationSuccess(message: 'Фотография автомобиля успешно удалена'));
        add(LoadCarPhotos(carId: event.carId)); // Reload photos for the car
      },
    );
  }
}
