import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class NotificationServiceAdvanced {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  /// Inicializar serviço de notificações
  static Future<void> inicializar() async {
    try {
      print('🔔 Inicializando serviço de notificações...');

      // Solicitar permissões
      await _solicitarPermissoes();

      // Configurar notificações locais
      await _configurarNotificacaoLocal();

      // Configurar Awesome Notifications
      await _configurarAwesomeNotifications();

      // Configurar Firebase Messaging
      await _configurarFirebaseMessaging();

      // Obter e salvar token FCM
      await _salvarTokenFCM();

      print('✅ Serviço de notificações inicializado');
    } catch (e) {
      print('❌ Erro ao inicializar notificações: $e');
    }
  }

  /// Solicitar permissões
  static Future<void> _solicitarPermissoes() async {
    // Firebase Messaging
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('Permissão de notificação: ${settings.authorizationStatus}');

    // Awesome Notifications
    await AwesomeNotifications().requestPermissionToSendNotifications();
  }

  /// Configurar notificações locais
  static Future<void> _configurarNotificacaoLocal() async {
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
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }

  /// Configurar Awesome Notifications
  static Future<void> _configurarAwesomeNotifications() async {
    await AwesomeNotifications().initialize(
      'resource://drawable/ic_launcher',
      [
        NotificationChannel(
          channelKey: 'corridas',
          channelName: 'Corridas',
          channelDescription: 'Notificações de corridas',
          defaultColor: const Color(0xFF1E88E5),
          ledColor: Colors.blue,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          playSound: true,
          enableVibration: true,
        ),
        NotificationChannel(
          channelKey: 'chat',
          channelName: 'Chat',
          channelDescription: 'Mensagens do chat',
          defaultColor: const Color(0xFF4CAF50),
          ledColor: Colors.green,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          playSound: true,
          enableVibration: true,
        ),
        NotificationChannel(
          channelKey: 'sistema',
          channelName: 'Sistema',
          channelDescription: 'Notificações do sistema',
          defaultColor: const Color(0xFFFF9800),
          ledColor: Colors.orange,
          importance: NotificationImportance.Default,
          channelShowBadge: true,
          playSound: false,
          enableVibration: false,
        ),
      ],
    );

    // Configurar listeners
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: _onActionReceived,
      onNotificationCreatedMethod: _onNotificationCreated,
      onNotificationDisplayedMethod: _onNotificationDisplayed,
      onDismissActionReceivedMethod: _onDismissActionReceived,
    );
  }

  /// Configurar Firebase Messaging
  static Future<void> _configurarFirebaseMessaging() async {
    // Configurar handlers
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);
    FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);

    // Verificar se app foi aberto por notificação
    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }
  }

  /// Salvar token FCM
  static Future<void> _salvarTokenFCM() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final token = await _messaging.getToken();
      if (token != null) {
        await _firestore.collection('motoristas').doc(user.uid).update({
          'fcmToken': token,
          'tokenAtualizadoEm': Timestamp.now(),
        });

        // Escutar mudanças no token
        _messaging.onTokenRefresh.listen((newToken) async {
          await _firestore.collection('motoristas').doc(user.uid).update({
            'fcmToken': newToken,
            'tokenAtualizadoEm': Timestamp.now(),
          });
        });
      }
    } catch (e) {
      print('❌ Erro ao salvar token FCM: $e');
    }
  }

  /// Enviar notificação para passageiro
  static Future<void> enviarNotificacaoPassageiro({
    required String corridaId,
    required String titulo,
    required String mensagem,
    required String tipo,
    Map<String, dynamic>? dados,
  }) async {
    try {
      // Obter dados da corrida
      final corridaDoc = await _firestore.collection('corridas').doc(corridaId).get();
      if (!corridaDoc.exists) return;

      final corridaData = corridaDoc.data()!;
      final passageiroId = corridaData['passageiroId'];

      // Obter token do passageiro
      final passageiroDoc = await _firestore.collection('passageiros').doc(passageiroId).get();
      if (!passageiroDoc.exists) return;

      final passageiroData = passageiroDoc.data()!;
      final fcmToken = passageiroData['fcmToken'];

      if (fcmToken != null) {
        // Enviar via FCM
        await _enviarFCM(
          token: fcmToken,
          titulo: titulo,
          mensagem: mensagem,
          dados: {
            'tipo': tipo,
            'corridaId': corridaId,
            ...?dados,
          },
        );
      }

      // Salvar notificação no banco
      await _salvarNotificacao(
        usuarioId: passageiroId,
        tipoUsuario: 'passageiro',
        titulo: titulo,
        mensagem: mensagem,
        tipo: tipo,
        dados: {
          'corridaId': corridaId,
          ...?dados,
        },
      );

      print('✅ Notificação enviada para passageiro');
    } catch (e) {
      print('❌ Erro ao enviar notificação para passageiro: $e');
    }
  }

  /// Enviar notificação para motorista
  static Future<void> enviarNotificacaoMotorista({
    required String motoristaId,
    required String titulo,
    required String mensagem,
    required String tipo,
    Map<String, dynamic>? dados,
  }) async {
    try {
      // Obter token do motorista
      final motoristaDoc = await _firestore.collection('motoristas').doc(motoristaId).get();
      if (!motoristaDoc.exists) return;

      final motoristaData = motoristaDoc.data()!;
      final fcmToken = motoristaData['fcmToken'];

      if (fcmToken != null) {
        // Enviar via FCM
        await _enviarFCM(
          token: fcmToken,
          titulo: titulo,
          mensagem: mensagem,
          dados: {
            'tipo': tipo,
            ...?dados,
          },
        );
      }

      // Salvar notificação no banco
      await _salvarNotificacao(
        usuarioId: motoristaId,
        tipoUsuario: 'motorista',
        titulo: titulo,
        mensagem: mensagem,
        tipo: tipo,
        dados: dados,
      );

      print('✅ Notificação enviada para motorista');
    } catch (e) {
      print('❌ Erro ao enviar notificação para motorista: $e');
    }
  }

  /// Mostrar notificação local
  static Future<void> mostrarNotificacaoLocal({
    required String titulo,
    required String mensagem,
    required String tipo,
    Map<String, dynamic>? dados,
  }) async {
    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
          channelKey: _getChannelKey(tipo),
          title: titulo,
          body: mensagem,
          bigPicture: _getBigPicture(tipo),
          notificationLayout: NotificationLayout.BigText,
          payload: dados != null ? Map<String, String>.from(dados.map((k, v) => MapEntry(k, v.toString()))) : null,
        ),
        actionButtons: _getActionButtons(tipo),
      );
    } catch (e) {
      print('❌ Erro ao mostrar notificação local: $e');
    }
  }

  /// Enviar mensagem de chat - BILATERAL
  static Future<void> enviarMensagemChat({
    required String corridaId,
    required String remetenteId,
    required String destinatarioId,
    required String tipoRemetente, // 'motorista' ou 'passageiro'
    required String mensagem,
    String? tipoMensagem = 'texto',
    String? anexo,
  }) async {
    try {
      // Salvar mensagem no chat
      await _firestore.collection('chats').doc(corridaId).collection('mensagens').add({
        'remetenteId': remetenteId,
        'destinatarioId': destinatarioId,
        'tipoRemetente': tipoRemetente,
        'mensagem': mensagem,
        'tipoMensagem': tipoMensagem,
        'anexo': anexo,
        'enviadaEm': Timestamp.now(),
        'lida': false,
      });

      // Atualizar último chat
      await _firestore.collection('chats').doc(corridaId).set({
        'corridaId': corridaId,
        'participantes': [remetenteId, destinatarioId],
        'ultimaMensagem': mensagem,
        'ultimoRemetente': remetenteId,
        'atualizadoEm': Timestamp.now(),
      }, SetOptions(merge: true));

      // Notificar destinatário
      final nomeRemetente = await _obterNomeUsuario(remetenteId, tipoRemetente);
      
      if (tipoRemetente == 'motorista') {
        await enviarNotificacaoPassageiro(
          corridaId: corridaId,
          titulo: 'Nova mensagem do motorista',
          mensagem: '$nomeRemetente: $mensagem',
          tipo: 'chat_mensagem',
          dados: {
            'remetenteId': remetenteId,
            'tipoRemetente': tipoRemetente,
          },
        );
      } else {
        await enviarNotificacaoMotorista(
          motoristaId: destinatarioId,
          titulo: 'Nova mensagem do passageiro',
          mensagem: '$nomeRemetente: $mensagem',
          tipo: 'chat_mensagem',
          dados: {
            'corridaId': corridaId,
            'remetenteId': remetenteId,
            'tipoRemetente': tipoRemetente,
          },
        );
      }

      print('✅ Mensagem de chat enviada');
    } catch (e) {
      print('❌ Erro ao enviar mensagem de chat: $e');
    }
  }

  /// Marcar mensagens como lidas
  static Future<void> marcarMensagensComoLidas(String corridaId, String usuarioId) async {
    try {
      final mensagens = await _firestore
          .collection('chats')
          .doc(corridaId)
          .collection('mensagens')
          .where('destinatarioId', isEqualTo: usuarioId)
          .where('lida', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (final doc in mensagens.docs) {
        batch.update(doc.reference, {'lida': true});
      }
      await batch.commit();

      print('✅ Mensagens marcadas como lidas');
    } catch (e) {
      print('❌ Erro ao marcar mensagens como lidas: $e');
    }
  }

  /// Obter histórico de notificações
  static Future<List<Map<String, dynamic>>> obterHistoricoNotificacoes() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final snapshot = await _firestore
          .collection('notificacoes')
          .where('usuarioId', isEqualTo: user.uid)
          .orderBy('criadaEm', descending: true)
          .limit(50)
          .get();

      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      print('❌ Erro ao obter histórico de notificações: $e');
      return [];
    }
  }

  /// Stream de mensagens de chat
  static Stream<List<Map<String, dynamic>>> streamMensagensChat(String corridaId) {
    return _firestore
        .collection('chats')
        .doc(corridaId)
        .collection('mensagens')
        .orderBy('enviadaEm', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => {
          'id': doc.id,
          ...doc.data(),
        }).toList());
  }

  /// Métodos privados auxiliares
  static Future<void> _enviarFCM({
    required String token,
    required String titulo,
    required String mensagem,
    Map<String, dynamic>? dados,
  }) async {
    // Implementar envio via FCM
    // Em produção, usar Firebase Admin SDK ou serviço de backend
    print('📤 Enviando FCM: $titulo - $mensagem');
  }

  static Future<void> _salvarNotificacao({
    required String usuarioId,
    required String tipoUsuario,
    required String titulo,
    required String mensagem,
    required String tipo,
    Map<String, dynamic>? dados,
  }) async {
    await _firestore.collection('notificacoes').add({
      'usuarioId': usuarioId,
      'tipoUsuario': tipoUsuario,
      'titulo': titulo,
      'mensagem': mensagem,
      'tipo': tipo,
      'dados': dados,
      'lida': false,
      'criadaEm': Timestamp.now(),
    });
  }

  static Future<String> _obterNomeUsuario(String usuarioId, String tipoUsuario) async {
    try {
      final doc = await _firestore.collection(tipoUsuario == 'motorista' ? 'motoristas' : 'passageiros').doc(usuarioId).get();
      return doc.data()?['nome'] ?? 'Usuário';
    } catch (e) {
      return 'Usuário';
    }
  }

  static String _getChannelKey(String tipo) {
    switch (tipo) {
      case 'corrida_aceita':
      case 'corrida_iniciada':
      case 'corrida_concluida':
      case 'corrida_cancelada':
        return 'corridas';
      case 'chat_mensagem':
        return 'chat';
      default:
        return 'sistema';
    }
  }

  static String? _getBigPicture(String tipo) {
    // Retornar URL da imagem baseada no tipo
    return null;
  }

  static List<NotificationActionButton>? _getActionButtons(String tipo) {
    switch (tipo) {
      case 'corrida_aceita':
        return [
          NotificationActionButton(
            key: 'ver_corrida',
            label: 'Ver Corrida',
            actionType: ActionType.Default,
          ),
        ];
      case 'chat_mensagem':
        return [
          NotificationActionButton(
            key: 'responder',
            label: 'Responder',
            actionType: ActionType.Default,
          ),
        ];
      default:
        return null;
    }
  }

  // Handlers de eventos
  static void _onNotificationTap(NotificationResponse response) {
    print('Notificação tocada: ${response.payload}');
    // Implementar navegação baseada no payload
  }

  static Future<void> _onActionReceived(ReceivedAction receivedAction) async {
    print('Ação recebida: ${receivedAction.buttonKeyPressed}');
    // Implementar ações dos botões
  }

  static Future<void> _onNotificationCreated(ReceivedNotification receivedNotification) async {
    print('Notificação criada: ${receivedNotification.title}');
  }

  static Future<void> _onNotificationDisplayed(ReceivedNotification receivedNotification) async {
    print('Notificação exibida: ${receivedNotification.title}');
  }

  static Future<void> _onDismissActionReceived(ReceivedAction receivedAction) async {
    print('Notificação dispensada: ${receivedAction.id}');
  }

  static Future<void> _onForegroundMessage(RemoteMessage message) async {
    print('Mensagem em foreground: ${message.notification?.title}');
    
    if (message.notification != null) {
      await mostrarNotificacaoLocal(
        titulo: message.notification!.title ?? '',
        mensagem: message.notification!.body ?? '',
        tipo: message.data['tipo'] ?? 'sistema',
        dados: message.data,
      );
    }
  }

  static Future<void> _onMessageOpenedApp(RemoteMessage message) async {
    print('App aberto por notificação: ${message.notification?.title}');
    _handleMessage(message);
  }

  static Future<void> _onBackgroundMessage(RemoteMessage message) async {
    print('Mensagem em background: ${message.notification?.title}');
  }

  static void _handleMessage(RemoteMessage message) {
    // Implementar navegação baseada no tipo de mensagem
    final tipo = message.data['tipo'];
    final corridaId = message.data['corridaId'];
    
    print('Handling message: $tipo, corridaId: $corridaId');
    // Navegar para tela apropriada
  }
}

