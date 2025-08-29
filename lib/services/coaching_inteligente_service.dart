import 'package:flutter/foundation.dart';

class CoachingInteligenteService extends ChangeNotifier {
  Map<String, dynamic> _performanceAtual = {};
  List<Map<String, dynamic>> _dicasAtivas = [];
  Map<String, Map<String, dynamic>> _metasPersonalizadas = {};
  List<Map<String, dynamic>> _conquistasDesbloqueadas = [];

  Map<String, dynamic> get performanceAtual => _performanceAtual;
  List<Map<String, dynamic>> get dicasAtivas => _dicasAtivas;
  Map<String, Map<String, dynamic>> get metasPersonalizadas => _metasPersonalizadas;
  List<Map<String, dynamic>> get conquistasDesbloqueadas => _conquistasDesbloqueadas;

  Future<void> inicializarCoaching() async {
    // Simular dados de performance
    _performanceAtual = {
      'totalCorridas': 45,
      'totalGanhos': 850.50,
      'avaliacaoMedia': 4.7,
      'mediaDiaria': 42.52,
    };

    // Simular dicas
    _dicasAtivas = [
      {
        'icone': '💡',
        'titulo': 'Horário de pico',
        'descricao': 'Trabalhe entre 18h-20h para aumentar ganhos em 40%',
        'prioridade': 'alta',
        'acao': 'Ver detalhes',
      },
      {
        'icone': '🚗',
        'titulo': 'Região estratégica',
        'descricao': 'Centro da cidade tem 60% mais demanda',
        'prioridade': 'media',
        'acao': 'Navegar',
      },
    ];

    // Simular metas
    _metasPersonalizadas = {
      'ganhos_diarios': {
        'valor': 150.0,
        'prazo': DateTime.now().add(Duration(days: 30)),
        'progresso': 68.5,
      },
      'corridas_diarias': {
        'valor': 12.0,
        'prazo': DateTime.now().add(Duration(days: 7)),
        'progresso': 75.0,
      },
    };

    // Simular conquistas
    _conquistasDesbloqueadas = [
      {
        'icone': '🏆',
        'titulo': '50 Corridas',
        'descricao': 'Completou 50 corridas com sucesso',
        'pontos': 100,
      },
      {
        'icone': '⭐',
        'titulo': 'Avaliação 5.0',
        'descricao': 'Manteve avaliação perfeita por uma semana',
        'pontos': 200,
      },
    ];

    notifyListeners();
  }

  void marcarDicaComoVista(int index) {
    if (index >= 0 && index < _dicasAtivas.length) {
      _dicasAtivas.removeAt(index);
      notifyListeners();
    }
  }

  Future<void> criarMetaPersonalizada(String tipo, double valor, DateTime prazo) async {
    _metasPersonalizadas[tipo] = {
      'valor': valor,
      'prazo': prazo,
      'progresso': 0.0,
    };
    notifyListeners();
  }
}