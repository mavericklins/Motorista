
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/driver_goals.dart';
import 'sound_service.dart';

class GamificationService extends ChangeNotifier {
  // Backing fields para compatibilidade dos getters
  int? _currentLevel, _currentXP, _xpToNextLevel, _currentRank, _totalDrivers;
  double? _levelProgress;
  List<Map<String, dynamic>>? _achievements, _topDrivers, _weeklyChallenges;
  Map<String, dynamic>? _dailyChallenge;

  int get currentLevel => _currentLevel ?? 1;

  int get currentXP => _currentXP ?? 0;

  double get levelProgress => _levelProgress ?? 0.0;

  int get xpToNextLevel => _xpToNextLevel ?? 100;

  int get currentRank => _currentRank ?? 999;

  int get totalDrivers => _totalDrivers ?? 1000;

  List<Map<String, dynamic>> get achievements => _achievements ?? const [];

  List<Map<String, dynamic>> get topDrivers => _topDrivers ?? const [];

  Map<String, dynamic> get dailyChallenge => _dailyChallenge ?? {'title':'Faça 5 corridas','progress':0.0,'current':0,'target':5,'reward':25};

  List<Map<String, dynamic>> get weeklyChallenges => _weeklyChallenges ?? [{'title':'20 corridas na semana','progress':0.0}];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final SoundService _soundService = SoundService();

  // Sistema de Eco-Score
  Future<Map<String, dynamic>> calcularEcoScore(String motoristaId) async {
    try {
      final now = DateTime.now();
      final inicioMes = DateTime(now.year, now.month, 1);

      final querySnapshot = await _firestore
          .collection('corridas')
          .where('motoristaId', isEqualTo: motoristaId)
          .where('status', isEqualTo: 'concluida')
          .where('concluidaEm', isGreaterThan: Timestamp.fromDate(inicioMes))
          .get();

      double totalDistancia = 0;
      double totalTempo = 0;
      double totalCombustivel = 0;
      int conducoesEficientes = 0;
      int totalCorridas = querySnapshot.docs.length;

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final distancia = (data['distancia'] as num?)?.toDouble() ?? 0;
        final tempo = (data['tempoViagem'] as num?)?.toDouble() ?? 0;
        
        totalDistancia += distancia;
        totalTempo += tempo;
        
        // Estimar consumo de combustível (média 10km/L urbano)
        final combustivelEstimado = distancia / 10;
        totalCombustivel += combustivelEstimado;
        
        // Condução eficiente: velocidade média entre 40-60 km/h
        if (tempo > 0) {
          final velocidadeMedia = (distancia / tempo) * 60; // km/h
          if (velocidadeMedia >= 40 && velocidadeMedia <= 60) {
            conducoesEficientes++;
          }
        }
      }

      // Calcular métricas eco
      final eficienciaCombustivel = totalDistancia > 0 ? totalDistancia / totalCombustivel : 0;
      final porcentagemEficiente = totalCorridas > 0 ? (conducoesEficientes / totalCorridas) * 100 : 0;
      final emissaoCO2 = totalCombustivel * 2.31; // kg CO2 por litro
      
      // Score eco (0-100)
      double ecoScore = 0;
      ecoScore += (eficienciaCombustivel / 12) * 40; // 40 pontos para eficiência
      ecoScore += porcentagemEficiente * 0.6; // 60 pontos para condução eficiente
      ecoScore = ecoScore.clamp(0, 100);

      return {
        'ecoScore': ecoScore.round(),
        'nivel': _obterNivelEco(ecoScore),
        'eficienciaCombustivel': eficienciaCombustivel,
        'porcentagemEficiente': porcentagemEficiente,
        'emissaoCO2': emissaoCO2,
        'arvoresCompensadas': (emissaoCO2 / 22).round(), // 1 árvore = ~22kg CO2/ano
        'ranking': 'Top 25%', // Placeholder - implementar ranking real
        'proximaMeta': _obterProximaMetaEco(ecoScore),
        'dicas': _obterDicasEco(ecoScore),
      };
    } catch (e) {
      print('Erro ao calcular eco-score: $e');
      return {'ecoScore': 0, 'nivel': 'Iniciante'};
    }
  }

  String _obterNivelEco(double score) {
    if (score >= 90) return 'Eco Master';
    if (score >= 80) return 'Eco Expert';
    if (score >= 70) return 'Eco Driver';
    if (score >= 60) return 'Eco Conscious';
    if (score >= 50) return 'Eco Learner';
    return 'Eco Iniciante';
  }

  String _obterProximaMetaEco(double score) {
    if (score < 50) return 'Chegue a 50 pontos para ser Eco Learner';
    if (score < 60) return 'Chegue a 60 pontos para ser Eco Conscious';
    if (score < 70) return 'Chegue a 70 pontos para ser Eco Driver';
    if (score < 80) return 'Chegue a 80 pontos para ser Eco Expert';
    if (score < 90) return 'Chegue a 90 pontos para ser Eco Master';
    return 'Mantenha seu nível Eco Master!';
  }

  List<String> _obterDicasEco(double score) {
    if (score < 50) {
      return [
        'Mantenha velocidade entre 40-60 km/h',
        'Evite acelerações e freadas bruscas',
        'Desligue o ar condicionado quando possível'
      ];
    } else if (score < 70) {
      return [
        'Use o GPS para evitar trânsito parado',
        'Planeje rotas mais eficientes',
        'Mantenha os pneus calibrados'
      ];
    } else {
      return [
        'Continue mantendo condução eficiente',
        'Compartilhe dicas eco com outros motoristas',
        'Considere horários com menos trânsito'
      ];
    }
  }

  // Achievements disponíveis
  static const Map<String, Map<String, dynamic>> availableAchievements = {
    'eco_iniciante': {
      'titulo': 'Eco Iniciante',
      'descricao': 'Atingiu 50 pontos de eco-score',
      'icone': '🌱',
      'pontos': 25,
    },
    'eco_driver': {
      'titulo': 'Eco Driver',
      'descricao': 'Atingiu 70 pontos de eco-score',
      'icone': '🌿',
      'pontos': 75,
    },
    'eco_master': {
      'titulo': 'Eco Master',
      'descricao': 'Atingiu 90 pontos de eco-score',
      'icone': '🌳',
      'pontos': 150,
    },
    'primeira_corrida': {
      'titulo': 'Primeira Corrida',
      'descricao': 'Complete sua primeira corrida',
      'icone': '🎉',
      'pontos': 10,
    },
    'corredor_dedicado': {
      'titulo': 'Corredor Dedicado',
      'descricao': 'Complete 10 corridas',
      'icone': '🏃‍♂️',
      'pontos': 50,
    },
    'veterano': {
      'titulo': 'Veterano',
      'descricao': 'Complete 100 corridas',
      'icone': '👑',
      'pontos': 200,
    },
    'madrugador': {
      'titulo': 'Madrugador',
      'descricao': 'Complete 5 corridas entre 5h e 7h',
      'icone': '🌅',
      'pontos': 30,
    },
    'noturno': {
      'titulo': 'Coruja Noturna',
      'descricao': 'Complete 5 corridas entre 22h e 5h',
      'icone': '🦉',
      'pontos': 30,
    },
    'meta_semanal': {
      'titulo': 'Meta Semanal Alcançada',
      'descricao': 'Complete sua meta semanal de ganhos',
      'icone': '🎯',
      'pontos': 100,
    },
    'avaliacao_5_estrelas': {
      'titulo': 'Cinco Estrelas',
      'descricao': 'Mantenha avaliação 5.0 por 20 corridas',
      'icone': '⭐',
      'pontos': 150,
    },
  };

  // Stream das metas do motorista
  Stream<DriverGoals?> getDriverGoals() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value(null);

    return _firestore
        .collection('driver_goals')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists 
            ? DriverGoals.fromMap(doc.data()!, doc.id)
            : null);
  }

  // Criar metas iniciais para motorista
  Future<void> createInitialGoals() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final today = DateTime.now();
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final endOfWeek = startOfWeek.add(Duration(days: 6));

    final goals = {
      'motoristaId': userId,
      'metasDiarias': {
        'corridas': GoalTarget(
          tipo: 'corridas',
          objetivo: 5,
          atual: 0,
          concluida: false,
          dataLimite: DateTime(today.year, today.month, today.day, 23, 59),
          bonus: 10.0,
        ).toMap(),
        'ganhos': GoalTarget(
          tipo: 'ganhos',
          objetivo: 80.0,
          atual: 0,
          concluida: false,
          dataLimite: DateTime(today.year, today.month, today.day, 23, 59),
          bonus: 20.0,
        ).toMap(),
      },
      'metasSemanais': {
        'corridas': GoalTarget(
          tipo: 'corridas',
          objetivo: 30,
          atual: 0,
          concluida: false,
          dataLimite: endOfWeek,
          bonus: 50.0,
        ).toMap(),
        'ganhos': GoalTarget(
          tipo: 'ganhos',
          objetivo: 500.0,
          atual: 0,
          concluida: false,
          dataLimite: endOfWeek,
          bonus: 100.0,
        ).toMap(),
      },
      'metasMensais': {
        'corridas': GoalTarget(
          tipo: 'corridas',
          objetivo: 120,
          atual: 0,
          concluida: false,
          dataLimite: DateTime(today.year, today.month + 1, 1).subtract(Duration(days: 1)),
          bonus: 200.0,
        ).toMap(),
      },
      'conquistas': [],
      'pontuacao': 0,
      'nivel': 1,
      'estatisticas': {
        'totalCorridas': 0,
        'totalGanhos': 0.0,
        'tempoOnlineTotal': 0,
        'avaliacaoMedia': 0.0,
        'corridasNoturnas': 0,
        'corridasMatutinas': 0,
      },
      'atualizadoEm': FieldValue.serverTimestamp(),
    };

    await _firestore.collection('driver_goals').doc(userId).set(goals);
  }

  // Atualizar progresso após corrida
  Future<void> updateProgressAfterRide(Map<String, dynamic> rideData) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final docRef = _firestore.collection('driver_goals').doc(userId);
    final doc = await docRef.get();
    
    if (!doc.exists) {
      await createInitialGoals();
      return;
    }

    final goals = DriverGoals.fromMap(doc.data()!, doc.id);
    final valor = (rideData['valor'] ?? 0.0).toDouble();
    final horaInicio = DateTime.parse(rideData['iniciadoEm'] ?? DateTime.now().toIso8601String());

    // Atualizar metas diárias
    await _updateDailyGoals(docRef, goals, valor);
    
    // Atualizar metas semanais
    await _updateWeeklyGoals(docRef, goals, valor);
    
    // Atualizar metas mensais
    await _updateMonthlyGoals(docRef, goals, valor);
    
    // Verificar conquistas
    await _checkAchievements(docRef, goals, rideData);
    
    // Atualizar estatísticas
    await _updateStatistics(docRef, goals, rideData);
  }

  Future<void> _updateDailyGoals(DocumentReference docRef, DriverGoals goals, double valor) async {
    final updates = <String, dynamic>{};
    
    // Meta de corridas diárias
    if (goals.metasDiarias.containsKey('corridas')) {
      final meta = goals.metasDiarias['corridas']!;
      final novoValor = meta.atual + 1;
      updates['metasDiarias.corridas.atual'] = novoValor;
      updates['metasDiarias.corridas.concluida'] = novoValor >= meta.objetivo;
    }

    // Meta de ganhos diários
    if (goals.metasDiarias.containsKey('ganhos')) {
      final meta = goals.metasDiarias['ganhos']!;
      final novoValor = meta.atual + valor;
      updates['metasDiarias.ganhos.atual'] = novoValor;
      updates['metasDiarias.ganhos.concluida'] = novoValor >= meta.objetivo;
    }

    if (updates.isNotEmpty) {
      await docRef.update(updates);
    }
  }

  Future<void> _updateWeeklyGoals(DocumentReference docRef, DriverGoals goals, double valor) async {
    final updates = <String, dynamic>{};
    
    // Meta de corridas semanais
    if (goals.metasSemanais.containsKey('corridas')) {
      final meta = goals.metasSemanais['corridas']!;
      final novoValor = meta.atual + 1;
      updates['metasSemanais.corridas.atual'] = novoValor;
      updates['metasSemanais.corridas.concluida'] = novoValor >= meta.objetivo;
      
      // Se completou meta semanal, dar achievement
      if (novoValor >= meta.objetivo && !meta.concluida) {
        await _grantAchievement(docRef, 'meta_semanal');
      }
    }

    // Meta de ganhos semanais
    if (goals.metasSemanais.containsKey('ganhos')) {
      final meta = goals.metasSemanais['ganhos']!;
      final novoValor = meta.atual + valor;
      updates['metasSemanais.ganhos.atual'] = novoValor;
      updates['metasSemanais.ganhos.concluida'] = novoValor >= meta.objetivo;
    }

    if (updates.isNotEmpty) {
      await docRef.update(updates);
    }
  }

  Future<void> _updateMonthlyGoals(DocumentReference docRef, DriverGoals goals, double valor) async {
    final updates = <String, dynamic>{};
    
    // Meta de corridas mensais
    if (goals.metasMensais.containsKey('corridas')) {
      final meta = goals.metasMensais['corridas']!;
      final novoValor = meta.atual + 1;
      updates['metasMensais.corridas.atual'] = novoValor;
      updates['metasMensais.corridas.concluida'] = novoValor >= meta.objetivo;
    }

    if (updates.isNotEmpty) {
      await docRef.update(updates);
    }
  }

  Future<void> _checkAchievements(DocumentReference docRef, DriverGoals goals, Map<String, dynamic> rideData) async {
    final conquistas = goals.conquistas.map((c) => c.id).toList();
    final totalCorridas = goals.estatisticas['totalCorridas'] ?? 0;

    // Primeira corrida
    if (totalCorridas == 0 && !conquistas.contains('primeira_corrida')) {
      await _grantAchievement(docRef, 'primeira_corrida');
    }

    // 10 corridas
    if (totalCorridas + 1 == 10 && !conquistas.contains('corredor_dedicado')) {
      await _grantAchievement(docRef, 'corredor_dedicado');
    }

    // 100 corridas
    if (totalCorridas + 1 == 100 && !conquistas.contains('veterano')) {
      await _grantAchievement(docRef, 'veterano');
    }

    // Verificar horários
    final horaInicio = DateTime.parse(rideData['iniciadoEm'] ?? DateTime.now().toIso8601String());
    final hora = horaInicio.hour;

    if (hora >= 5 && hora < 7) {
      final corridasMatutinas = goals.estatisticas['corridasMatutinas'] ?? 0;
      if (corridasMatutinas + 1 >= 5 && !conquistas.contains('madrugador')) {
        await _grantAchievement(docRef, 'madrugador');
      }
    }

    if (hora >= 22 || hora < 5) {
      final corridasNoturnas = goals.estatisticas['corridasNoturnas'] ?? 0;
      if (corridasNoturnas + 1 >= 5 && !conquistas.contains('noturno')) {
        await _grantAchievement(docRef, 'noturno');
      }
    }
  }

  Future<void> _grantAchievement(DocumentReference docRef, String achievementId) async {
    final achievement = availableAchievements[achievementId];
    if (achievement == null) return;

    final newAchievement = Achievement(
      id: achievementId,
      titulo: achievement['titulo'],
      descricao: achievement['descricao'],
      icone: achievement['icone'],
      conquistadoEm: DateTime.now(),
      pontos: achievement['pontos'],
    );

    await docRef.update({
      'conquistas': FieldValue.arrayUnion([newAchievement.toMap()]),
      'pontuacao': FieldValue.increment(achievement['pontos']),
    });

    // Tocar som de conquista
    await _soundService.playSound('vello_success.mp3');
  }

  Future<void> _updateStatistics(DocumentReference docRef, DriverGoals goals, Map<String, dynamic> rideData) async {
    final horaInicio = DateTime.parse(rideData['iniciadoEm'] ?? DateTime.now().toIso8601String());
    final hora = horaInicio.hour;
    final valor = (rideData['valor'] ?? 0.0).toDouble();

    final updates = {
      'estatisticas.totalCorridas': FieldValue.increment(1),
      'estatisticas.totalGanhos': FieldValue.increment(valor),
      'atualizadoEm': FieldValue.serverTimestamp(),
    };

    if (hora >= 5 && hora < 7) {
      updates['estatisticas.corridasMatutinas'] = FieldValue.increment(1);
    }

    if (hora >= 22 || hora < 5) {
      updates['estatisticas.corridasNoturnas'] = FieldValue.increment(1);
    }

    await docRef.update(updates);
  }

  // Calcular nível baseado na pontuação
  int calculateLevel(int pontuacao) {
    if (pontuacao < 100) return 1;
    if (pontuacao < 300) return 2;
    if (pontuacao < 600) return 3;
    if (pontuacao < 1000) return 4;
    if (pontuacao < 1500) return 5;
    return ((pontuacao - 1500) ~/ 500) + 6;
  }

  // Obter ranking semanal
  Future<List<Map<String, dynamic>>> getWeeklyRanking() async {
    try {
      final snapshot = await _firestore
          .collection('driver_goals')
          .orderBy('metasSemanais.ganhos.atual', descending: true)
          .limit(10)
          .get();

      final ranking = <Map<String, dynamic>>[];
      
      for (int i = 0; i < snapshot.docs.length; i++) {
        final doc = snapshot.docs[i];
        final data = doc.data();
        
        // Buscar dados do motorista
        final motoristaDoc = await _firestore
            .collection('motoristas')
            .doc(data['motoristaId'])
            .get();

        if (motoristaDoc.exists) {
          final motorista = motoristaDoc.data()!;
          ranking.add({
            'posicao': i + 1,
            'nome': motorista['nome'] ?? 'Motorista',
            'foto': motorista['fotoUrl'],
            'ganhos': data['metasSemanais']?['ganhos']?['atual'] ?? 0.0,
            'corridas': data['metasSemanais']?['corridas']?['atual'] ?? 0,
            'pontuacao': data['pontuacao'] ?? 0,
            'nivel': calculateLevel(data['pontuacao'] ?? 0),
          });
        }
      }

      return ranking;
    } catch (e) {
      print('Erro ao buscar ranking: $e');
      return [];
    }
  }
}


extension SoundServiceCompat on SoundService {
  Future<void> playSound(String asset) async {
    try {
      // Se já existir na classe real, este extension não será usado.
    } catch (_) {}
  }
}
