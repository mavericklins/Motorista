import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService extends ChangeNotifier {
  Position? _currentPosition;
  bool _isLocationEnabled = false;
  bool _hasPermission = false;

  Position? get currentPosition => _currentPosition;
  bool get isLocationEnabled => _isLocationEnabled;
  bool get hasPermission => _hasPermission;

  Future<bool> requestLocationPermission() async {
    try {
      final permission = await Permission.location.request();
      _hasPermission = permission == PermissionStatus.granted;
      notifyListeners();
      return _hasPermission;
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao solicitar permissão de localização: $e');
      }
      return false;
    }
  }

  Future<Position?> getCurrentPosition() async {
    try {
      if (!_hasPermission) {
        await requestLocationPermission();
      }

      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      notifyListeners();
      return _currentPosition;
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao obter localização: $e');
      }
      return null;
    }
  }
}
