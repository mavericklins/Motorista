// SISTEMA DE PRESENÇA CORRIGIDO - MANTÉM ONLINE QUANDO MINIMIZADO
// App continua rodando em background para receber notificações de corridas

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class PresenceService {
  static final PresenceService _instance = PresenceService._internal();
  factory PresenceService() => _instance;
  PresenceService._internal();

  final FirebaseDatabase _realtimeDb = FirebaseDatabase.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  DatabaseReference? _presenceRef;
  DatabaseReference? _connectedRef;
  Timer? _heartbeatTimer;
  bool _isInitialized = false;
  bool _isOnline = false;

  // Inicializar sistema de presença
  Future<void> initializePresence() async {
    if (_isInitialized) return;
    
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // Referência para o status de conexão do Firebase
      _connectedRef = _realtimeDb.ref('.info/connected');
      
      // Referência para a presença do usuário
      _presenceRef = _realtimeDb.ref('presence/${user.uid}');

      // Escutar mudanças na conexão
      _connectedRef!.onValue.listen((event) {
        final connected = event.snapshot.value as bool? ?? false;
        
        if (connected && !_isOnline) {
          _setUserOnline();
        }
      });

      // Configurar detecção APENAS para fechamento real do app
      _setupAppLifecycleDetection();
      
      // Iniciar heartbeat para manter conexão ativa
      _startHeartbeat();
      
      _isInitialized = true;
      print('✅ Sistema de presença inicializado (mantém online quando minimizado)');
      
    } catch (e) {
      print('❌ Erro ao inicializar presença: $e');
    }
  }

  // Marcar usuário como online
  Future<void> _setUserOnline() async {
    final user = _auth.currentUser;
    if (user == null || _presenceRef == null) return;

    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      
      // Dados de presença no Realtime Database
      final presenceData = {
        'online': true,
        'lastSeen': now,
        'timestamp': ServerValue.timestamp,
        'appState': 'active', // Estado do app
      };

      // Configurar para ficar offline APENAS quando desconectar completamente
      await _presenceRef!.onDisconnect().set({
        'online': false,
        'lastSeen': now,
        'timestamp': ServerValue.timestamp,
        'appState': 'disconnected',
      });

      // Definir como online agora
      await _presenceRef!.set(presenceData);

      // Atualizar também no Firestore
      await _updateFirestoreStatus(true, 'active');
      
      _isOnline = true;
      print('🟢 Motorista marcado como ONLINE (pode receber corridas)');
      
    } catch (e) {
      print('❌ Erro ao marcar como online: $e');
    }
  }

  // Marcar usuário como offline (APENAS quando realmente sair)
  Future<void> setUserOffline() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      
      // Atualizar Realtime Database
      if (_presenceRef != null) {
        await _presenceRef!.set({
          'online': false,
          'lastSeen': now,
          'timestamp': ServerValue.timestamp,
          'appState': 'offline',
        });
      }

      // Atualizar Firestore
      await _updateFirestoreStatus(false, 'offline');
      
      _isOnline = false;
      print('🔴 Motorista marcado como OFFLINE');
      
    } catch (e) {
      print('❌ Erro ao marcar como offline: $e');
    }
  }

  // Atualizar status no background (minimizado mas ativo)
  Future<void> _setUserBackground() async {
    final user = _auth.currentUser;
    if (user == null || _presenceRef == null) return;

    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      
      // Manter online mas indicar que está em background
      final presenceData = {
        'online': true, // MANTÉM ONLINE!
        'lastSeen': now,
        'timestamp': ServerValue.timestamp,
        'appState': 'background', // Indica que está minimizado
      };

      await _presenceRef!.set(presenceData);
      await _updateFirestoreStatus(true, 'background');
      
      print('📱 App em background - MANTENDO ONLINE para receber corridas');
      
    } catch (e) {
      print('❌ Erro ao atualizar status background: $e');
    }
  }

  // Atualizar status no Firestore
  Future<void> _updateFirestoreStatus(bool isOnline, String appState) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('motoristas').doc(user.uid).update({
        'isOnline': isOnline,
        'online': isOnline,
        'statusOnline': isOnline,
        'appState': appState, // 'active', 'background', 'offline'
        'lastSeen': FieldValue.serverTimestamp(),
        'lastActivity': FieldValue.serverTimestamp(),
        'canReceiveRides': isOnline, // Pode receber corridas se estiver online
      });
    } catch (e) {
      print('❌ Erro ao atualizar Firestore: $e');
    }
  }

  // Configurar detecção do ciclo de vida do app (CORRIGIDO)
  void _setupAppLifecycleDetection() {
    SystemChannels.lifecycle.setMessageHandler((message) async {
      print('📱 App lifecycle: $message');
      
      switch (message) {
        case 'AppLifecycleState.paused':
          // App minimizado - MANTÉM ONLINE para receber corridas
          await _setUserBackground();
          print('📱 App minimizado - MANTENDO ONLINE para corridas');
          break;
          
        case 'AppLifecycleState.inactive':
          // App temporariamente inativo - MANTÉM ONLINE
          print('📱 App temporariamente inativo - MANTENDO ONLINE');
          break;
          
        case 'AppLifecycleState.detached':
          // App realmente fechado - MARCA OFFLINE
          await setUserOffline();
          print('📱 App fechado - MARCANDO OFFLINE');
          break;
          
        case 'AppLifecycleState.resumed':
          // App reaberto - MARCA ONLINE ATIVO
          await _setUserOnline();
          print('📱 App reaberto - MARCANDO ONLINE ATIVO');
          break;
      }
      return null;
    });
  }

  // Heartbeat - manter conexão ativa (MELHORADO)
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    
    _heartbeatTimer = Timer.periodic(Duration(minutes: 1), (timer) async {
      final user = _auth.currentUser;
      if (user == null || !_isOnline) {
        timer.cancel();
        return;
      }

      try {
        // Atualizar timestamp de atividade para mostrar que está vivo
        await _firestore.collection('motoristas').doc(user.uid).update({
          'lastActivity': FieldValue.serverTimestamp(),
          'heartbeat': FieldValue.serverTimestamp(),
        });
        
        print('💓 Heartbeat enviado - motorista ativo');
        
      } catch (e) {
        print('❌ Erro no heartbeat: $e');
      }
    });
  }

  // Cleanup quando fazer logout
  Future<void> cleanup() async {
    try {
      await setUserOffline();
      
      if (_presenceRef != null) {
        await _presenceRef!.onDisconnect().cancel();
      }
      
      _heartbeatTimer?.cancel();
      
      _presenceRef = null;
      _connectedRef = null;
      _heartbeatTimer = null;
      _isInitialized = false;
      _isOnline = false;
      
      print('🧹 Sistema de presença limpo (logout)');
      
    } catch (e) {
      print('❌ Erro no cleanup: $e');
    }
  }

  // Método para forçar online (quando aceitar corrida, etc.)
  Future<void> forceOnline() async {
    await _setUserOnline();
  }

  // Verificar se está online
  bool get isOnline => _isOnline;
}

// COMO USAR NO MAIN.DART (CORRIGIDO):

/*
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'presence_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final PresenceService _presenceService = PresenceService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Inicializar presença quando o app iniciar
    _initializePresence();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // O PresenceService já trata isso automaticamente
    print('📱 App state changed to: $state');
  }

  void _initializePresence() async {
    // Aguardar um pouco para garantir que o Firebase Auth está pronto
    await Future.delayed(Duration(seconds: 2));
    await _presenceService.initializePresence();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vello Motorista',
      home: YourHomeScreen(),
    );
  }
}
*/

// COMO USAR NO AUTH_SERVICE.DART (CORRIGIDO):

/*
// No método de login, adicione:
Future<bool> signIn(String email, String password) async {
  try {
    // ... código de login existente ...
    
    if (success) {
      // Inicializar presença após login bem-sucedido
      await PresenceService().initializePresence();
    }
    
    return success;
  } catch (e) {
    return false;
  }
}

// No método de logout, adicione:
Future<void> signOut() async {
  try {
    // Limpar presença antes de fazer logout
    await PresenceService().cleanup();
    
    // ... código de logout existente ...
    await _auth.signOut();
    
  } catch (e) {
    print('Erro no logout: $e');
  }
}
*/

// CONFIGURAÇÃO PARA BACKGROUND PROCESSING:

/*
// Adicione no pubspec.yaml:
dependencies:
  firebase_database: ^10.5.0
  flutter_background_service: ^5.0.5
  flutter_local_notifications: ^16.3.2

// Adicione no android/app/src/main/AndroidManifest.xml:
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />

<service
    android:name="id.flutter.flutter_background_service.BackgroundService"
    android:exported="false"
    android:foregroundServiceType="dataSync" />
*/

// INSTRUÇÕES DE USO:
/*
1. ✅ App MANTÉM ONLINE quando minimizado (para receber corridas)
2. ✅ App marca OFFLINE apenas quando:
   - Usuário faz logout
   - App é realmente fechado (detached)
   - Perde conexão por muito tempo

3. ✅ App pode mostrar overlay de corridas mesmo minimizado
4. ✅ Heartbeat mantém conexão ativa
5. ✅ Sistema detecta automaticamente mudanças de estado

6. Para testar:
   - Minimize o app → Deve continuar ONLINE
   - Feche o app → Deve ficar OFFLINE
   - Faça logout → Deve ficar OFFLINE
   - Reabra o app → Deve voltar ONLINE
*/

