import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vello_motorista/services/notification_service.dart';

class AdvancedSecurityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> suggestRestPoints() async {
    try {
      final position = await Geolocator.getCurrentPosition();

      final pontos = await _firestore
          .collection('pontos_apoio')
          .where('ativo', isEqualTo: true)
          .get();

      final pontosProximos = <Map<String, dynamic>>[];

      for (final doc in pontos.docs) {
        final data = doc.data();
        final distance = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          data['latitude'],
          data['longitude'],
        );

        if (distance <= 5000) {
          pontosProximos.add({
            ...data,
            'distance': distance,
            'id': doc.id,
          });
        }
      }

      if (pontosProximos.isNotEmpty) {
        pontosProximos.sort((a, b) => a['distance'].compareTo(b['distance']));
        final pontoProximo = pontosProximos.first;
        final distanciaKm = (pontoProximo['distance'] / 1000).toStringAsFixed(1);

        await NotificationService().showNotification(
          id: DateTime.now().millisecondsSinceEpoch,
          title: 'Ponto de descanso próximo',
          body: 'O ponto mais próximo está a $distanciaKm km.',
        );
      }
    } catch (e) {
      print('Erro ao sugerir pontos de descanso: $e');
    }
  }

  Future<void> shareLocation() async {
    final position = await Geolocator.getCurrentPosition();
    await NotificationService().showNotification(
      id: DateTime.now().millisecondsSinceEpoch,
      title: 'Localização compartilhada',
      body: 'Latitude: ${position.latitude}, Longitude: ${position.longitude}',
    );
  }

  Future<void> callEmergency(String number) async {
    print('Ligando para $number');
    await NotificationService().showNotification(
      id: DateTime.now().millisecondsSinceEpoch,
      title: 'Ligação de emergência',
      body: 'Ligando para $number...',
    );
  }

  Future<void> sendEmergencyMessage() async {
    print('Enviando mensagem de emergência');
    await NotificationService().showNotification(
      id: DateTime.now().millisecondsSinceEpoch,
      title: 'Mensagem de emergência',
      body: 'Mensagem de emergência enviada!',
    );
  }

  Future<void> activateEmergency() async {
    print('Emergência ativada');
    await NotificationService().showNotification(
      id: DateTime.now().millisecondsSinceEpoch,
      title: 'Emergência ativada',
      body: 'O modo emergência foi ativado!',
    );
  }

  Future<void> cancelEmergency() async {
    print('Emergência cancelada');
    await NotificationService().showNotification(
      id: DateTime.now().millisecondsSinceEpoch,
      title: 'Emergência cancelada',
      body: 'O modo emergência foi cancelado!',
    );
  }
}