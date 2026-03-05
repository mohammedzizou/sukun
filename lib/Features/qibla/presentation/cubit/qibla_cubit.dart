import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

// --- State ---
abstract class QiblaState extends Equatable {
  const QiblaState();

  @override
  List<Object?> get props => [];
}

class QiblaInitial extends QiblaState {}

class QiblaLoading extends QiblaState {}

class QiblaPermissionDenied extends QiblaState {}

class QiblaNeedsCalibration extends QiblaState {}

class QiblaActive extends QiblaState {
  final double heading;
  final double qiblaDirection;
  final bool isQiblaFound;

  const QiblaActive({
    required this.heading,
    required this.qiblaDirection,
    required this.isQiblaFound,
  });

  @override
  List<Object?> get props => [heading, qiblaDirection, isQiblaFound];
}

// --- Cubit ---
class QiblaCubit extends Cubit<QiblaState> {
  StreamSubscription<QiblahDirection>? _qiblahSubscription;

  // Low Pass Filter variables to prevent jitter
  double _smoothedHeading = 0.0;
  final double _smoothingFactor = 0.15; // Lower is smoother but lags slightly

  QiblaCubit() : super(QiblaInitial());

  Future<void> initializeCompass() async {
    emit(QiblaLoading());

    // 1. Check Device Support
    final deviceSupport = await FlutterQiblah.checkLocationStatus();
    if (deviceSupport.status != LocationPermission.always &&
        deviceSupport.status != LocationPermission.whileInUse) {
      // Try requesting permission
      final status = await FlutterQiblah.requestPermissions();
      if (status != LocationPermission.always &&
          status != LocationPermission.whileInUse) {
        emit(QiblaPermissionDenied());
        return;
      }
    }

    // 2. Start Listening to Hardware Stream
    _startRealHardwareStream();
  }

  void _startRealHardwareStream() {
    _qiblahSubscription?.cancel();

    _qiblahSubscription = FlutterQiblah.qiblahStream.listen((qiblahDirection) {
      // The flutter_qiblah package returns an object containing:
      // - qiblah: The direction of the Qibla (constant)
      // - direction: The current heading/compass direction
      // - offset: The difference

      final rawHeading = qiblahDirection.direction;
      final qiblaAngle = qiblahDirection.qiblah;

      // If we don't have a previous reading, snap to the first one immediately
      if (_smoothedHeading == 0.0) {
        _smoothedHeading = rawHeading;
      } else {
        // Low-Pass Filter: Smooths out the raw magnetometer jitter
        // Calculate shortest angular distance (avoids 359 -> 1 jitter)
        double diff = rawHeading - _smoothedHeading;
        if (diff > 180) diff -= 360;
        if (diff < -180) diff += 360;

        _smoothedHeading = _smoothedHeading + (_smoothingFactor * diff);

        // Normalize 0-360
        if (_smoothedHeading < 0) _smoothedHeading += 360;
        if (_smoothedHeading >= 360) _smoothedHeading -= 360;
      }

      // Calculate if we're pointing at the Qibla (tolerance of ±5 degrees)
      double difference = (_smoothedHeading - qiblaAngle).abs();
      if (difference > 180) difference = 360 - difference;
      bool isFound = difference <= 5.0;

      emit(
        QiblaActive(
          heading: _smoothedHeading,
          qiblaDirection: qiblaAngle,
          isQiblaFound: isFound,
        ),
      );
    });
  }

  void stopCompass() {
    _qiblahSubscription?.cancel();
  }

  void requestRecalibration() {
    emit(QiblaNeedsCalibration());
    stopCompass();

    // Resume hardware listening after users finish their figure 8
    Future.delayed(const Duration(seconds: 4), () {
      _startRealHardwareStream();
    });
  }

  @override
  Future<void> close() {
    stopCompass();
    return super.close();
  }
}
