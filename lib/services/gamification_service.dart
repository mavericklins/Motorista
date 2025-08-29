// lib/services/gamification_service.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:vello_motorista/models/driver_goals.dart';

/// Service compatível com Provider + UI atual.
/// Mantém API que as telas esperam, sem alterar visual/comportamento.
class GamificationService extends ChangeNotifier {
  // --- Estado básico esperado pelas telas ---
  int _currentLevel = 1;
  int _currentXP = 0;
  double _levelProgress = 0.0; // 0.0..1.0
  int _xpToNextLevel = 100;

  int _currentRank = 0;
  int _totalDrivers = 0;

  // Listas/estruturas usadas nas telas
  final List<Map<String, dynamic>> _achievements = <Map<String, dynamic>>[
    {
      'icone': '🎯',
      'titulo': 'Bem-vindo!',
      'descricao': 'Comece a dirigir para ganhar conquistas',
      'pontos': 0,
    },
  ];

  final List<Map<String, dynamic>> _topDrivers = <Map<String, dynamic>>[
    // Ex.: {'nome': 'Você', 'xp': 0, 'rank': 0}
  ];

  final List<Map<String, dynamic>> _weeklyChallenges = <Map<String, dynamic>>[
    // Ex.: {'title': 'Complete 5 corridas', 'progress': 0.0, 'current': 0, 'target': 5, 'reward': 50}
  ];

  Map<String, dynamic> _dailyChallenge = <String, dynamic>{
    'title': 'Sem desafio ativo',
    'progress': 0.0,
    'current': 0,
    'target': 1,
    'reward': 0,
  };

  // --- Getters esperados pelas telas ---
  int get currentLevel => _currentLevel;
  int get currentXP => _currentXP;
  double get levelProgress => _levelProgress;
  int get xpToNextLevel => _xpToNextLevel;

  int get currentRank => _currentRank;
  int get totalDrivers => _totalDrivers;

  List<Map<String, dynamic>> get achievements => _achievements;
  List<Map<String, dynamic>> get topDrivers => _topDrivers;
  List<Map<String, dynamic>> get weeklyChallenges => _weeklyChallenges;
  Map<String, dynamic> get dailyChallenge => _dailyChallenge;

  // --- API esperada pelas telas ---

  /// A UI espera `Stream<DriverGoals?>`. Entregamos um stub seguro.
  Stream<DriverGoals?> getDriverGoals() async* {
    // TODO: integrar fonte real de metas; por enquanto, sem metas.
    yield null;
  }

  /// Algumas telas chamam esse método; retornamos a lista atual.
  Future<List<Map<String, dynamic>>> getWeeklyRanking() async {
    return _topDrivers;
  }

  /// Algumas telas referenciam isso como estático.
  static const Map<String, Map<String, dynamic>> availableAchievements = {
    'first_ride': {
      'icone': '🚗',
      'titulo': 'Primeira corrida',
      'descricao': 'Complete sua primeira corrida',
      'pontos': 10,
    },
  };

  // --- (Opcional) setters/mutadores simples, caso já existam chamadas ---
  void setLevel({
    int? level,
    int? xp,
    double? progress,
    int? xpToNext,
  }) {
    if (level != null) _currentLevel = level;
    if (xp != null) _currentXP = xp;
    if (progress != null) _levelProgress = progress.clamp(0.0, 1.0);
    if (xpToNext != null) _xpToNextLevel = xpToNext;
    notifyListeners();
  }

  void setRanking({int? rank, int? total}) {
    if (rank != null) _currentRank = rank;
    if (total != null) _totalDrivers = total;
    notifyListeners();
  }

  void setDailyChallenge(Map<String, dynamic> value) {
    _dailyChallenge = value;
    notifyListeners();
  }

  void setWeeklyChallenges(List<Map<String, dynamic>> list) {
    _weeklyChallenges
      ..clear()
      ..addAll(list);
    notifyListeners();
  }

  void setTopDrivers(List<Map<String, dynamic>> list) {
    _topDrivers
      ..clear()
      ..addAll(list);
    notifyListeners();
  }

  void setAchievements(List<Map<String, dynamic>> list) {
    _achievements
      ..clear()
      ..addAll(list);
    notifyListeners();
  }
}
