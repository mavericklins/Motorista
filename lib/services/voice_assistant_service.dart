
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Serviço de assistente de voz para o Vello Motorista
class VoiceAssistantService {
  static final VoiceAssistantService _instance = VoiceAssistantService._internal();
  factory VoiceAssistantService() => _instance;
  VoiceAssistantService._internal();

  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  
  bool _speechEnabled = false;
  bool _isListening = false;
  String _wordsSpoken = "";

  // Getters
  bool get isListening => _isListening;
  bool get speechEnabled => _speechEnabled;
  String get wordsSpoken => _wordsSpoken;

  /// Inicializar o serviço de voz
  Future<void> initialize() async {
    try {
      _speechEnabled = await _speechToText.initialize();
      
      // Configurar TTS
      await _flutterTts.setLanguage("pt-BR");
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
      
      debugPrint('🎤 Serviço de voz inicializado: $_speechEnabled');
    } catch (e) {
      debugPrint('❌ Erro ao inicializar serviço de voz: $e');
    }
  }

  /// Iniciar escuta de voz
  Future<void> startListening({Function(String)? onResult}) async {
    if (!_speechEnabled) return;

    try {
      _isListening = true;
      await _speechToText.listen(
        onResult: (result) {
          _wordsSpoken = result.recognizedWords;
          onResult?.call(_wordsSpoken);
        },
        listenFor: Duration(seconds: 30),
        pauseFor: Duration(seconds: 3),
        partialResults: true,
        onSoundLevelChange: null,
        cancelOnError: true,
        listenMode: ListenMode.confirmation,
      );
    } catch (e) {
      debugPrint('❌ Erro ao iniciar escuta: $e');
      _isListening = false;
    }
  }

  /// Parar escuta de voz
  Future<void> stopListening() async {
    try {
      await _speechToText.stop();
      _isListening = false;
    } catch (e) {
      debugPrint('❌ Erro ao parar escuta: $e');
    }
  }

  /// Falar texto
  Future<void> speak(String text) async {
    try {
      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint('❌ Erro ao falar: $e');
    }
  }

  /// Parar fala
  Future<void> stopSpeaking() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      debugPrint('❌ Erro ao parar fala: $e');
    }
  }

  /// Processar comando de voz
  Future<void> processVoiceCommand(String command) async {
    final commandLower = command.toLowerCase();
    
    if (commandLower.contains('aceitar corrida')) {
      await speak('Aceitando corrida');
      // Lógica para aceitar corrida
    } else if (commandLower.contains('recusar corrida')) {
      await speak('Recusando corrida');
      // Lógica para recusar corrida
    } else if (commandLower.contains('ficar online')) {
      await speak('Ficando online');
      // Lógica para ficar online
    } else if (commandLower.contains('ficar offline')) {
      await speak('Ficando offline');
      // Lógica para ficar offline
    } else {
      await speak('Comando não reconhecido');
    }
  }

  /// Limpar recursos
  void dispose() {
    stopListening();
    stopSpeaking();
  }
}
