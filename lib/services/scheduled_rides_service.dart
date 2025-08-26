import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/scheduled_ride.dart';
import 'notification_service.dart';

class ScheduledRidesService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationService _notificationService = NotificationService();

  List<ScheduledRide> _scheduledRides = [];
  bool _isLoading = false;

  List<ScheduledRide> get scheduledRides => _scheduledRides;
  bool get isLoading => _isLoading;

  Future<void> loadScheduledRides() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user != null) {
        final snapshot = await _firestore
            .collection('scheduled_rides')
            .where('motoristaId', isEqualTo: user.uid)
            .orderBy('scheduledDateTime')
            .get();

        _scheduledRides = snapshot.docs
            .map((doc) => ScheduledRide.fromMap(doc.data(), doc.id))
            .toList();
      }
    } catch (e) {
      print('Erro ao carregar corridas programadas: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> acceptScheduledRide(String rideId) async {
    try {
      await _firestore.collection('scheduled_rides').doc(rideId).update({
        'status': 'accepted',
        'acceptedAt': FieldValue.serverTimestamp(),
      });

      // Atualizar localmente
      final index = _scheduledRides.indexWhere((ride) => ride.id == rideId);
      if (index != -1) {
        _scheduledRides[index] = _scheduledRides[index].copyWith(status: 'accepted');
        notifyListeners();
      }

      // Agendar notificação
      final ride = _scheduledRides.firstWhere((r) => r.id == rideId);
      await _notificationService.scheduleNotification(
        ride.id.hashCode,
        'Corrida Programada',
        'Sua corrida programada começa em 15 minutos',
        ride.scheduledDateTime.subtract(const Duration(minutes: 15)),
      );
    } catch (e) {
      print('Erro ao aceitar corrida: $e');
    }
  }

  Future<void> startScheduledRide(String rideId) async {
    try {
      await _firestore.collection('scheduled_rides').doc(rideId).update({
        'status': 'in_progress',
        'startedAt': FieldValue.serverTimestamp(),
      });

      final index = _scheduledRides.indexWhere((ride) => ride.id == rideId);
      if (index != -1) {
        _scheduledRides[index] = _scheduledRides[index].copyWith(status: 'in_progress');
        notifyListeners();
      }
    } catch (e) {
      print('Erro ao iniciar corrida: $e');
    }
  }

  Future<bool> cancelScheduledRide(String rideId, String reason) async {
    try {
      await _firestore.collection('scheduled_rides').doc(rideId).update({
        'status': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
        'cancellationReason': reason,
      });

      final index = _scheduledRides.indexWhere((ride) => ride.id == rideId);
      if (index != -1) {
        _scheduledRides[index] = _scheduledRides[index].copyWith(status: 'cancelled');
        notifyListeners();
      }

      // Cancelar notificação agendada
      await _notificationService.cancelNotification(rideId.hashCode);
      return true; // Indica sucesso
    } catch (e) {
      print('Erro ao cancelar corrida: $e');
      return false; // Indica falha
    }
  }

  void filterByDate(DateTime date) {
    // Implementar filtro por data se necessário
    notifyListeners();
  }
}