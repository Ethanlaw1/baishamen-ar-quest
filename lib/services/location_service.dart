import 'dart:async';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

class LocationPermissionResult {
  final bool ok;
  final String message;
  final bool serviceDisabled;
  final bool permanentlyDenied;

  const LocationPermissionResult({
    required this.ok,
    required this.message,
    this.serviceDisabled = false,
    this.permanentlyDenied = false,
  });
}

class LocationService {
  static Future<LocationPermissionResult> ensurePermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return const LocationPermissionResult(
        ok: false,
        serviceDisabled: true,
        message: '手机定位服务未开启，请先打开系统定位。',
      );
    }

    // 先用 permission_handler 主动请求，OPPO/ColorOS 上更容易弹出权限框。
    final phStatus = await ph.Permission.locationWhenInUse.request();
    if (phStatus.isPermanentlyDenied || phStatus.isRestricted) {
      return const LocationPermissionResult(
        ok: false,
        permanentlyDenied: true,
        message: '定位权限被永久拒绝，请点「打开应用权限设置」手动开启。',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      return const LocationPermissionResult(
        ok: false,
        permanentlyDenied: true,
        message: '定位权限被永久拒绝，请点「打开应用权限设置」手动开启。',
      );
    }

    if (permission == LocationPermission.denied) {
      return const LocationPermissionResult(
        ok: false,
        message: '你还没有授予定位权限，无法显示实时位置。',
      );
    }

    return const LocationPermissionResult(ok: true, message: '定位权限已开启');
  }

  static Future<void> openAppSettings() async {
    await ph.openAppSettings();
  }

  static Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  static Stream<Position> positionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 1,
      ),
    );
  }

  static Future<Position?> currentPosition() async {
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
        timeLimit: const Duration(seconds: 15),
      );
    } catch (_) {
      return null;
    }
  }

  static double distanceMeters(double lat1, double lng1, double lat2, double lng2) {
    return Geolocator.distanceBetween(lat1, lng1, lat2, lng2);
  }

  static double bearingDegrees(double lat1, double lng1, double lat2, double lng2) {
    return Geolocator.bearingBetween(lat1, lng1, lat2, lng2);
  }

  static Stream<double?> headingStream() {
    return FlutterCompass.events?.map((e) => e.heading) ?? const Stream.empty();
  }
}
