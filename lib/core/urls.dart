
/// URLs centralizadas do projeto
class AppUrls {
  // Firebase
  static const String firebaseStorageBase = 'https://firebasestorage.googleapis.com/v0/b/';
  
  // APIs externas
  static const String geoapifyBase = 'https://api.geoapify.com/v1/';
  
  // Suporte e documentação
  static const String helpCenter = 'https://vello.com.br/ajuda'; // TODO: Verificar URL válida
  static const String privacyPolicy = 'https://vello.com.br/privacidade'; // TODO: Verificar URL válida
  static const String termsOfService = 'https://vello.com.br/termos'; // TODO: Verificar URL válida
  
  // Contato
  static const String supportEmail = 'suporte@vello.com.br';
  static const String supportPhone = '+55 11 9999-9999'; // TODO: Número real
  
  /// Valida se uma URL está acessível
  static bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }
}
