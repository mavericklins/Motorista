import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/scheduled_ride.dart';

class ScheduledRidesService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<ScheduledRide> _scheduledRides = [];
  bool _isLoading = false;

  List<ScheduledRide> get scheduledRides => _scheduledRides;
  bool get isLoading => _isLoading;

  Future<List<ScheduledRide>> getScheduledRides() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final querySnapshot = await _firestore
          .collection('scheduled_rides')
          .orderBy('scheduledTime')
          .get();

      return querySnapshot.docs
          .map((doc) => ScheduledRide.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Erro ao carregar corridas programadas: $e');
    }
  }

  Future<void> loadScheduledRides() async {
    _isLoading = true;
    notifyListeners();

    try {
      _scheduledRides = await getScheduledRides();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception('Erro ao carregar corridas programadas: $e');
    }
  }

  Future<bool> acceptScheduledRide(String rideId) async {
    try {
      final index = _scheduledRides.indexWhere((ride) => ride.id == rideId);
      if (index != -1) {
        _scheduledRides[index] = _scheduledRides[index].copyWith(status: ScheduledRideStatus.accepted);
        notifyListeners();
      }

      await _firestore.collection('scheduled_rides').doc(rideId).update({
        'status': 'accepted',
        'acceptedAt': FieldValue.serverTimestamp(),
      });
      
      return true;
    } catch (e) {
      throw Exception('Erro ao aceitar corrida: $e');
    }
  }

  void scheduleNotification(ScheduledRide ride) {
    // Agendar notificação 15 minutos antes do horário
    final notificationTime = ride.scheduledTime.subtract(const Duration(minutes: 15));

    // Implementar lógica de notificação local aqui
    print('Notificação agendada para ${notificationTime}');
  }

  Future<bool> startScheduledRide(String rideId) async {
    try {
      await _firestore.collection('scheduled_rides').doc(rideId).update({
        'status': 'in_progress',
        'startedAt': FieldValue.serverTimestamp(),
      });

      final index = _scheduledRides.indexWhere((ride) => ride.id == rideId);
      if (index != -1) {
        _scheduledRides[index] = _scheduledRides[index].copyWith(status: ScheduledRideStatus.inProgress);
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      throw Exception('Erro ao iniciar corrida: $e');
    }
  }

  Future<bool> completeScheduledRide(String rideId) async {
    try {
      await _firestore.collection('scheduled_rides').doc(rideId).update({
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
      });

      _scheduledRides.removeWhere((ride) => ride.id == rideId);
      notifyListeners();
      
      return true;
    } catch (e) {
      throw Exception('Erro ao completar corrida: $e');
    }
  }

  Future<bool> cancelScheduledRide(String rideId) async {
    try {
      await _firestore.collection('scheduled_rides').doc(rideId).update({
        'status': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
      });

      _scheduledRides.removeWhere((ride) => ride.id == rideId);
      notifyListeners();
      
      return true;
    } catch (e) {
      throw Exception('Erro ao cancelar corrida: $e');
    }
  }

  void clearScheduledRides() {
    _scheduledRides.clear();
    notifyListeners();
  }
}