import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;

/// Serviço de notificações push para Vello Motorista
class NotificationService {
      Future<void> showNotification({required int id, required String title, required String body}) async {
        const androidDetails = AndroidNotificationDetails(
          'vello_default',
          'Vello Notificações',
          channelDescription: 'Alertas do app Vello',
          importance: Importance.high,
          priority: Priority.high,
        );
        const iosDetails = DarwinNotificationDetails();
        await _localNotifications.show(id, title, body, const NotificationDetails(android: androidDetails, iOS: iosDetails));
      }

  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _fcmToken;
  String? _driverId;

  // Callbacks para diferentes tipos de notificação
  Function(Map<String, dynamic>)? onNewRideRequest;
  Function(Map<String, dynamic>)? onRideUpdate;
  Function(Map<String, dynamic>)? onPaymentUpdate;
  Function(Map<String, dynamic>)? onSystemMessage;

  /// Inicializa o serviço de notificações
  Future<void> initialize(String driverId) async {
    _driverId = driverId;
    
    await _initializeLocalNotifications();
    await _initializeFirebaseMessaging();
    await _requestPermissions();
    await _getFCMToken();
    await _setupMessageHandlers();
  }

  /// Inicializa notificações locais
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  /// Inicializa Firebase Messaging
  Future<void> _initializeFirebaseMessaging() async {
    // Configura canal de notificação para Android
    const androidChannel = AndroidNotificationChannel(
      'vello_motorista_channel',
      'Vello Motorista',
      description: 'Notificações do Vello Motorista',
      importance: Importance.high,
      sound: RawResourceAndroidNotificationSound('notification_sound'),
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  /// Solicita permissões de notificação
  Future<void> _requestPermissions() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
    );

    print('Permissão de notificação: ${settings.authorizationStatus}');
  }

  /// Obtém token FCM
  Future<void> _getFCMToken() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      print('FCM Token: $_fcmToken');

      if (_fcmToken != null && _driverId != null) {
        await _saveTokenToFirestore();
      }

      // Escuta mudanças no token
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        _saveTokenToFirestore();
      });
    } catch (e) {
      print('Erro ao obter FCM token: $e');
    }
  }

  /// Salva token no Firestore
  Future<void> _saveTokenToFirestore() async {
    if (_fcmToken == null || _driverId == null) return;

    try {
      await _firestore.collection('motoristas').doc(_driverId).update({
        'fcmToken': _fcmToken,
        'lastTokenUpdate': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Erro ao salvar token: $e');
    }
  }

  /// Configura handlers de mensagens
  Future<void> _setupMessageHandlers() async {
    // Mensagem recebida quando app está em foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Mensagem clicada quando app está em background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

    // Verifica se app foi aberto por uma notificação
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleBackgroundMessage(initialMessage);
    }
  }

  /// Manipula mensagem em foreground
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Mensagem recebida em foreground: ${message.data}');

    final notificationType = message.data['type'] ?? 'general';
    
    // Mostra notificação local
    await _showLocalNotification(
      title: message.notification?.title ?? 'Vello Motorista',
      body: message.notification?.body ?? 'Nova notificação',
      payload: json.encode(message.data),
      type: notificationType,
    );

    // Chama callback apropriado
    _handleNotificationByType(notificationType, message.data);
  }

  /// Manipula mensagem em background
  Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    print('Mensagem clicada em background: ${message.data}');
    
    final notificationType = message.data['type'] ?? 'general';
    _handleNotificationByType(notificationType, message.data);
  }

  /// Manipula notificação por tipo
  void _handleNotificationByType(String type, Map<String, dynamic> data) {
    switch (type) {
      case 'new_ride_request':
        onNewRideRequest?.call(data);
        break;
      case 'ride_update':
        onRideUpdate?.call(data);
        break;
      case 'payment_update':
        onPaymentUpdate?.call(data);
        break;
      case 'system_message':
        onSystemMessage?.call(data);
        break;
      default:
        print('Tipo de notificação desconhecido: $type');
    }
  }

  /// Mostra notificação local
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
    required String type,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'vello_motorista_channel',
      'Vello Motorista',
      channelDescription: 'Notificações do Vello Motorista',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      sound: _getNotificationSound(type),
      enableVibration: true,
      vibrationPattern: _getVibrationPattern(type),
      color: _getNotificationColor(type),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// Obtém som da notificação baseado no tipo
  RawResourceAndroidNotificationSound? _getNotificationSound(String type) {
    switch (type) {
      case 'new_ride_request':
        return const RawResourceAndroidNotificationSound('ride_request_sound');
      case 'payment_update':
        return const RawResourceAndroidNotificationSound('payment_sound');
      default:
        return const RawResourceAndroidNotificationSound('notification_sound');
    }
  }

  /// Obtém padrão de vibração baseado no tipo
  Int64List _getVibrationPattern(String type) {
    switch (type) {
      case 'new_ride_request':
        return Int64List.fromList([0, 1000, 500, 1000]); // Vibração urgente
      case 'payment_update':
        return Int64List.fromList([0, 500, 200, 500]); // Vibração suave
      default:
        return Int64List.fromList([0, 250, 250, 250]); // Vibração padrão
    }
  }

  /// Obtém cor da notificação baseado no tipo
  Color _getNotificationColor(String type) {
    switch (type) {
      case 'laranja':
        return const Color(0xFFFF8C42);
      case 'verde':
        return const Color(0xFF10B981);
      case 'azul':
        return const Color(0xFF1B3A57);
      default:
        return Colors.grey;
    }
  }

  /// Manipula toque na notificação
  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      try {
        final data = json.decode(response.payload!);
        final type = data['type'] ?? 'general';
        _handleNotificationByType(type, data);
      } catch (e) {
        print('Erro ao processar payload da notificação: $e');
      }
    }
  }

  /// Envia notificação para um motorista específico
  Future<bool> sendNotificationToDriver({
    required String driverId,
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Busca token do motorista
      final driverDoc = await _firestore.collection('motoristas').doc(driverId).get();
      if (!driverDoc.exists) return false;

      final driverData = driverDoc.data()!;
      final fcmToken = driverData['fcmToken'];
      if (fcmToken == null) return false;

      // Prepara dados da notificação
      final notificationData = {
        'type': type,
        'timestamp': DateTime.now().toIso8601String(),
        ...?data,
      };

      // Envia via FCM
      return await _sendFCMNotification(
        token: fcmToken,
        title: title,
        body: body,
        data: notificationData,
      );
    } catch (e) {
      print('Erro ao enviar notificação: $e');
      return false;
    }
  }

  /// Envia notificação via FCM
  Future<bool> _sendFCMNotification({
    required String token,
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    try {
      // Busca server key do Firebase
      final configDoc = await _firestore.collection('config').doc('firebase').get();
      if (!configDoc.exists) return false;

      final serverKey = configDoc.data()!['serverKey'];
      if (serverKey == null) return false;

      final message = {
        'to': token,
        'notification': {
          'title': title,
          'body': body,
          'sound': 'default',
        },
        'data': data.map((key, value) => MapEntry(key, value.toString())),
        'android': {
          'priority': 'high',
          'notification': {
            'channel_id': 'vello_motorista_channel',
            'sound': 'default',
          },
        },
        'apns': {
          'payload': {
            'aps': {
              'sound': 'default',
              'badge': 1,
            },
          },
        },
      };

      final response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {
          'Authorization': 'key=$serverKey',
          'Content-Type': 'application/json',
        },
        body: json.encode(message),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Erro ao enviar FCM: $e');
      return false;
    }
  }

  /// Envia notificação de nova corrida
  Future<bool> sendNewRideNotification({
    required String driverId,
    required String rideId,
    required String origin,
    required String destination,
    required double distance,
    required double fare,
  }) async {
    return await sendNotificationToDriver(
      driverId: driverId,
      title: '🚗 Nova Corrida Disponível!',
      body: 'De $origin para $destination • ${distance.toStringAsFixed(1)}km • R\$ ${fare.toStringAsFixed(2)}',
      type: 'new_ride_request',
      data: {
        'rideId': rideId,
        'origin': origin,
        'destination': destination,
        'distance': distance,
        'fare': fare,
      },
    );
  }

  /// Envia notificação de atualização de corrida
  Future<bool> sendRideUpdateNotification({
    required String driverId,
    required String rideId,
    required String status,
    required String message,
  }) async {
    return await sendNotificationToDriver(
      driverId: driverId,
      title: 'Atualização da Corrida',
      body: message,
      type: 'ride_update',
      data: {
        'rideId': rideId,
        'status': status,
      },
    );
  }

  /// Envia notificação de pagamento
  Future<bool> sendPaymentNotification({
    required String driverId,
    required String rideId,
    required double amount,
    required String status,
  }) async {
    String title;
    String body;

    switch (status) {
      case 'approved':
        title = '💰 Pagamento Recebido!';
        body = 'R\$ ${amount.toStringAsFixed(2)} foi creditado na sua conta';
        break;
      case 'pending':
        title = '⏳ Pagamento Pendente';
        body = 'Aguardando confirmação do pagamento de R\$ ${amount.toStringAsFixed(2)}';
        break;
      case 'rejected':
        title = '❌ Pagamento Rejeitado';
        body = 'O pagamento de R\$ ${amount.toStringAsFixed(2)} foi rejeitado';
        break;
      default:
        title = 'Atualização de Pagamento';
        body = 'Status do pagamento: $status';
    }

    return await sendNotificationToDriver(
      driverId: driverId,
      title: title,
      body: body,
      type: 'payment_update',
      data: {
        'rideId': rideId,
        'amount': amount,
        'status': status,
      },
    );
  }

  /// Envia notificação do sistema
  Future<bool> sendSystemNotification({
    required String driverId,
    required String title,
    required String message,
    String? actionUrl,
  }) async {
    return await sendNotificationToDriver(
      driverId: driverId,
      title: title,
      body: message,
      type: 'system_message',
      data: {
        'actionUrl': actionUrl,
      },
    );
  }

  /// Agenda notificação local
  Future<void> scheduleLocalNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'vello_motorista_scheduled',
      'Lembretes Vello',
      channelDescription: 'Notificações agendadas do Vello Motorista',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Cancela notificação agendada
  Future<void> cancelScheduledNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  /// Cancela todas as notificações
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  /// Obtém notificações pendentes
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _localNotifications.pendingNotificationRequests();
  }

  /// Atualiza badge do app (iOS)
  Future<void> updateBadgeCount(int count) async {
    // Implementar para iOS se necessário
  }

  /// Limpa badge do app
  Future<void> clearBadge() async {
    await updateBadgeCount(0);
  }

  /// Subscreve a tópicos FCM
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  /// Desinscreve de tópicos FCM
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }

  /// Limpa recursos
  void dispose() {
    // Limpar recursos se necessário
  }

  /// Agenda notificação
  Future<void> scheduleNotification(
    int id,
    String title,
    String body,
    DateTime scheduledDate, {
    String type = 'laranja',
  }) async {
    final color = _getNotificationColor(type);

    const String channelId = 'vello_motorista_channel';
    const String channelName = 'Vello Motorista';
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      importance: Importance.max,
      priority: Priority.high,
      color: color,
      icon: '@mipmap/ic_launcher',
    );

    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Cancela notificação
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }
}
