
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AssistenteVozService extends ChangeNotifier {
  static final AssistenteVozService _instance = AssistenteVozService._internal();
  factory AssistenteVozService() => _instance;
  AssistenteVozService._internal();

  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _speechEnabled = false;
  bool _speechListening = false;
  bool _ttsEnabled = true;
  String _lastWords = '';
  List<Map<String, dynamic>> _comandosPersonalizados = [];

  // Getters
  bool get speechEnabled => _speechEnabled;
  bool get speechListening => _speechListening;
  bool get ttsEnabled => _ttsEnabled;
  String get lastWords => _lastWords;
  List<Map<String, dynamic>> get comandosPersonalizados => _comandosPersonalizados;

  // Inicializar assistente
  Future<void> inicializar() async {
    await _inicializarSpeechToText();
    await _inicializarTTS();
    await _carregarComandosPersonalizados();
  }

  // Inicializar Speech-to-Text
  Future<void> _inicializarSpeechToText() async {
    try {
      // Solicitar permissão de microfone
      var status = await Permission.microphone.request();

      if (status == PermissionStatus.granted) {
        _speechEnabled = await _speechToText.initialize(
          onStatus: (status) => print('Status: $status'),
          onError: (error) => print('Erro: $error'),
        );
      }
    } catch (e) {
      print('Erro ao inicializar Speech-to-Text: $e');
      _speechEnabled = false;
    }

    notifyListeners();
  }

  // Inicializar Text-to-Speech
  Future<void> _inicializarTTS() async {
    try {
      await _flutterTts.setLanguage('pt-BR');
      await _flutterTts.setSpeechRate(0.8);
      await _flutterTts.setVolume(0.8);
      await _flutterTts.setPitch(1.0);

      _ttsEnabled = true;
    } catch (e) {
      print('Erro ao inicializar TTS: $e');
      _ttsEnabled = false;
    }
  }

  // Começar escuta
  Future<void> iniciarEscuta() async {
    if (!_speechEnabled || _speechListening) return;

    try {
      await _speechToText.listen(
        onResult: _onSpeechResult,
        listenFor: Duration(seconds: 30),
        pauseFor: Duration(seconds: 5),
        partialResults: true,
        localeId: 'pt_BR',
        cancelOnError: true,
      );

      _speechListening = true;
      notifyListeners();

      // Som de início
      await falar('Estou escutando...');
    } catch (e) {
      print('Erro ao iniciar escuta: $e');
    }
  }

  // Parar escuta
  Future<void> pararEscuta() async {
    await _speechToText.stop();
    _speechListening = false;
    notifyListeners();
  }

  // Callback para resultado da fala
  void _onSpeechResult(result) {
    _lastWords = result.recognizedWords;
    notifyListeners();

    if (result.finalResult) {
      _processarComando(_lastWords);
      _speechListening = false;
      notifyListeners();
    }
  }

  // Processar comando de voz
  Future<void> _processarComando(String comando) async {
    final comandoLower = comando.toLowerCase().trim();

    print('Comando recebido: $comandoLower');

    // Comandos básicos
    if (comandoLower.contains('aceitar') || comandoLower.contains('aceito')) {
      await _executarComandoAceitar();
    } else if (comandoLower.contains('recusar') || comandoLower.contains('rejeitar')) {
      await _executarComandoRecusar();
    } else if (comandoLower.contains('online') || comandoLower.contains('ficar online')) {
      await _executarComandoFicarOnline();
    } else if (comandoLower.contains('offline') || comandoLower.contains('ficar offline')) {
      await _executarComandoFicarOffline();
    } else if (comandoLower.contains('navegação') || comandoLower.contains('navegar')) {
      await _executarComandoNavegacao();
    } else if (comandoLower.contains('chegei') || comandoLower.contains('cheguei')) {
      await _executarComandoCheguei();
    } else if (comandoLower.contains('concluir') || comandoLower.contains('finalizar')) {
      await _executarComandoConcluir();
    } else if (comandoLower.contains('ajuda')) {
      await _mostrarComandosDisponiveis();
    } else if (comandoLower.contains('status') || comandoLower.contains('situação')) {
      await _informarStatus();
    } else {
      // Verificar comandos personalizados
      bool comandoEncontrado = false;
      for (var cmd in _comandosPersonalizados) {
        if (comandoLower.contains(cmd['gatilho'].toLowerCase())) {
          await _executarComandoPersonalizado(cmd);
          comandoEncontrado = true;
          break;
        }
      }

      if (!comandoEncontrado) {
        await falar('Comando não reconhecido. Diga "ajuda" para ver os comandos disponíveis.');
      }
    }
  }

  // Executar comandos específicos
  Future<void> _executarComandoAceitar() async {
    await falar('Aceitando corrida...');
    // Implementar lógica de aceitar corrida
    // Pode usar um callback ou event system
  }

  Future<void> _executarComandoRecusar() async {
    await falar('Recusando corrida...');
    // Implementar lógica de recusar corrida
  }

  Future<void> _executarComandoFicarOnline() async {
    await falar('Ficando online para receber corridas...');
    // Implementar lógica para ficar online
  }

  Future<void> _executarComandoFicarOffline() async {
    await falar('Ficando offline...');
    // Implementar lógica para ficar offline
  }

  Future<void> _executarComandoNavegacao() async {
    await falar('Iniciando navegação para o destino...');
    // Implementar lógica de navegação
  }

  Future<void> _executarComandoCheguei() async {
    await falar('Informando que chegou no local...');
    // Implementar lógica de chegada
  }

  Future<void> _executarComandoConcluir() async {
    await falar('Concluindo corrida...');
    // Implementar lógica de conclusão
  }

  Future<void> _mostrarComandosDisponiveis() async {
    final comandos = [
      'Aceitar ou Aceito - para aceitar uma corrida',
      'Recusar ou Rejeitar - para recusar uma corrida',
      'Ficar Online - para ficar disponível',
      'Ficar Offline - para sair de operação',
      'Navegação - para iniciar navegação',
      'Chegei - para informar chegada',
      'Concluir - para finalizar corrida',
      'Status - para saber sua situação atual',
    ];

    await falar('Comandos disponíveis: ${comandos.join(', ')}');
  }

  Future<void> _informarStatus() async {
    // Obter status atual do motorista
    try {
      final motoristaId = FirebaseAuth.instance.currentUser?.uid;
      if (motoristaId == null) {
        await falar('Usuário não identificado');
        return;
      }

      final doc = await _firestore.collection('motoristas').doc(motoristaId).get();
      if (doc.exists) {
        final data = doc.data()!;
        final status = data['status'] ?? 'offline';
        final nome = data['nome'] ?? 'Motorista';

        await falar('Olá $nome, você está $status no momento.');
      } else {
        await falar('Não foi possível obter seu status atual');
      }
    } catch (e) {
      await falar('Erro ao obter informações de status');
    }
  }

  // Executar comando personalizado
  Future<void> _executarComandoPersonalizado(Map<String, dynamic> comando) async {
    await falar(comando['resposta'] ?? 'Comando personalizado executado');

    // Log do uso do comando
    await _salvarLogComando(comando['nome'], _lastWords);
  }

  // Falar texto
  Future<void> falar(String texto) async {
    if (!_ttsEnabled) return;

    try {
      await _flutterTts.speak(texto);
    } catch (e) {
      print('Erro ao falar: $e');
    }
  }

  // Parar fala
  Future<void> pararFala() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      print('Erro ao parar fala: $e');
    }
  }

  // Toggle TTS
  void toggleTTS() {
    _ttsEnabled = !_ttsEnabled;
    notifyListeners();
  }

  // Configurar velocidade da fala
  Future<void> configurarVelocidadeFala(double velocidade) async {
    try {
      await _flutterTts.setSpeechRate(velocidade.clamp(0.1, 2.0));
    } catch (e) {
      print('Erro ao configurar velocidade: $e');
    }
  }

  // Configurar volume
  Future<void> configurarVolume(double volume) async {
    try {
      await _flutterTts.setVolume(volume.clamp(0.0, 1.0));
    } catch (e) {
      print('Erro ao configurar volume: $e');
    }
  }

  // Adicionar comando personalizado
  Future<void> adicionarComandoPersonalizado(
      String nome,
      String gatilho,
      String resposta,
      String acao,
      ) async {
    try {
      final comando = {
        'nome': nome,
        'gatilho': gatilho,
        'resposta': resposta,
        'acao': acao,
        'criadoEm': DateTime.now(),
        'usos': 0,
      };

      _comandosPersonalizados.add(comando);
      await _salvarComandosPersonalizados();

      notifyListeners();

      await falar('Comando personalizado "$nome" adicionado com sucesso');
    } catch (e) {
      print('Erro ao adicionar comando: $e');
      await falar('Erro ao adicionar comando personalizado');
    }
  }

  // Remover comando personalizado
  Future<void> removerComandoPersonalizado(int index) async {
    if (index >= 0 && index < _comandosPersonalizados.length) {
      final comando = _comandosPersonalizados.removeAt(index);
      await _salvarComandosPersonalizados();

      notifyListeners();

      await falar('Comando "${comando['nome']}" removido');
    }
  }

  // Carregar comandos personalizados
  Future<void> _carregarComandosPersonalizados() async {
    try {
      final motoristaId = FirebaseAuth.instance.currentUser?.uid;
      if (motoristaId == null) return;

      final doc = await _firestore
          .collection('motoristas')
          .doc(motoristaId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        final comandosData = data['comandosVoz'] as List<dynamic>?;

        if (comandosData != null) {
          _comandosPersonalizados = comandosData
              .cast<Map<String, dynamic>>()
              .toList();
        }
      }
    } catch (e) {
      print('Erro ao carregar comandos personalizados: $e');
    }
  }

  // Salvar comandos personalizados
  Future<void> _salvarComandosPersonalizados() async {
    try {
      final motoristaId = FirebaseAuth.instance.currentUser?.uid;
      if (motoristaId == null) return;

      await _firestore
          .collection('motoristas')
          .doc(motoristaId)
          .update({
        'comandosVoz': _comandosPersonalizados,
      });
    } catch (e) {
      print('Erro ao salvar comandos: $e');
    }
  }

  // Salvar log de uso de comando
  Future<void> _salvarLogComando(String nomeComando, String textoReconhecido) async {
    try {
      final motoristaId = FirebaseAuth.instance.currentUser?.uid;
      if (motoristaId == null) return;

      await _firestore.collection('logs_comandos_voz').add({
        'motoristaId': motoristaId,
        'comando': nomeComando,
        'textoReconhecido': textoReconhecido,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Erro ao salvar log: $e');
    }
  }

  // Obter estatísticas de uso
  Future<Map<String, dynamic>> obterEstatisticasUso() async {
    try {
      final motoristaId = FirebaseAuth.instance.currentUser?.uid;
      if (motoristaId == null) return {};

      final querySnapshot = await _firestore
          .collection('logs_comandos_voz')
          .where('motoristaId', isEqualTo: motoristaId)
          .orderBy('timestamp', descending: true)
          .limit(100)
          .get();

      final logs = querySnapshot.docs.map((doc) => doc.data()).toList();

      // Contar comandos mais usados
      Map<String, int> contagemComandos = {};
      for (var log in logs) {
        final comando = log['comando'] as String;
        contagemComandos[comando] = (contagemComandos[comando] ?? 0) + 1;
      }

      return {
        'totalComandos': logs.length,
        'comandosMaisUsados': contagemComandos,
        'ultimoUso': logs.isNotEmpty ? logs.first['timestamp'] : null,
      };
    } catch (e) {
      print('Erro ao obter estatísticas: $e');
      return {};
    }
  }

  // Modo mãos livres
  void ativarModoMaosLivres() {
    // Implementar modo que responde automaticamente a determinados eventos
    print('Modo mãos livres ativado');
  }

  void desativarModoMaosLivres() {
    print('Modo mãos livres desativado');
  }

  @override
  void dispose() {
    _speechToText.stop();
    _flutterTts.stop();
    super.dispose();
  }
}
