import 'package:flutter/foundation.dart';

class LocationService extends ChangeNotifier {
  double? _latitude;
  double? _longitude;
  String? _address;

  double? get latitude => _latitude;
  double? get longitude => _longitude;
  String? get address => _address;

  Future<void> getCurrentLocation() async {
    try {
      // Simular obtenção de localização
      await Future.delayed(const Duration(seconds: 1));
      
      // Coordenadas de exemplo (São Paulo)
      _latitude = -23.5505;
      _longitude = -46.6333;
      _address = 'São Paulo, SP';
      
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao obter localização: $e');
    }
  }
}

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
