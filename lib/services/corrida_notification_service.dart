import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../widgets/corrida_popup_widget.dart';
import 'sound_service.dart';
import 'overlay_service.dart';

class CorridaNotificationService {
  static CorridaNotificationService? _instance;
  static CorridaNotificationService get instance => _instance ??= CorridaNotificationService._();
  
  CorridaNotificationService._();

  StreamSubscription<QuerySnapshot>? _notificacoesSubscription;
  BuildContext? _context;
  bool _isListening = false;
  bool _isOnline = false;
  String? _currentMotoristaId;
  Timer? _heartbeatTimer;

  // Inicializar o serviço
  void initialize(BuildContext context) {
    _context = context;
    _currentMotoristaId = FirebaseAuth.instance.currentUser?.uid;
    
    print('🚗 CorridaNotificationService: Inicializando para motorista $_currentMotoristaId');
    
    if (_currentMotoristaId != null) {
      // Verificar e solicitar permissões de overlay
      _checkOverlayPermissions();
      
      // Verificar notificações pendentes ao inicializar
      _checkPendingNotifications();
      
      // Iniciar heartbeat para manter motorista ativo
      _startHeartbeat();
    }
  }

  // Parar o serviço
  void dispose() {
    print('🚗 CorridaNotificationService: Finalizando serviço');
    _stopListening();
    _stopHeartbeat();
    _context = null;
    _currentMotoristaId = null;
    _isOnline = false;
  }

  // Verificar permissões de overlay
  Future<void> _checkOverlayPermissions() async {
    try {
      final hasPermission = await OverlayService.checkOverlayPermission();
      if (!hasPermission) {
        print('⚠️ Permissão de overlay não concedida, solicitando...');
        await OverlayService.requestOverlayPermission();
      } else {
        print('✅ Permissão de overlay já concedida');
      }
    } catch (e) {
      print('❌ Erro ao verificar permissões de overlay: $e');
    }
  }

  // Atualizar status online/offline
  void updateOnlineStatus(bool isOnline) {
    print('🚗 CorridaNotificationService: Status alterado para ${isOnline ? "ONLINE" : "OFFLINE"}');
    
    _isOnline = isOnline;
    
    if (isOnline && !_isListening && _currentMotoristaId != null) {
      _startListening();
      _updateMotoristaStatus(true);
    } else if (!isOnline && _isListening) {
      _stopListening();
      _updateMotoristaStatus(false);
    }
  }

  // Verificar notificações pendentes
  Future<void> _checkPendingNotifications() async {
    if (_currentMotoristaId == null) return;

    try {
      print('🔍 Verificando notificações pendentes...');
      
      final snapshot = await FirebaseFirestore.instance
          .collection('notificacoes_motorista')
          .where('motoristaId', isEqualTo: _currentMotoristaId)
          .where('lida', isEqualTo: false)
          .where('tipo', isEqualTo: 'nova_corrida')
          .orderBy('criadaEm', descending: true)
          .limit(5)
          .get();

      if (snapshot.docs.isNotEmpty) {
        print('📱 Encontradas ${snapshot.docs.length} notificações pendentes');
        
        // Processar apenas a mais recente se motorista estiver online
        if (_isOnline && snapshot.docs.isNotEmpty) {
          final doc = snapshot.docs.first;
          final data = doc.data();
          final corridaId = data['corridaId'] as String?;
          
          if (corridaId != null) {
            // Verificar se a corrida ainda está disponível
            final corridaDoc = await FirebaseFirestore.instance
                .collection('corridas')
                .doc(corridaId)
                .get();
                
            if (corridaDoc.exists) {
              final corridaData = corridaDoc.data()!;
              if (corridaData['status'] == 'pendente' && 
                  (corridaData['motoristaId'] == null || corridaData['motoristaId'] == '')) {
                await _showCorridaPopup(corridaId, doc.id);
              } else {
                // Marcar como lida se não está mais disponível
                await _marcarNotificacaoComoLida(doc.id);
              }
            }
          }
        }
      } else {
        print('📱 Nenhuma notificação pendente encontrada');
      }
    } catch (e) {
      print('❌ Erro ao verificar notificações pendentes: $e');
    }
  }

  // Iniciar monitoramento em tempo real
  void _startListening() {
    if (_isListening || _currentMotoristaId == null) return;
    
    _isListening = true;
    
    print('🎧 Iniciando monitoramento de notificações em tempo real...');
    
    // Monitorar notificações específicas para este motorista
    _notificacoesSubscription = FirebaseFirestore.instance
        .collection('notificacoes_motorista')
        .where('motoristaId', isEqualTo: _currentMotoristaId)
        .where('lida', isEqualTo: false)
        .where('tipo', isEqualTo: 'nova_corrida')
        .orderBy('criadaEm', descending: true)
        .snapshots()
        .listen(
          _onNotificacaoReceived,
          onError: (error) {
            print('❌ Erro no monitoramento de notificações: $error');
            // Tentar reconectar após erro
            Timer(Duration(seconds: 5), () {
              if (_isOnline && !_isListening) {
                _startListening();
              }
            });
          },
        );

    print('✅ Monitoramento iniciado para motorista $_currentMotoristaId');
  }

  // Parar monitoramento
  void _stopListening() {
    _notificacoesSubscription?.cancel();
    _notificacoesSubscription = null;
    _isListening = false;
    
    print('🛑 Monitoramento de notificações parado');
  }

  // Quando recebe notificação em tempo real
  void _onNotificacaoReceived(QuerySnapshot snapshot) {
    print('📨 Recebida atualização de notificações: ${snapshot.docChanges.length} mudanças');
    
    for (var change in snapshot.docChanges) {
      if (change.type == DocumentChangeType.added) {
        final data = change.doc.data() as Map<String, dynamic>;
        final corridaId = data['corridaId'] as String?;
        final criadaEm = data['criadaEm'] as Timestamp?;
        
        print('🆕 Nova notificação recebida para corrida: $corridaId');
        
        if (corridaId != null && _isOnline) {
          // Verificar se é uma notificação realmente nova (últimos 30 segundos)
          if (criadaEm != null) {
            final agora = DateTime.now();
            final criadaEmDateTime = criadaEm.toDate();
            final diferenca = agora.difference(criadaEmDateTime);
            
            if (diferenca.inSeconds <= 30) {
              print('✨ Notificação é recente, mostrando popup...');
              _showCorridaPopup(corridaId, change.doc.id);
            } else {
              print('⏰ Notificação é antiga (${diferenca.inSeconds}s), ignorando...');
            }
          } else {
            // Se não tem timestamp, mostrar mesmo assim
            _showCorridaPopup(corridaId, change.doc.id);
          }
        }
      }
    }
  }

  // Mostrar popup da corrida
  Future<void> _showCorridaPopup(String corridaId, String notificacaoId) async {
    if (_context == null || !_context!.mounted) {
      print('❌ Contexto não disponível para mostrar popup');
      return;
    }

    try {
      print('🎯 Buscando dados da corrida $corridaId...');
      
      // Buscar dados da corrida
      final corridaDoc = await FirebaseFirestore.instance
          .collection('corridas')
          .doc(corridaId)
          .get();

      if (!corridaDoc.exists) {
        print('❌ Corrida $corridaId não encontrada');
        await _marcarNotificacaoComoLida(notificacaoId);
        return;
      }

      final corridaData = corridaDoc.data()!;
      
      // Verificar se a corrida ainda está disponível
      if (corridaData['status'] != 'pendente' || 
          (corridaData['motoristaId'] != null && corridaData['motoristaId'] != '')) {
        print('⚠️ Corrida $corridaId não está mais disponível (status: ${corridaData['status']}, motorista: ${corridaData['motoristaId']})');
        await _marcarNotificacaoComoLida(notificacaoId);
        return;
      }

      print('🎉 Mostrando popup para corrida $corridaId');

      // CONFIGURAR OVERLAY PARA APARECER SOBRE TUDO
      await OverlayService.bringAppToForeground();

      // Tocar som de nova corrida
      await SoundService.playNewRideSound();
      
      // Vibrar o dispositivo
      HapticFeedback.heavyImpact();

      // Mostrar popup sobrepondo tudo - CONFIGURAÇÃO CRÍTICA
      if (_context != null && _context!.mounted) {
        showDialog(
          context: _context!,
          barrierDismissible: false, // Não pode fechar clicando fora
          barrierColor: Colors.black87, // Fundo escuro para destacar
          useRootNavigator: true, // Usa navegador raiz para sobrepor tudo
          builder: (context) => WillPopScope(
            onWillPop: () async => false, // Impede fechar com botão voltar
            child: Material(
              type: MaterialType.transparency,
              child: CorridaPopupWidget(
                corridaId: corridaId,
                corridaData: corridaData,
                notificacaoId: notificacaoId,
                onAceitar: () => _aceitarCorrida(corridaId, notificacaoId),
                onRecusar: () => _recusarCorrida(corridaId, notificacaoId),
              ),
            ),
          ),
        );
      }
    } catch (e) {
      print('❌ Erro ao mostrar popup da corrida: $e');
      await _marcarNotificacaoComoLida(notificacaoId);
    }
  }

  // Aceitar corrida
  Future<void> _aceitarCorrida(String corridaId, String notificacaoId) async {
    try {
      if (_currentMotoristaId == null) {
        print('❌ ID do motorista não disponível');
        return;
      }

      print('✅ Aceitando corrida $corridaId...');

      // Verificar se a corrida ainda está disponível antes de aceitar
      final corridaDoc = await FirebaseFirestore.instance
          .collection('corridas')
          .doc(corridaId)
          .get();

      if (!corridaDoc.exists) {
        _showErrorMessage('Corrida não encontrada');
        return;
      }

      final corridaData = corridaDoc.data()!;
      if (corridaData['status'] != 'pendente' || 
          (corridaData['motoristaId'] != null && corridaData['motoristaId'] != '')) {
        _showErrorMessage('Corrida não está mais disponível');
        await _marcarNotificacaoComoLida(notificacaoId);
        return;
      }

      // Atualizar corrida no Firebase usando transação para evitar conflitos
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final corridaRef = FirebaseFirestore.instance.collection('corridas').doc(corridaId);
        final corridaSnapshot = await transaction.get(corridaRef);
        
        if (!corridaSnapshot.exists) {
          throw Exception('Corrida não encontrada');
        }
        
        final data = corridaSnapshot.data()!;
        if (data['status'] != 'pendente' || 
            (data['motoristaId'] != null && data['motoristaId'] != '')) {
          throw Exception('Corrida não está mais disponível');
        }
        
        transaction.update(corridaRef, {
          'motoristaId': _currentMotoristaId,
          'status': 'aceita',
          'aceitaEm': FieldValue.serverTimestamp(),
          'atualizadaEm': FieldValue.serverTimestamp(),
        });
      });

      // Marcar notificação como lida
      await _marcarNotificacaoComoLida(notificacaoId);

      // Tocar som de sucesso
      await SoundService.playRideAcceptedSound();

      // Fechar popup
      if (_context != null && _context!.mounted) {
        Navigator.of(_context!).pop();
      }

      // Mostrar confirmação
      _showSuccessMessage('Corrida aceita com sucesso!');

      print('🎉 Corrida $corridaId aceita pelo motorista $_currentMotoristaId');
    } catch (e) {
      print('❌ Erro ao aceitar corrida: $e');
      
      // Fechar popup em caso de erro
      if (_context != null && _context!.mounted) {
        Navigator.of(_context!).pop();
      }
      
      if (e.toString().contains('não está mais disponível')) {
        _showErrorMessage('Corrida não está mais disponível');
      } else {
        _showErrorMessage('Erro ao aceitar corrida. Tente novamente.');
      }
    }
  }

  // Recusar corrida
  Future<void> _recusarCorrida(String corridaId, String notificacaoId) async {
    try {
      print('❌ Recusando corrida $corridaId...');
      
      // Marcar notificação como lida
      await _marcarNotificacaoComoLida(notificacaoId);

      // Adicionar motorista à lista de rejeitados
      await FirebaseFirestore.instance.collection('corridas').doc(corridaId).update({
        'motoristasRejeitados': FieldValue.arrayUnion([_currentMotoristaId]),
        'atualizadaEm': FieldValue.serverTimestamp(),
      });

      // Tocar som de recusa
      await SoundService.playCancelSound();

      // Fechar popup
      if (_context != null && _context!.mounted) {
        Navigator.of(_context!).pop();
      }

      print('✅ Corrida $corridaId recusada pelo motorista $_currentMotoristaId');
    } catch (e) {
      print('❌ Erro ao recusar corrida: $e');
      
      // Fechar popup mesmo com erro
      if (_context != null && _context!.mounted) {
        Navigator.of(_context!).pop();
      }
    }
  }

  // Marcar notificação como lida
  Future<void> _marcarNotificacaoComoLida(String notificacaoId) async {
    try {
      await FirebaseFirestore.instance
          .collection('notificacoes_motorista')
          .doc(notificacaoId)
          .update({
        'lida': true,
        'lidaEm': FieldValue.serverTimestamp(),
      });
      print('✅ Notificação $notificacaoId marcada como lida');
    } catch (e) {
      print('❌ Erro ao marcar notificação como lida: $e');
    }
  }

  // Atualizar status do motorista no Firebase
  Future<void> _updateMotoristaStatus(bool isOnline) async {
    if (_currentMotoristaId == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('motoristas')
          .doc(_currentMotoristaId)
          .set({
        'status': isOnline ? 'online' : 'offline',
        'ultimaAtualizacao': FieldValue.serverTimestamp(),
        'corridaAtiva': null, // Reset corrida ativa
      }, SetOptions(merge: true));
      
      print('📍 Status do motorista atualizado: ${isOnline ? "ONLINE" : "OFFLINE"}');
    } catch (e) {
      print('❌ Erro ao atualizar status do motorista: $e');
    }
  }

  // Iniciar heartbeat para manter motorista ativo
  void _startHeartbeat() {
    _heartbeatTimer = Timer.periodic(Duration(minutes: 1), (timer) {
      if (_isOnline && _currentMotoristaId != null) {
        _updateMotoristaStatus(true);
      }
    });
  }

  // Parar heartbeat
  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  // Mostrar mensagem de sucesso
  void _showSuccessMessage(String message) {
    if (_context != null && _context!.mounted) {
      ScaffoldMessenger.of(_context!).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  // Mostrar mensagem de erro
  void _showErrorMessage(String message) {
    if (_context != null && _context!.mounted) {
      ScaffoldMessenger.of(_context!).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  // Getters para debug
  bool get isListening => _isListening;
  bool get isOnline => _isOnline;
  String? get currentMotoristaId => _currentMotoristaId;
  
  // Método para debug
  void printStatus() {
    print('🚗 CorridaNotificationService Status:');
    print('   - Motorista ID: $_currentMotoristaId');
    print('   - Online: $_isOnline');
    print('   - Listening: $_isListening');
    print('   - Context: ${_context != null ? "Available" : "Null"}');
  }
}

