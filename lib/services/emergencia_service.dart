
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:camera/camera.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import 'dart:io';
import '../services/sound_service.dart';

class EmergenciaService extends ChangeNotifier {
  static final EmergenciaService _instance = EmergenciaService._internal();
  factory EmergenciaService() => _instance;
  EmergenciaService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _emergenciaAtiva = false;
  bool _gravacaoAtiva = false;
  bool _monitoramentoAtivo = false;
  List<Map<String, dynamic>> _contatosEmergencia = [];
  CameraController? _cameraController;
  StreamSubscription<AccelerometerEvent>? _acelerometerSubscription;
  Timer? _timerEmergencia;

  // Configurações de detecção
  double _limiteAceleracao = 15.0; // m/s² para detecção de impacto
  int _tempoSemResposta = 30; // segundos

  // Getters
  bool get emergenciaAtiva => _emergenciaAtiva;
  bool get gravacaoAtiva => _gravacaoAtiva;
  bool get monitoramentoAtivo => _monitoramentoAtivo;
  List<Map<String, dynamic>> get contatosEmergencia => _contatosEmergencia;

  // Inicializar serviço
  Future<void> inicializar() async {
    await _carregarContatosEmergencia();
    await _configurarSensores();
    await _configurarCamera();
    _iniciarMonitoramento();
  }

  // Ativar emergência manual
  Future<void> ativarEmergencia({String? motivo}) async {
    if (_emergenciaAtiva) return;

    try {
      _emergenciaAtiva = true;
      notifyListeners();

      // Som de emergência
      await SoundService.playNotificationSound();

      // Obter localização atual
      final posicao = await _obterLocalizacaoAtual();

      // Criar alerta de emergência
      final alertaId = await _criarAlertaEmergencia(motivo ?? 'Emergência ativada manualmente', posicao);

      // Iniciar gravação automática
      await _iniciarGravacaoEmergencia();

      // Compartilhar localização
      await _compartilharLocalizacao(alertaId, posicao);

      // Notificar contatos
      await _notificarContatosEmergencia(alertaId, posicao, motivo);

      // Configurar timer de emergência
      _configurarTimerEmergencia(alertaId);

    } catch (e) {
      print('Erro ao ativar emergência: $e');
      _emergenciaAtiva = false;
      notifyListeners();
    }
  }

  // Desativar emergência
  Future<void> desativarEmergencia() async {
    if (!_emergenciaAtiva) return;

    try {
      _emergenciaAtiva = false;
      _timerEmergencia?.cancel();

      await _pararGravacaoEmergencia();
      await _finalizarAlertaEmergencia();

      notifyListeners();
    } catch (e) {
      print('Erro ao desativar emergência: $e');
    }
  }

  // Configurar sensores para detecção automática
  Future<void> _configurarSensores() async {
    try {
      var status = await Permission.sensors.request();

      if (status == PermissionStatus.granted) {
        // Monitorar acelerômetro para detectar impactos
        _acelerometerSubscription = accelerometerEvents.listen((event) {
          _verificarImpacto(event);
        });
      }
    } catch (e) {
      print('Erro ao configurar sensores: $e');
    }
  }

  // Verificar impacto através do acelerômetro
  void _verificarImpacto(AccelerometerEvent event) {
    if (!_monitoramentoAtivo) return;

    final forcaTotal = (event.x.abs() + event.y.abs() + event.z.abs());

    if (forcaTotal > _limiteAceleracao) {
      print('Impacto detectado: $forcaTotal m/s²');
      _detectarEmergenciaAutomatica('Impacto detectado pelos sensores');
    }
  }

  // Detectar emergência automática
  Future<void> _detectarEmergenciaAutomatica(String motivo) async {
    if (_emergenciaAtiva) return;

    // Mostrar alerta de confirmação por alguns segundos
    _mostrarAlertaConfirmacao(motivo);
  }

  // Mostrar alerta de confirmação
  void _mostrarAlertaConfirmacao(String motivo) {
    // Timer de 10 segundos para confirmação
    Timer(Duration(seconds: 10), () {
      if (!_emergenciaAtiva) {
        ativarEmergencia(motivo: motivo);
      }
    });

    // Aqui você pode mostrar um dialog ou notificação
    print('Emergência detectada: $motivo. Ativando em 10 segundos...');
  }

  // Configurar câmera para gravação
  Future<void> _configurarCamera() async {
    try {
      var status = await Permission.camera.request();

      if (status == PermissionStatus.granted) {
        final cameras = await availableCameras();
        if (cameras.isNotEmpty) {
          _cameraController = CameraController(
            cameras.first,
            ResolutionPreset.medium,
            enableAudio: true,
          );

          await _cameraController?.initialize();
        }
      }
    } catch (e) {
      print('Erro ao configurar câmera: $e');
    }
  }

  // Iniciar gravação de emergência
  Future<void> _iniciarGravacaoEmergencia() async {
    if (_gravacaoAtiva || _cameraController == null) return;

    try {
      await _cameraController?.startVideoRecording();
      _gravacaoAtiva = true;
      notifyListeners();

      print('Gravação de emergência iniciada');
    } catch (e) {
      print('Erro ao iniciar gravação: $e');
    }
  }

  // Parar gravação de emergência
  Future<void> _pararGravacaoEmergencia() async {
    if (!_gravacaoAtiva || _cameraController == null) return;

    try {
      final video = await _cameraController?.stopVideoRecording();
      _gravacaoAtiva = false;
      notifyListeners();

      if (video != null) {
        await _salvarGravacaoEmergencia(video);
      }

    } catch (e) {
      print('Erro ao parar gravação: $e');
    }
  }

  // Salvar gravação de emergência
  Future<void> _salvarGravacaoEmergencia(XFile video) async {
    try {
      final motoristaId = FirebaseAuth.instance.currentUser?.uid;
      if (motoristaId == null) return;

      // Aqui você salvaria o vídeo no Firebase Storage
      // e guardaria a referência no Firestore

      await _firestore.collection('gravacoes_emergencia').add({
        'motoristaId': motoristaId,
        'caminhoArquivo': video.path,
        'timestamp': FieldValue.serverTimestamp(),
        'duracao': await _obterDuracaoVideo(video.path),
        'tamanho': await File(video.path).length(),
      });

    } catch (e) {
      print('Erro ao salvar gravação: $e');
    }
  }

  // Obter localização atual
  Future<Position?> _obterLocalizacaoAtual() async {
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 5),
      );
    } catch (e) {
      print('Erro ao obter localização: $e');
      return null;
    }
  }

  // Criar alerta de emergência
  Future<String> _criarAlertaEmergencia(String motivo, Position? posicao) async {
    try {
      final motoristaId = FirebaseAuth.instance.currentUser?.uid;
      if (motoristaId == null) throw Exception('Usuário não identificado');

      final docRef = await _firestore.collection('alertas_emergencia').add({
        'motoristaId': motoristaId,
        'motivo': motivo,
        'status': 'ativo',
        'iniciadoEm': FieldValue.serverTimestamp(),
        'localizacao': posicao != null ? {
          'lat': posicao.latitude,
          'lon': posicao.longitude,
          'precisao': posicao.accuracy,
        } : null,
        'contatosNotificados': [],
        'gravacoes': [],
      });

      return docRef.id;
    } catch (e) {
      print('Erro ao criar alerta: $e');
      throw e;
    }
  }

  // Compartilhar localização em tempo real
  Future<void> _compartilharLocalizacao(String alertaId, Position? posicaoInicial) async {
    // Atualizar localização a cada 30 segundos durante a emergência
    Timer.periodic(Duration(seconds: 30), (timer) async {
      if (!_emergenciaAtiva) {
        timer.cancel();
        return;
      }

      final posicaoAtual = await _obterLocalizacaoAtual();
      if (posicaoAtual != null) {
        await _firestore.collection('alertas_emergencia').doc(alertaId).update({
          'ultimaLocalizacao': {
            'lat': posicaoAtual.latitude,
            'lon': posicaoAtual.longitude,
            'timestamp': FieldValue.serverTimestamp(),
            'precisao': posicaoAtual.accuracy,
          }
        });
      }
    });
  }

  // Notificar contatos de emergência
  Future<void> _notificarContatosEmergencia(
      String alertaId,
      Position? posicao,
      String? motivo
      ) async {
    try {
      for (var contato in _contatosEmergencia) {
        // Aqui você enviaria SMS, email ou push notification
        // Por enquanto, apenas log
        print('Notificando ${contato['nome']}: ${contato['telefone']}');

        // Simular envio de notificação
        await _enviarNotificacaoContato(contato, alertaId, posicao, motivo);
      }
    } catch (e) {
      print('Erro ao notificar contatos: $e');
    }
  }

  // Enviar notificação para contato específico
  Future<void> _enviarNotificacaoContato(
      Map<String, dynamic> contato,
      String alertaId,
      Position? posicao,
      String? motivo,
      ) async {
    try {
      String mensagem = 'ALERTA DE EMERGÊNCIA!\n\n';
      mensagem += 'Motorista em situação de emergência.\n';
      if (motivo != null) {
        mensagem += 'Motivo: $motivo\n';
      }
      if (posicao != null) {
        mensagem += 'Localização: ${posicao.latitude}, ${posicao.longitude}\n';
        mensagem += 'Google Maps: https://maps.google.com/?q=${posicao.latitude},${posicao.longitude}\n';
      }
      mensagem += '\nHorário: ${DateTime.now().toString()}';

      // Aqui você integraria com um serviço de SMS ou email
      print('Mensagem para ${contato['nome']}: $mensagem');

    } catch (e) {
      print('Erro ao enviar notificação: $e');
    }
  }

  // Configurar timer de emergência
  void _configurarTimerEmergencia(String alertaId) {
    _timerEmergencia = Timer.periodic(Duration(minutes: 1), (timer) async {
      if (!_emergenciaAtiva) {
        timer.cancel();
        return;
      }

      // Atualizar status no banco
      await _firestore.collection('alertas_emergencia').doc(alertaId).update({
        'ultimaAtualizacao': FieldValue.serverTimestamp(),
      });
    });
  }

  // Finalizar alerta de emergência
  Future<void> _finalizarAlertaEmergencia() async {
    try {
      final motoristaId = FirebaseAuth.instance.currentUser?.uid;
      if (motoristaId == null) return;

      // Buscar alerta ativo
      final querySnapshot = await _firestore
          .collection('alertas_emergencia')
          .where('motoristaId', isEqualTo: motoristaId)
          .where('status', isEqualTo: 'ativo')
          .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.update({
          'status': 'finalizado',
          'finalizadoEm': FieldValue.serverTimestamp(),
        });
      }

    } catch (e) {
      print('Erro ao finalizar alerta: $e');
    }
  }

  // Adicionar contato de emergência
  Future<void> adicionarContatoEmergencia(String nome, String telefone, String parentesco) async {
    try {
      final contato = {
        'nome': nome,
        'telefone': telefone,
        'parentesco': parentesco,
        'ativo': true,
        'adicionadoEm': DateTime.now(),
      };

      _contatosEmergencia.add(contato);
      await _salvarContatosEmergencia();

      notifyListeners();
    } catch (e) {
      print('Erro ao adicionar contato: $e');
    }
  }

  // Remover contato de emergência
  Future<void> removerContatoEmergencia(int index) async {
    if (index >= 0 && index < _contatosEmergencia.length) {
      _contatosEmergencia.removeAt(index);
      await _salvarContatosEmergencia();
      notifyListeners();
    }
  }

  // Carregar contatos de emergência
  Future<void> _carregarContatosEmergencia() async {
    try {
      final motoristaId = FirebaseAuth.instance.currentUser?.uid;
      if (motoristaId == null) return;

      final doc = await _firestore.collection('motoristas').doc(motoristaId).get();
      if (doc.exists) {
        final data = doc.data()!;
        final contatosData = data['contatosEmergencia'] as List<dynamic>?;

        if (contatosData != null) {
          _contatosEmergencia = contatosData.cast<Map<String, dynamic>>();
        }
      }
    } catch (e) {
      print('Erro ao carregar contatos: $e');
    }
  }

  // Salvar contatos de emergência
  Future<void> _salvarContatosEmergencia() async {
    try {
      final motoristaId = FirebaseAuth.instance.currentUser?.uid;
      if (motoristaId == null) return;

      await _firestore.collection('motoristas').doc(motoristaId).update({
        'contatosEmergencia': _contatosEmergencia,
      });
    } catch (e) {
      print('Erro ao salvar contatos: $e');
    }
  }

  // Iniciar monitoramento
  void _iniciarMonitoramento() {
    _monitoramentoAtivo = true;
    notifyListeners();
  }

  // Parar monitoramento
  void pararMonitoramento() {
    _monitoramentoAtivo = false;
    _acelerometerSubscription?.cancel();
    notifyListeners();
  }

  // Configurar sensibilidade de detecção
  void configurarSensibilidade(double limite) {
    _limiteAceleracao = limite.clamp(5.0, 25.0);
  }

  // Obter duração do vídeo (método auxiliar)
  Future<int> _obterDuracaoVideo(String caminho) async {
    // Implementação simplificada
    return 0;
  }

  // Teste de emergência
  Future<void> testeEmergencia() async {
    await ativarEmergencia(motivo: 'Teste do sistema de emergência');

    // Desativar após 30 segundos
    Timer(Duration(seconds: 30), () {
      desativarEmergencia();
    });
  }

  @override
  void dispose() {
    _timerEmergencia?.cancel();
    _acelerometerSubscription?.cancel();
    _cameraController?.dispose();
    super.dispose();
  }
}
