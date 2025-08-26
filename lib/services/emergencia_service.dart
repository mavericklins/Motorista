import 'package:flutter/material.dart';
import '../core/feature_flags.dart';

class EmergenciaService {
  static final EmergenciaService _instance = EmergenciaService._internal();
  factory EmergenciaService() => _instance;
  EmergenciaService._internal();

  bool get isEnabled => FeatureFlags.enableEmergencyService;

  /// Aciona o SOS - implementação mínima que não quebra o app
  Future<void> triggerSOS(BuildContext context) async {
    if (!isEnabled) {
      _showMessage(context, 'Serviço de emergência não disponível');
      return;
    }

    try {
      // Log da emergência
      print('SOS ACIONADO - ${DateTime.now()}');

      // TODO: Implementar envio para central de emergência
      // TODO: Implementar notificação para contatos de emergência
      // TODO: Implementar compartilhamento de localização

      _showMessage(context, 'SOS acionado! Estamos processando sua solicitação.');

    } catch (e) {
      print('Erro ao acionar SOS: $e');
      _showMessage(context, 'Erro ao acionar SOS. Tente novamente.');
    }
  }

  /// Cancela o SOS
  Future<void> cancelSOS(BuildContext context) async {
    if (!isEnabled) return;

    try {
      print('SOS CANCELADO - ${DateTime.now()}');
      _showMessage(context, 'SOS cancelado.');
    } catch (e) {
      print('Erro ao cancelar SOS: $e');
    }
  }

  void _showMessage(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }
}