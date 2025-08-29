import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HotZone {
  final String name;
  final String demandLevel;
  final int estimatedRides;
  final double latitude;
  final double longitude;

  HotZone({
    required this.name,
    required this.demandLevel,
    required this.estimatedRides,
    required this.latitude,
    required this.longitude,
  });
}

class DemandPrediction {
  int get hour => 0;

  String get location => '';

  final String area;
  final String timeSlot;
  final String demandLevel;
  final int estimatedRides;

  DemandPrediction({
    required this.area,
    required this.timeSlot,
    required this.demandLevel,
    required this.estimatedRides,
  });
}

class DemandPredictionService extends ChangeNotifier {
  bool _isLoading = false;
  HotZone? _currentHotZone;
  List<DemandPrediction> _predictions = [];
  List<String> _tips = [];

  bool get isLoading => _isLoading;
  HotZone? get currentHotZone => _currentHotZone;
  List<DemandPrediction> get predictions => _predictions;
  List<String> get tips => _tips;

  Future<void> loadPredictions() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simular dados por enquanto
      await Future.delayed(const Duration(seconds: 2));

      _currentHotZone = HotZone(
        name: 'Centro da Cidade',
        demandLevel: 'Alta',
        estimatedRides: 15,
        latitude: -23.5505,
        longitude: -46.6333,
      );

      _predictions = [
        DemandPrediction(
          area: 'Centro',
          timeSlot: '08:00 - 10:00',
          demandLevel: 'Alta',
          estimatedRides: 20,
        ),
        DemandPrediction(
          area: 'Aeroporto',
          timeSlot: '14:00 - 16:00',
          demandLevel: 'Média',
          estimatedRides: 12,
        ),
      ];

      _tips = [
        'Fique próximo ao centro entre 8h e 10h',
        'Aeroporto tem boa demanda à tarde',
        'Evite bairros residenciais no meio da manhã',
      ];
    } catch (e) {
      print('Erro ao carregar previsões: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> getCurrentDemandData() async {
    return {
      'hotZones': [_currentHotZone],
      'predictions': _predictions,
      'lastUpdate': DateTime.now().toIso8601String(),
    };
  }

  Future<Map<String, dynamic>?> getPredictions() async {
    // Alinhar com expectativa do screen que consome
    return {
      'hotZones': [_currentHotZone],
      'predictions': _predictions,
      'lastUpdate': DateTime.now().toIso8601String(),
    };
  }
}