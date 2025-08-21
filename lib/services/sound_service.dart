import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final AudioPlayer _audioPlayer = AudioPlayer();
  static bool _soundEnabled = true;

  // Sons personalizados da Vello
  static const String _onlineSound = 'sounds/vello_online.mp3';
  static const String _offlineSound = 'sounds/vello_offline.mp3';
  static const String _newRideSound = 'sounds/vello_new_ride.mp3';
  static const String _rideAcceptedSound = 'sounds/vello_ride_accepted.mp3';
  static const String _rideCompletedSound = 'sounds/vello_ride_completed.mp3';
  static const String _notificationSound = 'sounds/vello_notification.mp3';
  static const String _errorSound = 'sounds/vello_error.mp3';
  static const String _successSound = 'sounds/vello_success.mp3';
  static const String _loginSound = 'sounds/vello_login.mp3';
  static const String _logoutSound = 'sounds/vello_logout.mp3';

  // Configurações
  static bool get soundEnabled => _soundEnabled;
  
  static void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
  }

  // Método principal para tocar sons
  static Future<void> _playSound(String soundPath, {double volume = 1.0}) async {
    if (!_soundEnabled) return;
    
    try {
      await _audioPlayer.play(AssetSource(soundPath));
      await _audioPlayer.setVolume(volume);
    } catch (e) {
      // Fallback para vibração se o som falhar
      HapticFeedback.mediumImpact();
    }
  }

  // Sons específicos da Vello Motorista

  /// Som quando motorista fica online - Tom alegre e motivador
  static Future<void> playOnlineSound() async {
    await _playSound(_onlineSound, volume: 0.8);
    HapticFeedback.lightImpact();
  }

  /// Som quando motorista fica offline - Tom suave de despedida
  static Future<void> playOfflineSound() async {
    await _playSound(_offlineSound, volume: 0.6);
    HapticFeedback.selectionClick();
  }

  /// Som de nova corrida disponível - Tom urgente mas agradável
  static Future<void> playNewRideSound() async {
    await _playSound(_newRideSound, volume: 1.0);
    // Vibração mais intensa para chamar atenção
    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 200));
    HapticFeedback.mediumImpact();
  }

  /// Som quando aceita uma corrida - Tom de confirmação positiva
  static Future<void> playRideAcceptedSound() async {
    await _playSound(_rideAcceptedSound, volume: 0.9);
    HapticFeedback.mediumImpact();
  }

  /// Som quando completa uma corrida - Tom de conquista e satisfação
  static Future<void> playRideCompletedSound() async {
    await _playSound(_rideCompletedSound, volume: 0.9);
    HapticFeedback.lightImpact();
  }

  /// Som de notificação geral - Tom neutro mas distintivo
  static Future<void> playNotificationSound() async {
    await _playSound(_notificationSound, volume: 0.7);
    HapticFeedback.selectionClick();
  }

  /// Som de erro - Tom suave de alerta sem ser agressivo
  static Future<void> playErrorSound() async {
    await _playSound(_errorSound, volume: 0.6);
    HapticFeedback.mediumImpact();
  }

  /// Som de sucesso - Tom positivo e recompensador
  static Future<void> playSuccessSound() async {
    await _playSound(_successSound, volume: 0.8);
    HapticFeedback.lightImpact();
  }

  /// Som de login - Tom de boas-vindas caloroso
  static Future<void> playLoginSound() async {
    await _playSound(_loginSound, volume: 0.7);
    HapticFeedback.selectionClick();
  }

  /// Som de logout - Tom de despedida amigável
  static Future<void> playLogoutSound() async {
    await _playSound(_logoutSound, volume: 0.6);
    HapticFeedback.selectionClick();
  }

  // Sons contextuais baseados em situações

  /// Som para ganhos/dinheiro - Tom de celebração sutil
  static Future<void> playEarningsSound() async {
    await playSuccessSound();
  }

  /// Som para GPS/localização - Tom tecnológico suave
  static Future<void> playLocationSound() async {
    await playNotificationSound();
  }

  /// Som para mensagens/chat - Tom amigável de conversa
  static Future<void> playMessageSound() async {
    await _playSound(_notificationSound, volume: 0.5);
    HapticFeedback.selectionClick();
  }

  /// Som para cancelamento - Tom neutro de informação
  static Future<void> playCancelSound() async {
    await playNotificationSound();
  }

  // Métodos utilitários

  /// Para todos os sons
  static Future<void> stopAllSounds() async {
    await _audioPlayer.stop();
  }

  /// Ajusta volume global
  static Future<void> setGlobalVolume(double volume) async {
    await _audioPlayer.setVolume(volume.clamp(0.0, 1.0));
  }

  /// Testa se os sons estão funcionando
  static Future<void> testSounds() async {
    await playNotificationSound();
    await Future.delayed(const Duration(milliseconds: 500));
    await playSuccessSound();
  }

  /// Libera recursos
  static Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}

// Extensão para facilitar uso em widgets
extension SoundServiceExtension on SoundService {
  static Future<void> playOnStatusChange(bool isOnline) async {
    if (isOnline) {
      await SoundService.playOnlineSound();
    } else {
      await SoundService.playOfflineSound();
    }
  }
}

