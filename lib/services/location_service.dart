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

