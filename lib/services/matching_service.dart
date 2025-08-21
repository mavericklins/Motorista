import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../models/ride.dart';
import '../models/driver.dart';

/// Serviço de matching inteligente em tempo real para Vello Motorista
class MatchingService {
  static final MatchingService _instance = MatchingService._internal();
  factory MatchingService() => _instance;
  MatchingService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot>? _rideRequestsSubscription;
  StreamSubscription<QuerySnapshot>? _activeRidesSubscription;
  
  // Callbacks para notificar a UI
  Function(Ride)? onNewRideRequest;
  Function(Ride)? onRideUpdate;
  Function(String)? onRideCancelled;

  // Configurações do algoritmo de matching
  static const double _maxDistanceKm = 5.0; // Raio máximo de busca
  static const int _maxResponseTimeSeconds = 30; // Tempo máximo para resposta
  static const double _minDriverRating = 4.0; // Avaliação mínima do motorista
  
  /// Inicia o serviço de matching para um motorista
  Future<void> startMatching(String driverId) async {
    await _listenToRideRequests(driverId);
    await _listenToActiveRides(driverId);
  }

  /// Para o serviço de matching
  void stopMatching() {
    _rideRequestsSubscription?.cancel();
    _activeRidesSubscription?.cancel();
  }

  /// Escuta novas solicitações de corrida
  Future<void> _listenToRideRequests(String driverId) async {
    try {
      // Busca motorista atual
      final driverDoc = await _firestore.collection('motoristas').doc(driverId).get();
      if (!driverDoc.exists) return;

      final driver = Driver.fromFirestore(driverDoc);
      if (driver.location == null) return;

      // Escuta corridas pendentes
      _rideRequestsSubscription = _firestore
          .collection('corridas')
          .where('status', isEqualTo: 'pendente')
          .where('motoristaId', isEqualTo: '')
          .snapshots()
          .listen((snapshot) {
        for (var change in snapshot.docChanges) {
          if (change.type == DocumentChangeType.added) {
            final ride = Ride.fromFirestore(change.doc);
            _processRideRequest(ride, driver);
          }
        }
      });
    } catch (e) {
      print('Erro ao escutar solicitações de corrida: $e');
    }
  }

  /// Escuta corridas ativas do motorista
  Future<void> _listenToActiveRides(String driverId) async {
    try {
      _activeRidesSubscription = _firestore
          .collection('corridas')
          .where('motoristaId', isEqualTo: driverId)
          .where('status', whereIn: ['aceita', 'iniciada', 'em_andamento'])
          .snapshots()
          .listen((snapshot) {
        for (var change in snapshot.docChanges) {
          final ride = Ride.fromFirestore(change.doc);
          
          switch (change.type) {
            case DocumentChangeType.added:
            case DocumentChangeType.modified:
              onRideUpdate?.call(ride);
              break;
            case DocumentChangeType.removed:
              onRideCancelled?.call(ride.id);
              break;
          }
        }
      });
    } catch (e) {
      print('Erro ao escutar corridas ativas: $e');
    }
  }

  /// Processa uma nova solicitação de corrida
  Future<void> _processRideRequest(Ride ride, Driver driver) async {
    try {
      // Verifica se o motorista está online e disponível
      if (driver.status != 'online') return;

      // Calcula distância até o passageiro
      final distance = _calculateDistance(
        driver.location!.latitude,
        driver.location!.longitude,
        ride.origemLat,
        ride.origemLon,
      );

      // Verifica se está dentro do raio de atendimento
      if (distance > _maxDistanceKm) return;

      // Verifica avaliação do motorista
      if (driver.rating < _minDriverRating) return;

      // Calcula score de matching
      final score = _calculateMatchingScore(ride, driver, distance);

      // Verifica se é um bom match
      if (score >= 0.7) {
        // Adiciona informações de matching à corrida
        final enrichedRide = _enrichRideWithMatchingData(ride, driver, distance, score);
        
        // Notifica a UI sobre nova corrida disponível
        onNewRideRequest?.call(enrichedRide);
      }
    } catch (e) {
      print('Erro ao processar solicitação de corrida: $e');
    }
  }

  /// Calcula distância entre dois pontos em km
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000;
  }

  /// Calcula score de matching (0.0 a 1.0)
  double _calculateMatchingScore(Ride ride, Driver driver, double distance) {
    double score = 1.0;

    // Fator distância (peso: 40%)
    final distanceScore = max(0.0, 1.0 - (distance / _maxDistanceKm));
    score *= (0.4 * distanceScore + 0.6);

    // Fator avaliação do motorista (peso: 30%)
    final ratingScore = (driver.rating - 3.0) / 2.0; // Normaliza de 3-5 para 0-1
    score *= (0.3 * ratingScore + 0.7);

    // Fator experiência do motorista (peso: 20%)
    final experienceScore = min(1.0, driver.totalRides / 100.0);
    score *= (0.2 * experienceScore + 0.8);

    // Fator tempo de resposta histórico (peso: 10%)
    // TODO: Implementar baseado em dados históricos
    final responseScore = 0.8; // Placeholder
    score *= (0.1 * responseScore + 0.9);

    return min(1.0, score);
  }

  /// Enriquece a corrida com dados de matching
  Ride _enrichRideWithMatchingData(Ride ride, Driver driver, double distance, double score) {
    // Cria uma cópia da corrida com dados adicionais
    // Nota: Isso seria melhor implementado com um modelo específico para matching
    return ride; // Por enquanto retorna a corrida original
  }

  /// Aceita uma corrida
  Future<bool> acceptRide(String rideId, String driverId) async {
    try {
      final batch = _firestore.batch();

      // Atualiza a corrida
      final rideRef = _firestore.collection('corridas').doc(rideId);
      batch.update(rideRef, {
        'motoristaId': driverId,
        'status': 'aceita',
        'aceitaEm': FieldValue.serverTimestamp(),
      });

      // Atualiza status do motorista
      final driverRef = _firestore.collection('motoristas').doc(driverId);
      batch.update(driverRef, {
        'status': 'ocupado',
        'corridaAtiva': rideId,
      });

      await batch.commit();
      return true;
    } catch (e) {
      print('Erro ao aceitar corrida: $e');
      return false;
    }
  }

  /// Rejeita uma corrida
  Future<bool> rejectRide(String rideId, String driverId) async {
    try {
      // Adiciona motorista à lista de rejeitados para esta corrida
      await _firestore.collection('corridas').doc(rideId).update({
        'motoristasRejeitados': FieldValue.arrayUnion([driverId]),
      });

      return true;
    } catch (e) {
      print('Erro ao rejeitar corrida: $e');
      return false;
    }
  }

  /// Inicia uma corrida aceita
  Future<bool> startRide(String rideId) async {
    try {
      await _firestore.collection('corridas').doc(rideId).update({
        'status': 'iniciada',
        'iniciadaEm': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Erro ao iniciar corrida: $e');
      return false;
    }
  }

  /// Finaliza uma corrida
  Future<bool> completeRide(String rideId, String driverId) async {
    try {
      final batch = _firestore.batch();

      // Atualiza a corrida
      final rideRef = _firestore.collection('corridas').doc(rideId);
      batch.update(rideRef, {
        'status': 'concluida',
        'concluidaEm': FieldValue.serverTimestamp(),
      });

      // Libera o motorista
      final driverRef = _firestore.collection('motoristas').doc(driverId);
      batch.update(driverRef, {
        'status': 'online',
        'corridaAtiva': null,
        'totalRides': FieldValue.increment(1),
      });

      await batch.commit();
      return true;
    } catch (e) {
      print('Erro ao finalizar corrida: $e');
      return false;
    }
  }

  /// Cancela uma corrida
  Future<bool> cancelRide(String rideId, String driverId, String motivo) async {
    try {
      final batch = _firestore.batch();

      // Atualiza a corrida
      final rideRef = _firestore.collection('corridas').doc(rideId);
      batch.update(rideRef, {
        'status': 'cancelada',
        'canceladaEm': FieldValue.serverTimestamp(),
        'motivoCancelamento': motivo,
        'canceladaPor': 'motorista',
      });

      // Libera o motorista
      final driverRef = _firestore.collection('motoristas').doc(driverId);
      batch.update(driverRef, {
        'status': 'online',
        'corridaAtiva': null,
      });

      await batch.commit();
      return true;
    } catch (e) {
      print('Erro ao cancelar corrida: $e');
      return false;
    }
  }

  /// Atualiza localização do motorista durante a corrida
  Future<void> updateDriverLocation(String driverId, double lat, double lon) async {
    try {
      await _firestore.collection('motoristas').doc(driverId).update({
        'location.latitude': lat,
        'location.longitude': lon,
        'location.timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Erro ao atualizar localização: $e');
    }
  }

  /// Busca corridas próximas manualmente (fallback)
  Future<List<Ride>> findNearbyRides(String driverId, double lat, double lon) async {
    try {
      final snapshot = await _firestore
          .collection('corridas')
          .where('status', isEqualTo: 'pendente')
          .where('motoristaId', isEqualTo: '')
          .limit(10)
          .get();

      final rides = <Ride>[];
      
      for (var doc in snapshot.docs) {
        final ride = Ride.fromFirestore(doc);
        final distance = _calculateDistance(lat, lon, ride.origemLat, ride.origemLon);
        
        if (distance <= _maxDistanceKm) {
          rides.add(ride);
        }
      }

      // Ordena por distância
      rides.sort((a, b) {
        final distA = _calculateDistance(lat, lon, a.origemLat, a.origemLon);
        final distB = _calculateDistance(lat, lon, b.origemLat, b.origemLon);
        return distA.compareTo(distB);
      });

      return rides;
    } catch (e) {
      print('Erro ao buscar corridas próximas: $e');
      return [];
    }
  }

  /// Obtém estatísticas de matching
  Future<Map<String, dynamic>> getMatchingStats(String driverId) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);

      final snapshot = await _firestore
          .collection('corridas')
          .where('motoristaId', isEqualTo: driverId)
          .where('aceitaEm', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .get();

      final totalRides = snapshot.docs.length;
      final completedRides = snapshot.docs.where((doc) => doc.data()['status'] == 'concluida').length;
      final cancelledRides = snapshot.docs.where((doc) => doc.data()['status'] == 'cancelada').length;

      return {
        'totalRides': totalRides,
        'completedRides': completedRides,
        'cancelledRides': cancelledRides,
        'completionRate': totalRides > 0 ? (completedRides / totalRides) : 0.0,
        'cancellationRate': totalRides > 0 ? (cancelledRides / totalRides) : 0.0,
      };
    } catch (e) {
      print('Erro ao obter estatísticas: $e');
      return {};
    }
  }
}

