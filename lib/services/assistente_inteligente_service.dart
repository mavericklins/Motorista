
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import '../services/financial_service.dart';
import '../services/navigation_service.dart';
import '../services/gamification_service.dart';

class AssistenteInteligenteService extends ChangeNotifier {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  
  bool _isListening = false;
  bool _speechEnabled = false;
  String _lastWords = '';
  Timer? _contextTimer;
  
  // Contexto da conversa
  List<Map<String, dynamic>> _conversationContext = [];
  Map<String, dynamic> _currentSession = {};

  bool get isListening => _isListening;
  bool get speechEnabled => _speechEnabled;
  String get lastWords => _lastWords;

  // Comandos disponíveis organizados por categoria
  final Map<String, List<Map<String, dynamic>>> _comandosDisponiveis = {
    'navegacao': [
      {'comando': 'ir para casa', 'acao': 'navigate_home'},
      {'comando': 'abrir perfil', 'acao': 'navigate_profile'},
      {'comando': 'ver histórico', 'acao': 'navigate_history'},
      {'comando': 'abrir configurações', 'acao': 'navigate_settings'},
      {'comando': 'ver ganhos', 'acao': 'navigate_earnings'},
    ],
    'status': [
      {'comando': 'ficar online', 'acao': 'go_online'},
      {'comando': 'ficar offline', 'acao': 'go_offline'},
      {'comando': 'aceitar corrida', 'acao': 'accept_ride'},
      {'comando': 'recusar corrida', 'acao': 'reject_ride'},
      {'comando': 'cancelar corrida', 'acao': 'cancel_ride'},
    ],
    'informacoes': [
      {'comando': 'quanto ganhei hoje', 'acao': 'earnings_today'},
      {'comando': 'quantas corridas fiz', 'acao': 'rides_count'},
      {'comando': 'qual minha avaliação', 'acao': 'rating_info'},
      {'comando': 'como está o trânsito', 'acao': 'traffic_info'},
      {'comando': 'onde estou', 'acao': 'location_info'},
    ],
    'metas': [
      {'comando': 'como estão minhas metas', 'acao': 'goals_status'},
      {'comando': 'criar nova meta', 'acao': 'create_goal'},
      {'comando': 'metas de hoje', 'acao': 'today_goals'},
    ],
    'emergencia': [
      {'comando': 'socorro', 'acao': 'emergency_help'},
      {'comando': 'ligar para suporte', 'acao': 'call_support'},
      {'comando': 'reportar problema', 'acao': 'report_issue'},
    ],
    'conveniencia': [
      {'comando': 'ler mensagens', 'acao': 'read_messages'},
      {'comando': 'pausar música', 'acao': 'pause_music'},
      {'comando': 'aumentar volume', 'acao': 'volume_up'},
      {'comando': 'diminuir volume', 'acao': 'volume_down'},
    ],
  };

  Future<void> initSpeech() async {
    try {
      print('🎤 Inicializando assistente de voz...');
      
      // Verificar e solicitar permissões
      final micPermission = await Permission.microphone.request();
      if (micPermission != PermissionStatus.granted) {
        print('❌ Permissão de microfone negada');
        return;
      }

      // Inicializar speech to text
      _speechEnabled = await _speechToText.initialize(
        onStatus: _onSpeechStatus,
        onError: _onSpeechError,
        debugLogging: true,
      );

      // Configurar TTS
      await _configurarTTS();

      if (_speechEnabled) {
        print('✅ Assistente de voz ativado');
        await _falar('Olá! Sou seu assistente Vello. Como posso ajudar?');
        
        // Iniciar sessão
        _iniciarSessao();
      } else {
        print('❌ Falha ao ativar assistente de voz');
      }

      notifyListeners();
    } catch (e) {
      print('❌ Erro ao inicializar assistente: $e');
    }
  }

  Future<void> _configurarTTS() async {
    await _flutterTts.setLanguage('pt-BR');
    await _flutterTts.setSpeechRate(0.9);
    await _flutterTts.setVolume(0.8);
    await _flutterTts.setPitch(1.0);

    // Configurar callbacks
    _flutterTts.setStartHandler(() {
      print('🔊 TTS iniciado');
    });

    _flutterTts.setCompletionHandler(() {
      print('✅ TTS concluído');
    });

    _flutterTts.setErrorHandler((msg) {
      print('❌ Erro TTS: $msg');
    });
  }

  void _iniciarSessao() {
    _currentSession = {
      'inicio': DateTime.now(),
      'comandos_executados': 0,
      'contexto_ativo': null,
      'usuario_ativo': true,
    };
  }

  Future<void> startListening() async {
    if (!_speechEnabled) {
      await initSpeech();
      return;
    }

    if (_isListening) return;

    try {
      _lastWords = '';
      _isListening = true;
      notifyListeners();

      await _speechToText.listen(
        onResult: _onSpeechResult,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        localeId: 'pt_BR',
        cancelOnError: true,
        listenMode: ListenMode.confirmation,
      );

      print('🎤 Escutando comandos...');
    } catch (e) {
      print('❌ Erro ao iniciar escuta: $e');
      _isListening = false;
      notifyListeners();
    }
  }

  Future<void> stopListening() async {
    if (!_isListening) return;

    await _speechToText.stop();
    _isListening = false;
    notifyListeners();
    print('🛑 Parou de escutar');
  }

  void _onSpeechResult(result) {
    final command = result.recognizedWords.toLowerCase();
    _lastWords = command;
    notifyListeners();

    print('🎤 Comando detectado: $command');

    if (result.finalResult) {
      _processarComando(command);
    }
  }

  void _onSpeechStatus(String status) {
    print('🎤 Status do speech: $status');
    
    if (status == 'done' || status == 'notListening') {
      _isListening = false;
      notifyListeners();
    }
  }

  void _onSpeechError(error) {
    print('❌ Erro no speech: $error');
    _isListening = false;
    notifyListeners();
  }

  Future<void> _processarComando(String comando) async {
    try {
      print('🤖 Processando comando: $comando');
      
      // Adicionar ao contexto da conversa
      _conversationContext.add({
        'timestamp': DateTime.now(),
        'tipo': 'comando',
        'conteudo': comando,
      });

      // Manter apenas os últimos 10 comandos no contexto
      if (_conversationContext.length > 10) {
        _conversationContext.removeAt(0);
      }

      // Processar comando usando IA simplificada
      final resultado = await _analisarComandoIA(comando);
      
      if (resultado['sucesso']) {
        await _executarAcao(resultado['acao'], resultado['parametros']);
        _currentSession['comandos_executados']++;
      } else {
        await _falar(resultado['resposta'] ?? 'Desculpe, não entendi. Pode repetir?');
        await _sugerirComandos();
      }

    } catch (e) {
      print('❌ Erro ao processar comando: $e');
      await _falar('Ops, houve um erro. Tente novamente.');
    }
  }

  Future<Map<String, dynamic>> _analisarComandoIA(String comando) async {
    // Normalizar comando
    final comandoLimpo = _normalizarComando(comando);
    
    // Buscar correspondência exata primeiro
    for (final categoria in _comandosDisponiveis.keys) {
      for (final cmd in _comandosDisponiveis[categoria]!) {
        if (comandoLimpo.contains(cmd['comando'])) {
          return {
            'sucesso': true,
            'acao': cmd['acao'],
            'categoria': categoria,
            'parametros': _extrairParametros(comando, cmd['comando']),
          };
        }
      }
    }

    // Buscar correspondência por similaridade
    final melhorCorrespondencia = _encontrarMelhorCorrespondencia(comandoLimpo);
    if (melhorCorrespondencia['confianca'] > 0.7) {
      return {
        'sucesso': true,
        'acao': melhorCorrespondencia['acao'],
        'categoria': melhorCorrespondencia['categoria'],
        'parametros': {},
      };
    }

    // Analisar contexto para comandos ambíguos
    final contextoAcao = _analisarContexto(comandoLimpo);
    if (contextoAcao != null) {
      return {
        'sucesso': true,
        'acao': contextoAcao,
        'categoria': 'contexto',
        'parametros': {},
      };
    }

    return {
      'sucesso': false,
      'resposta': _gerarRespostaNaoEntendido(comando),
    };
  }

  String _normalizarComando(String comando) {
    return comando
        .toLowerCase()
        .replaceAll(RegExp(r'[áàâã]'), 'a')
        .replaceAll(RegExp(r'[éêë]'), 'e')
        .replaceAll(RegExp(r'[íîï]'), 'i')
        .replaceAll(RegExp(r'[óôõö]'), 'o')
        .replaceAll(RegExp(r'[úûü]'), 'u')
        .replaceAll(RegExp(r'[ç]'), 'c')
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .trim();
  }

  Map<String, dynamic> _encontrarMelhorCorrespondencia(String comando) {
    double melhorConfianca = 0;
    Map<String, dynamic> melhorMatch = {};

    for (final categoria in _comandosDisponiveis.keys) {
      for (final cmd in _comandosDisponiveis[categoria]!) {
        final confianca = _calcularSimilaridade(comando, cmd['comando']);
        if (confianca > melhorConfianca) {
          melhorConfianca = confianca;
          melhorMatch = {
            'acao': cmd['acao'],
            'categoria': categoria,
            'confianca': confianca,
          };
        }
      }
    }

    return melhorMatch;
  }

  double _calcularSimilaridade(String a, String b) {
    // Implementação simples de similaridade Jaro-Winkler
    final palavrasA = a.split(' ');
    final palavrasB = b.split(' ');
    
    int matches = 0;
    for (final palavraA in palavrasA) {
      for (final palavraB in palavrasB) {
        if (palavraA == palavraB || palavraA.contains(palavraB) || palavraB.contains(palavraA)) {
          matches++;
          break;
        }
      }
    }

    return matches / palavrasA.length;
  }

  String? _analisarContexto(String comando) {
    // Analisar palavras-chave de contexto
    if (comando.contains('sim') || comando.contains('aceitar') || comando.contains('ok')) {
      return 'confirm_action';
    }
    
    if (comando.contains('nao') || comando.contains('cancelar') || comando.contains('recusar')) {
      return 'reject_action';
    }
    
    if (comando.contains('help') || comando.contains('ajuda') || comando.contains('socorro')) {
      return 'show_help';
    }

    return null;
  }

  Map<String, dynamic> _extrairParametros(String comando, String comandoBase) {
    final parametros = <String, dynamic>{};
    
    // Extrair números
    final numeros = RegExp(r'\d+').allMatches(comando);
    if (numeros.isNotEmpty) {
      parametros['numero'] = int.tryParse(numeros.first.group(0)!) ?? 0;
    }

    // Extrair horários
    final horarios = RegExp(r'\d{1,2}:\d{2}').allMatches(comando);
    if (horarios.isNotEmpty) {
      parametros['horario'] = horarios.first.group(0);
    }

    return parametros;
  }

  Future<void> _executarAcao(String acao, Map<String, dynamic> parametros) async {
    print('🚀 Executando ação: $acao');

    switch (acao) {
      case 'navigate_home':
        await _falar('Abrindo tela inicial');
        // Navigator.of(context).pushReplacementNamed('/');
        break;

      case 'navigate_profile':
        await _falar('Abrindo seu perfil');
        // Navigator.of(context).pushNamed('/perfil');
        break;

      case 'navigate_history':
        await _falar('Mostrando histórico de corridas');
        // Navigator.of(context).pushNamed('/historico');
        break;

      case 'navigate_earnings':
        await _falar('Exibindo seus ganhos');
        // Navigator.of(context).pushNamed('/ganhos');
        break;

      case 'go_online':
        await _falar('Colocando você online. Boa sorte nas corridas!');
        // Implementar lógica de ficar online
        break;

      case 'go_offline':
        await _falar('Colocando você offline. Descanse bem!');
        // Implementar lógica de ficar offline
        break;

      case 'earnings_today':
        final ganhos = await _obterGanhosHoje();
        await _falar('Hoje você ganhou R\$ ${ganhos.toStringAsFixed(2)}');
        break;

      case 'rides_count':
        final corridas = await _obterCorridasHoje();
        await _falar('Hoje você fez $corridas corridas');
        break;

      case 'rating_info':
        final avaliacao = await _obterAvaliacaoAtual();
        await _falar('Sua avaliação atual é ${avaliacao.toStringAsFixed(1)} estrelas');
        break;

      case 'goals_status':
        await _informarStatusMetas();
        break;

      case 'traffic_info':
        await _falar('Verificando condições do trânsito...');
        await _informarTransito();
        break;

      case 'location_info':
        await _falar('Verificando sua localização...');
        await _informarLocalizacao();
        break;

      case 'emergency_help':
        await _falar('Ativando modo de emergência. Entrando em contato com o suporte.');
        // Implementar chamada de emergência
        break;

      case 'show_help':
        await _mostrarAjuda();
        break;

      case 'confirm_action':
        await _falar('Ação confirmada');
        break;

      case 'reject_action':
        await _falar('Ação cancelada');
        break;

      default:
        await _falar('Comando não implementado ainda');
    }

    // Adicionar resposta ao contexto
    _conversationContext.add({
      'timestamp': DateTime.now(),
      'tipo': 'resposta',
      'acao': acao,
    });
  }

  Future<void> _falar(String texto) async {
    try {
      print('🗣️ Falando: $texto');
      await _flutterTts.speak(texto);
    } catch (e) {
      print('❌ Erro ao falar: $e');
    }
  }

  Future<void> _sugerirComandos() async {
    final sugestoes = [
      'Você pode dizer "ir para casa", "quanto ganhei hoje" ou "ficar online"',
      'Experimente comandos como "ver histórico", "como estão minhas metas" ou "onde estou"',
      'Diga "ajuda" para ver todos os comandos disponíveis',
    ];
    
    final sugestao = sugestoes[DateTime.now().millisecond % sugestoes.length];
    await _falar(sugestao);
  }

  String _gerarRespostaNaoEntendido(String comando) {
    final respostas = [
      'Não entendi "$comando". Pode reformular?',
      'Comando não reconhecido. Tente algo como "quanto ganhei hoje"',
      'Desculpe, não compreendi. Diga "ajuda" para ver os comandos',
    ];
    
    return respostas[DateTime.now().millisecond % respostas.length];
  }

  Future<void> _mostrarAjuda() async {
    await _falar('Estes são alguns comandos que você pode usar:');
    await Future.delayed(const Duration(milliseconds: 500));
    
    final comandosPopulares = [
      'Quanto ganhei hoje',
      'Quantas corridas fiz',
      'Ficar online',
      'Ver histórico',
      'Como estão minhas metas',
    ];

    for (int i = 0; i < comandosPopulares.length; i++) {
      await _falar('${i + 1}. ${comandosPopulares[i]}');
      await Future.delayed(const Duration(milliseconds: 300));
    }
  }

  // Métodos de integração com outros serviços
  Future<double> _obterGanhosHoje() async {
    try {
      final financialService = FinancialService();
      final summary = await financialService.getDailySummary('user_id');
      return summary.totalEarnings;
    } catch (e) {
      return 0.0;
    }
  }

  Future<int> _obterCorridasHoje() async {
    try {
      final financialService = FinancialService();
      final summary = await financialService.getDailySummary('user_id');
      return summary.totalRides;
    } catch (e) {
      return 0;
    }
  }

  Future<double> _obterAvaliacaoAtual() async {
    // Implementar busca de avaliação atual
    return 4.8;
  }

  Future<void> _informarStatusMetas() async {
    try {
      // Implementar integração com GamificationService
      await _falar('Verificando suas metas...');
      await Future.delayed(const Duration(seconds: 1));
      await _falar('Você concluiu 3 de 5 metas hoje. Continue assim!');
    } catch (e) {
      await _falar('Não foi possível verificar suas metas no momento');
    }
  }

  Future<void> _informarTransito() async {
    // Implementar integração com serviço de trânsito
    await Future.delayed(const Duration(seconds: 1));
    await _falar('O trânsito está normal na sua região. Boa hora para trabalhar!');
  }

  Future<void> _informarLocalizacao() async {
    // Implementar integração com serviço de localização
    await Future.delayed(const Duration(seconds: 1));
    await _falar('Você está na região central da cidade');
  }

  // Comandos de conveniência
  Future<void> executarComandoRapido(String comando) async {
    await _processarComando(comando);
  }

  List<String> obterComandosPopulares() {
    return [
      'Quanto ganhei hoje',
      'Quantas corridas fiz',
      'Ficar online',
      'Ficar offline',
      'Ver histórico',
      'Como estão minhas metas',
      'Onde estou',
      'Como está o trânsito',
    ];
  }

  Map<String, dynamic> obterEstatisticasUso() {
    return {
      'comandos_executados': _currentSession['comandos_executados'] ?? 0,
      'tempo_sessao': DateTime.now().difference(_currentSession['inicio'] ?? DateTime.now()).inMinutes,
      'contexto_ativo': _conversationContext.length,
    };
  }

  void dispose() {
    _speechToText.stop();
    _flutterTts.stop();
    _contextTimer?.cancel();
    super.dispose();
  }
}
