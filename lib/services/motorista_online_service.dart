import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'dart:async';

/// Serviço para gerenciar status online/offline do motorista - VERSÃO FINAL
class MotoristaOnlineService extends ChangeNotifier {
  // Singleton pattern
  static MotoristaOnlineService? _instance;
  static MotoristaOnlineService get instance => _instance ??= MotoristaOnlineService._();
  
  MotoristaOnlineService._();

  // Estado do serviço
  bool _isOnline = false;
  bool _isPaused = false;
  String? _currentUserId;
  Position? _currentPosition;
  Timer? _heartbeatTimer;
  Timer? _locationTimer;
  StreamSubscription<Position>? _positionStream;

  // Getters
  bool get isOnline => _isOnline;
  bool get isPaused => _isPaused;
  Position? get currentPosition => _currentPosition;
  String? get currentUserId => _currentUserId;

  /// STATUS PADRONIZADOS DO MOTORISTA:
  /// - 'offline': Motorista desconectado (não aparece no mapa/busca)
  /// - 'online': Motorista conectado e disponível para corridas
  /// - 'ocupado': Motorista em corrida (aparece no mapa mas não recebe novas corridas)
  /// - 'pausado': Motorista online mas pausado (aparece no mapa mas não recebe corridas)

  /// Inicializar serviço
  Future<void> initialize() async {
    print('🔄 MotoristaOnlineService: Inicializando...');
    
    // Obter usuário atual
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('❌ Usuário não autenticado');
      return;
    }
    
    _currentUserId = user.uid;
    print('✅ Usuário autenticado: $_currentUserId');
    
    // Verificar permissões de localização
    await _checkLocationPermissions();
    
    // Obter posição inicial (com timeout)
    await _getCurrentLocationWithTimeout();
    
    // Verificar status anterior no Firebase
    await _loadPreviousStatus();
    
    print('✅ MotoristaOnlineService inicializado');
  }

  /// Verificar e solicitar permissões de localização
  Future<void> _checkLocationPermissions() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      // Verificar se serviço de localização está habilitado
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('❌ Serviço de localização desabilitado');
        return;
      }

      // Verificar permissões
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('❌ Permissão de localização negada');
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        print('❌ Permissão de localização negada permanentemente');
        return;
      }

      print('✅ Permissões de localização OK');
    } catch (e) {
      print('❌ Erro ao verificar permissões: $e');
    }
  }

  /// Obter localização atual com timeout
  Future<void> _getCurrentLocationWithTimeout() async {
    try {
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 5), // Timeout de 5 segundos
      );
      print('📍 Localização obtida: ${_currentPosition?.latitude}, ${_currentPosition?.longitude}');
    } catch (e) {
      print('❌ Erro ao obter localização: $e');
      // Usar localização padrão (São Paulo) se não conseguir obter
      _currentPosition = Position(
        latitude: -23.5505,
        longitude: -46.6333,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );
      print('📍 Usando localização padrão: São Paulo');
    }
  }

  /// Carregar status anterior do Firebase
  Future<void> _loadPreviousStatus() async {
    if (_currentUserId == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('motoristas')
          .doc(_currentUserId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        final status = data['status'] as String?;
        
        // Verificar se estava online antes (mas não ocupado)
        if (status == 'online' || status == 'pausado') {
          _isOnline = true;
          _isPaused = status == 'pausado';
          print('🔄 Status anterior carregado: $status');
        }
      }
    } catch (e) {
      print('❌ Erro ao carregar status anterior: $e');
    }
  }

  /// Toggle status online/offline - MÉTODO COMPATÍVEL
  Future<void> toggleOnlineStatus() async {
    if (_isOnline) {
      await goOffline();
    } else {
      await goOnline();
    }
  }

  /// Ficar online
  Future<void> goOnline() async {
    if (_currentUserId == null) {
      print('❌ Usuário não autenticado');
      return;
    }

    try {
      print('🟢 Ficando online...');
      
      // Obter localização atual (com timeout)
      await _getCurrentLocationWithTimeout();
      
      if (_currentPosition == null) {
        print('❌ Não foi possível obter localização');
        return;
      }

      // Dados padronizados para salvar no Firebase
      final Map<String, dynamic> data = {
        // Status padronizado
        'status': 'online',
        'disponivel': true,
        'conectado': true,
        
        // Localização em formato objeto (compatível com app passageiro)
        'localizacao': {
          'latitude': _currentPosition!.latitude,
          'longitude': _currentPosition!.longitude,
        },
        
        // Localização em campos separados (compatibilidade)
        'latitude': _currentPosition!.latitude,
        'longitude': _currentPosition!.longitude,
        
        // Timestamps
        'ultimaAtualizacao': FieldValue.serverTimestamp(),
        'ultimaLocalizacao': FieldValue.serverTimestamp(),
        
        // Dados de controle
        'corridaAtual': null, // Limpa corrida atual ao ficar online
        'versaoApp': '1.0.0',
      };

      // Salvar no Firebase
      await FirebaseFirestore.instance
          .collection('motoristas')
          .doc(_currentUserId!)
          .update(data);

      // Atualizar estado local
      _isOnline = true;
      _isPaused = false;
      
      // Iniciar monitoramento
      _startLocationTracking();
      _startHeartbeat();
      
      // Notificar listeners
      notifyListeners();
      
      print('✅ Motorista online com sucesso');

    } catch (e) {
      print('❌ Erro ao ficar online: $e');
      rethrow;
    }
  }

  /// Ficar offline
  Future<void> goOffline() async {
    if (_currentUserId == null) return;

    try {
      print('🔴 Ficando offline...');

      // Dados para marcar como offline
      final Map<String, dynamic> data = {
        // Status padronizado
        'status': 'offline',
        'disponivel': false,
        'conectado': false,
        
        // Timestamps
        'ultimaAtualizacao': FieldValue.serverTimestamp(),
        'dataHoraOffline': FieldValue.serverTimestamp(),
        
        // Limpeza de dados
        'corridaAtual': null,
      };

      // Salvar no Firebase
      await FirebaseFirestore.instance
          .collection('motoristas')
          .doc(_currentUserId!)
          .update(data);

      // Atualizar estado local
      _isOnline = false;
      _isPaused = false;
      
      // Parar monitoramento
      _stopLocationTracking();
      _stopHeartbeat();
      
      // Notificar listeners
      notifyListeners();
      
      print('✅ Motorista offline com sucesso');

    } catch (e) {
      print('❌ Erro ao ficar offline: $e');
    }
  }

  /// Pausar/Despausar (online mas não recebe corridas)
  Future<void> togglePause() async {
    if (!_isOnline || _currentUserId == null) return;

    try {
      _isPaused = !_isPaused;
      
      final status = _isPaused ? 'pausado' : 'online';
      print('⏸️ Alterando para: $status');

      // Atualizar no Firebase
      await FirebaseFirestore.instance
          .collection('motoristas')
          .doc(_currentUserId!)
          .update({
        'status': status,
        'disponivel': !_isPaused, // Disponível apenas se não pausado
        'ultimaAtualizacao': FieldValue.serverTimestamp(),
      });

      // Notificar listeners
      notifyListeners();
      
      print('✅ Status alterado para: $status');

    } catch (e) {
      print('❌ Erro ao alterar status de pausa: $e');
    }
  }

  /// Marcar como ocupado (em corrida)
  Future<void> setOccupied(String corridaId) async {
    if (_currentUserId == null) return;

    try {
      print('🚗 Marcando como ocupado - Corrida: $corridaId');

      await FirebaseFirestore.instance
          .collection('motoristas')
          .doc(_currentUserId!)
          .update({
        'status': 'ocupado',
        'disponivel': false,
        'corridaAtual': corridaId,
        'ultimaAtualizacao': FieldValue.serverTimestamp(),
      });

      print('✅ Motorista marcado como ocupado');

    } catch (e) {
      print('❌ Erro ao marcar como ocupado: $e');
    }
  }

  /// Voltar para disponível (após corrida)
  Future<void> setAvailable() async {
    if (_currentUserId == null) return;

    try {
      print('✅ Voltando para disponível');

      await FirebaseFirestore.instance
          .collection('motoristas')
          .doc(_currentUserId!)
          .update({
        'status': 'online',
        'disponivel': true,
        'corridaAtual': null,
        'ultimaAtualizacao': FieldValue.serverTimestamp(),
      });

      print('✅ Motorista disponível novamente');

    } catch (e) {
      print('❌ Erro ao voltar para disponível: $e');
    }
  }

  /// Iniciar rastreamento de localização
  void _startLocationTracking() {
    _stopLocationTracking(); // Para qualquer rastreamento anterior
    
    print('📍 Iniciando rastreamento de localização...');
    
    // Atualizar localização a cada 15 segundos (reduzido para evitar timeout)
    _locationTimer = Timer.periodic(Duration(seconds: 15), (timer) {
      _updateLocation();
    });
  }

  /// Parar rastreamento de localização
  void _stopLocationTracking() {
    _locationTimer?.cancel();
    _locationTimer = null;
    
    _positionStream?.cancel();
    _positionStream = null;
    
    print('📍 Rastreamento de localização parado');
  }

  /// Atualizar localização
  Future<void> _updateLocation() async {
    if (!_isOnline || _currentUserId == null) return;

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium, // Reduzido para medium
        timeLimit: Duration(seconds: 3), // Timeout reduzido
      );
      
      _currentPosition = position;
      await _updateLocationInFirebase(position);
      
    } catch (e) {
      print('❌ Erro ao atualizar localização: $e');
      // Continuar com a última posição conhecida
    }
  }

  /// Atualizar localização no Firebase
  Future<void> _updateLocationInFirebase(Position position) async {
    if (_currentUserId == null) return;

    try {
      // Dados de localização padronizados
      final Map<String, dynamic> locationData = {
        // Localização em formato objeto (compatível com app passageiro)
        'localizacao': {
          'latitude': position.latitude,
          'longitude': position.longitude,
        },
        
        // Localização em campos separados (compatibilidade)
        'latitude': position.latitude,
        'longitude': position.longitude,
        
        // Timestamps
        'ultimaLocalizacao': FieldValue.serverTimestamp(),
        'ultimaAtualizacao': FieldValue.serverTimestamp(),
        
        // Dados adicionais de localização
        'precisao': position.accuracy,
        'velocidade': position.speed,
        'direcao': position.heading,
      };

      await FirebaseFirestore.instance
          .collection('motoristas')
          .doc(_currentUserId!)
          .update(locationData);

    } catch (e) {
      print('❌ Erro ao atualizar localização no Firebase: $e');
    }
  }

  /// Iniciar heartbeat para manter conexão ativa
  void _startHeartbeat() {
    _stopHeartbeat(); // Para qualquer heartbeat anterior
    
    print('💓 Iniciando heartbeat...');
    
    // Heartbeat a cada 30 segundos
    _heartbeatTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      _sendHeartbeat();
    });
  }

  /// Parar heartbeat
  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    print('💓 Heartbeat parado');
  }

  /// Enviar heartbeat
  Future<void> _sendHeartbeat() async {
    if (!_isOnline || _currentUserId == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('motoristas')
          .doc(_currentUserId!)
          .update({
        'ultimaAtualizacao': FieldValue.serverTimestamp(),
        'heartbeat': FieldValue.serverTimestamp(),
      });

    } catch (e) {
      print('❌ Erro no heartbeat: $e');
    }
  }

  /// Limpar recursos ao sair do app
  @override
  void dispose() {
    print('🔄 MotoristaOnlineService: Finalizando...');
    
    // Marcar como offline
    goOffline();
    
    // Parar todos os timers e streams
    _stopLocationTracking();
    _stopHeartbeat();
    
    // Limpar dados
    _currentUserId = null;
    _currentPosition = null;
    _isOnline = false;
    _isPaused = false;
    
    super.dispose();
  }

  /// Obter status atual como string
  String getCurrentStatus() {
    if (!_isOnline) return 'offline';
    if (_isPaused) return 'pausado';
    return 'online';
  }

  /// Verificar se está disponível para corridas
  bool isAvailableForRides() {
    return _isOnline && !_isPaused;
  }
}

