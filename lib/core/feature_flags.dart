/// Sistema de feature flags para funcionalidades em desenvolvimento
class FeatureFlags {
  // Funcionalidades experimentais
  static const bool enableVoiceAssistant = false;
  static const bool enableEcoDrive = false;
  static const bool enableVirtualQueue = false;
  static const bool enableSmartRoutes = false;
  static const bool enableDemandPrediction = true;
  static const bool enableAdvancedAnalytics = true;
  static const bool enableEcoDriving = true;
  static const bool enableGamification = true;

  // Serviços não ativos
  static const bool enableSentimentAnalysis = false;
  static const bool enableCashback = false;
  static const bool enableIntelligentCoaching = false;
  static const bool enableEmergencyService = true; // Manter ativo para SOS

  /// Verifica se uma feature está habilitada
  static bool isEnabled(String feature) {
    switch (feature) {
      case 'voice_assistant':
        return enableVoiceAssistant;
      case 'eco_drive':
        return enableEcoDrive;
      case 'virtual_queue':
        return enableVirtualQueue;
      case 'smart_routes':
        return enableSmartRoutes;
      case 'demand_prediction':
        return enableDemandPrediction;
      case 'advanced_analytics':
        return enableAdvancedAnalytics;
      case 'eco_driving':
        return enableEcoDriving;
      case 'gamification':
        return enableGamification;
      case 'sentiment_analysis':
        return enableSentimentAnalysis;
      case 'cashback':
        return enableCashback;
      case 'intelligent_coaching':
        return enableIntelligentCoaching;
      case 'emergency_service':
        return enableEmergencyService;
      default:
        return false;
    }
  }
}