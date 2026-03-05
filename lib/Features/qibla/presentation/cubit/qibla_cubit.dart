import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'dart:io';

// --- State ---
abstract class QiblaState extends Equatable {
  const QiblaState();

  @override
  List<Object?> get props => [];
}

class QiblaInitial extends QiblaState {}

class QiblaLoading extends QiblaState {}

class QiblaUnsupported extends QiblaState {}

class QiblaLocationDisabled extends QiblaState {}

class QiblaPermissionDenied extends QiblaState {}

class QiblaPermissionDeniedForever extends QiblaState {}

// Using simple states to handle the overall prerequisites.
// The raw qibla data is streamed directly in the UI as per the example.
class QiblaReady extends QiblaState {}

// --- Cubit ---
class QiblaCubit extends Cubit<QiblaState> {
  QiblaCubit() : super(QiblaInitial());

  Future<void> initializeCompass() async {
    emit(QiblaLoading());

    // 1. Android-specific sensor check
    if (Platform.isAndroid) {
      try {
        final sensorSupport = await FlutterQiblah.androidDeviceSensorSupport();
        if (sensorSupport == false) {
          emit(QiblaUnsupported());
          return;
        }
      } catch (_) {
        // Fallback
      }
    }

    // 2. Check Location Status
    await checkLocationStatus();
  }

  Future<void> checkLocationStatus() async {
    try {
      final status = await FlutterQiblah.checkLocationStatus();

      if (!status.enabled) {
        emit(QiblaLocationDisabled());
        return;
      }

      if (status.status == LocationPermission.denied) {
        await FlutterQiblah.requestPermissions();
        final requestStatus = await FlutterQiblah.checkLocationStatus();
        if (requestStatus.status == LocationPermission.denied) {
          emit(QiblaPermissionDenied());
          return;
        }
        if (requestStatus.status == LocationPermission.deniedForever) {
          emit(QiblaPermissionDeniedForever());
          return;
        }
      }

      if (status.status == LocationPermission.deniedForever) {
        emit(QiblaPermissionDeniedForever());
        return;
      }

      // All good
      emit(QiblaReady());
    } catch (_) {
      emit(QiblaPermissionDenied());
    }
  }

  @override
  Future<void> close() {
    FlutterQiblah().dispose();
    return super.close();
  }
}
