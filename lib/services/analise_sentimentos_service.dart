
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AnaliseSentimentosService extends ChangeNotifier {
  static final AnaliseSentimentosService _instance = AnaliseSentimentosService._internal();
  factory AnaliseSentimentosService() => _instance;
  AnaliseSentimentosService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Map<String, dynamic> _sentimentoAtual = {};
  List<Map<String, dynamic>> _historicoSentimentos = [];
  Map<String, dynamic> _sugestoesMelhoria = {};
  double _pontuacaoGeral = 0.0;

  // Getters
  Map<String, dynamic> get sentimentoAtual => _sentimentoAtual;
  List<Map<String, dynamic>> get historicoSentimentos => _historicoSentimentos;
  Map<String, dynamic> get sugestoesMelhoria => _sugestoesMelhoria;
  double get pontuacaoGeral => _pontuacaoGeral;

  // Analisar sentimento baseado em feedback
  Future<void> analisarSentimentoViagem(Map<String, dynamic> dadosViagem) async {
    try {
      final avaliacao = dadosViagem['avaliacaoPassageiro'] as double? ?? 0;
      final comentario = dadosViagem['comentario'] as String? ?? '';
      final tempoViagem = dadosViagem['tempoViagem'] as int? ?? 0;
      final cancelamentos = dadosViagem['cancelamentos'] as int? ?? 0;

      // Análise baseada em múltiplos fatores
      Map<String, double> scores = {
        'satisfacao': _calcularSatisfacao(avaliacao, comentario),
        'pontualidade': _calcularPontualidade(tempoViagem),
        'confiabilidade': _calcularConfiabilidade(cancelamentos),
        'comunicacao': _calcularComunicacao(comentario),
        'conforto': _calcularConforto(avaliacao, comentario),
      };

      // Sentimento geral
      double sentimentoGeral = scores.values.reduce((a, b) => a + b) / scores.length;
      
      _sentimentoAtual = {
        'data': DateTime.now(),
        'sentimentoGeral': sentimentoGeral,
        'scores': scores,
        'nivel': _obterNivelSentimento(sentimentoGeral),
        'recomendacoes': _gerarRecomendacoes(scores),
      };

      _historicoSentimentos.insert(0, _sentimentoAtual);
      
      // Manter apenas os últimos 50 registros
      if (_historicoSentimentos.length > 50) {
        _historicoSentimentos = _historicoSentimentos.take(50).toList();
      }

      await _atualizarPontuacaoGeral();
      await _gerarSugestoesMelhoria();
      await _salvarAnalise();

      notifyListeners();
    } catch (e) {
      print('Erro ao analisar sentimento: $e');
    }
  }

  // Calcular satisfação baseada em avaliação e comentários
  double _calcularSatisfacao(double avaliacao, String comentario) {
    double scorePorAvaliacao = (avaliacao / 5.0) * 100;
    
    // Análise básica de sentimento no comentário
    double scorePorComentario = 50.0; // neutro por padrão
    
    if (comentario.isNotEmpty) {
      List<String> palavrasPositivas = [
        'excelente', 'ótimo', 'bom', 'educado', 'pontual', 'limpo', 
        'confortável', 'recomendo', 'profissional', 'simpático'
      ];
      
      List<String> palavrasNegativas = [
        'ruim', 'péssimo', 'atrasado', 'sujo', 'mal educado', 
        'grosso', 'demorado', 'desconfortável', 'não recomendo'
      ];

      String comentarioLower = comentario.toLowerCase();
      int positivas = palavrasPositivas.where((p) => comentarioLower.contains(p)).length;
      int negativas = palavrasNegativas.where((p) => comentarioLower.contains(p)).length;

      if (positivas > negativas) {
        scorePorComentario = 80.0;
      } else if (negativas > positivas) {
        scorePorComentario = 30.0;
      }
    }

    return (scorePorAvaliacao + scorePorComentario) / 2;
  }

  // Calcular pontualidade
  double _calcularPontualidade(int tempoViagem) {
    // Tempos esperados baseados na distância (seria melhor calcular dinamicamente)
    int tempoEsperado = 15; // minutos médios
    
    if (tempoViagem <= tempoEsperado) {
      return 100.0;
    } else if (tempoViagem <= tempoEsperado * 1.2) {
      return 80.0;
    } else if (tempoViagem <= tempoEsperado * 1.5) {
      return 60.0;
    } else {
      return 40.0;
    }
  }

  // Calcular confiabilidade
  double _calcularConfiabilidade(int cancelamentos) {
    if (cancelamentos == 0) return 100.0;
    if (cancelamentos <= 2) return 80.0;
    if (cancelamentos <= 5) return 60.0;
    return 40.0;
  }

  // Calcular comunicação
  double _calcularComunicacao(String comentario) {
    if (comentario.isEmpty) return 70.0; // neutro
    
    List<String> indicadoresComunicacao = [
      'comunicativo', 'informativo', 'educado', 'prestativo',
      'silencioso', 'não falou', 'mal educado', 'grosso'
    ];

    String comentarioLower = comentario.toLowerCase();
    bool temIndicadores = indicadoresComunicacao.any((i) => comentarioLower.contains(i));
    
    if (temIndicadores) {
      if (comentarioLower.contains('educado') || comentarioLower.contains('prestativo')) {
        return 90.0;
      } else {
        return 50.0;
      }
    }
    
    return 70.0;
  }

  // Calcular conforto
  double _calcularConforto(double avaliacao, String comentario) {
    double scoreBase = (avaliacao / 5.0) * 100;
    
    String comentarioLower = comentario.toLowerCase();
    if (comentarioLower.contains('confortável') || comentarioLower.contains('limpo')) {
      scoreBase += 10;
    } else if (comentarioLower.contains('desconfortável') || comentarioLower.contains('sujo')) {
      scoreBase -= 20;
    }
    
    return scoreBase.clamp(0, 100);
  }

  // Obter nível do sentimento
  String _obterNivelSentimento(double score) {
    if (score >= 80) return 'Muito Positivo';
    if (score >= 65) return 'Positivo';
    if (score >= 50) return 'Neutro';
    if (score >= 35) return 'Negativo';
    return 'Muito Negativo';
  }

  // Gerar recomendações baseadas nos scores
  List<String> _gerarRecomendacoes(Map<String, double> scores) {
    List<String> recomendacoes = [];
    
    if (scores['satisfacao']! < 70) {
      recomendacoes.add('Melhore o atendimento ao cliente - seja mais cordial e prestativo');
    }
    
    if (scores['pontualidade']! < 70) {
      recomendacoes.add('Chegue mais rápido ao destino - use rotas otimizadas');
    }
    
    if (scores['confiabilidade']! < 70) {
      recomendacoes.add('Evite cancelamentos - aceite apenas corridas que pode cumprir');
    }
    
    if (scores['comunicacao']! < 70) {
      recomendacoes.add('Seja mais comunicativo - cumprimente e mantenha educação');
    }
    
    if (scores['conforto']! < 70) {
      recomendacoes.add('Mantenha o veículo limpo e confortável');
    }
    
    return recomendacoes;
  }

  // Atualizar pontuação geral
  Future<void> _atualizarPontuacaoGeral() async {
    if (_historicoSentimentos.isEmpty) return;
    
    // Média ponderada dos últimos 10 sentimentos (mais recentes têm mais peso)
    double somaPonderada = 0;
    double somaPesos = 0;
    
    for (int i = 0; i < _historicoSentimentos.length && i < 10; i++) {
      double peso = 1.0 - (i * 0.1); // peso decresce com a idade
      double sentimento = _historicoSentimentos[i]['sentimentoGeral'] ?? 0;
      
      somaPonderada += sentimento * peso;
      somaPesos += peso;
    }
    
    _pontuacaoGeral = somaPesos > 0 ? somaPonderada / somaPesos : 0;
  }

  // Gerar sugestões de melhoria
  Future<void> _gerarSugestoesMelhoria() async {
    Map<String, int> problemasFrequentes = {};
    
    // Analisar problemas mais frequentes
    for (var sentimento in _historicoSentimentos.take(20)) {
      final recomendacoes = sentimento['recomendacoes'] as List<String>? ?? [];
      for (var recomendacao in recomendacoes) {
        problemasFrequentes[recomendacao] = (problemasFrequentes[recomendacao] ?? 0) + 1;
      }
    }
    
    // Ordenar por frequência
    var problemasOrdenados = problemasFrequentes.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    _sugestoesMelhoria = {
      'principaisPontosMelhoria': problemasOrdenados.take(3).map((e) => e.key).toList(),
      'tendencia': _calcularTendencia(),
      'proximaMeta': _definirProximaMeta(),
    };
  }

  // Calcular tendência dos sentimentos
  String _calcularTendencia() {
    if (_historicoSentimentos.length < 5) return 'Dados insuficientes';
    
    List<double> ultimosCinco = _historicoSentimentos
        .take(5)
        .map((s) => s['sentimentoGeral'] as double)
        .toList();
    
    double mediaRecente = ultimosCinco.reduce((a, b) => a + b) / ultimosCinco.length;
    
    List<double> cincoanterior = _historicoSentimentos
        .skip(5)
        .take(5)
        .map((s) => s['sentimentoGeral'] as double)
        .toList();
    
    if (cincoanterior.isEmpty) return 'Melhorando';
    
    double mediaAnterior = cincoanterior.reduce((a, b) => a + b) / cincoanterior.length;
    
    double diferenca = mediaRecente - mediaAnterior;
    
    if (diferenca > 5) return 'Melhorando';
    if (diferenca < -5) return 'Piorando';
    return 'Estável';
  }

  // Definir próxima meta
  String _definirProximaMeta() {
    if (_pontuacaoGeral >= 90) {
      return 'Manter excelência no atendimento';
    } else if (_pontuacaoGeral >= 70) {
      return 'Aumentar pontuação para 90+';
    } else {
      return 'Focar em melhorar atendimento básico';
    }
  }

  // Obter insights por período
  Map<String, dynamic> obterInsightsPorPeriodo(DateTime inicio, DateTime fim) {
    var sentimentosPeriodo = _historicoSentimentos.where((s) {
      DateTime data = s['data'] as DateTime;
      return data.isAfter(inicio) && data.isBefore(fim);
    }).toList();

    if (sentimentosPeriodo.isEmpty) {
      return {'erro': 'Nenhum dado no período'};
    }

    double mediaPeriodo = sentimentosPeriodo
        .map((s) => s['sentimentoGeral'] as double)
        .reduce((a, b) => a + b) / sentimentosPeriodo.length;

    return {
      'mediaPeriodo': mediaPeriodo,
      'totalAvaliacoes': sentimentosPeriodo.length,
      'melhorDia': _encontrarMelhorDia(sentimentosPeriodo),
      'piorDia': _encontrarPiorDia(sentimentosPeriodo),
    };
  }

  DateTime? _encontrarMelhorDia(List<Map<String, dynamic>> sentimentos) {
    if (sentimentos.isEmpty) return null;
    
    var melhor = sentimentos.reduce((a, b) => 
        a['sentimentoGeral'] > b['sentimentoGeral'] ? a : b);
    
    return melhor['data'] as DateTime;
  }

  DateTime? _encontrarPiorDia(List<Map<String, dynamic>> sentimentos) {
    if (sentimentos.isEmpty) return null;
    
    var pior = sentimentos.reduce((a, b) => 
        a['sentimentoGeral'] < b['sentimentoGeral'] ? a : b);
    
    return pior['data'] as DateTime;
  }

  // Salvar análise no Firebase
  Future<void> _salvarAnalise() async {
    try {
      final motoristaId = _auth.currentUser?.uid;
      if (motoristaId == null) return;

      await _firestore
          .collection('motoristas')
          .doc(motoristaId)
          .collection('analise_sentimentos')
          .add({
        'sentimento': _sentimentoAtual,
        'pontuacaoGeral': _pontuacaoGeral,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Erro ao salvar análise: $e');
    }
  }
}
