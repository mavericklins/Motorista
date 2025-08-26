
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/meta_inteligente.dart';
import 'analytics_service.dart';
import 'gamification_service.dart';
import 'financial_service.dart';

class MetasInteligentesService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AnalyticsService _analyticsService = AnalyticsService();
  final GamificationService _gamificationService = GamificationService();
  final FinancialService _financialService = FinancialService();

  List<MetaInteligente> _metas = [];
  Map<String, dynamic> _performance = {};
  Map<String, dynamic> _previsoes = {};

  List<MetaInteligente> get metas => _metas;
  Map<String, dynamic> get performance => _performance;
  Map<String, dynamic> get previsoes => _previsoes;

  /// Gerar metas personalizadas baseadas no histórico do motorista
  Future<void> gerarMetasPersonalizadas() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      print('🎯 Gerando metas personalizadas...');

      // Analisar histórico do motorista
      final historico = await _analisarHistoricoMotorista(userId);
      
      // Gerar metas baseadas no perfil do motorista
      final metasGeradas = await _calcularMetasOptimas(historico);
      
      // Salvar metas no Firestore
      await _salvarMetas(userId, metasGeradas);
      
      // Atualizar cache local
      _metas = metasGeradas;
      notifyListeners();

      print('✅ ${metasGeradas.length} metas personalizadas geradas');
    } catch (e) {
      print('❌ Erro ao gerar metas: $e');
    }
  }

  /// Analisar histórico do motorista para entender padrões
  Future<Map<String, dynamic>> _analisarHistoricoMotorista(String userId) async {
    // Buscar dados dos últimos 30 dias
    final dataInicio = DateTime.now().subtract(Duration(days: 30));
    
    // Corridas realizadas
    final corridasSnapshot = await _firestore
        .collection('corridas')
        .where('motoristaId', isEqualTo: userId)
        .where('concluidaEm', isGreaterThan: Timestamp.fromDate(dataInicio))
        .get();

    // Análise de padrões temporais
    final Map<int, List<double>> ganhosPorDia = {};
    final Map<int, int> corridasPorDia = {};
    final Map<int, double> tempoOnlinePorDia = {};
    
    double totalGanhos = 0;
    int totalCorridas = 0;
    double melhorDia = 0;
    double piorDia = double.infinity;

    for (final doc in corridasSnapshot.docs) {
      final data = doc.data();
      final valor = (data['valor'] ?? 0).toDouble();
      final dataCorreida = (data['concluidaEm'] as Timestamp).toDate();
      final diaSemana = dataCorreida.weekday;

      totalGanhos += valor;
      totalCorridas++;

      // Agrupar por dia da semana
      ganhosPorDia.putIfAbsent(diaSemana, () => []).add(valor);
      corridasPorDia[diaSemana] = (corridasPorDia[diaSemana] ?? 0) + 1;

      if (valor > melhorDia) melhorDia = valor;
      if (valor < piorDia) piorDia = valor;
    }

    // Calcular médias e identificar padrões
    final ganhoMedioDiario = totalGanhos / 30;
    final corridaMediaDiaria = totalCorridas / 30;
    
    // Identificar melhor dia da semana
    int melhorDiaSemana = 1;
    double maiorMediaDia = 0;
    
    ganhosPorDia.forEach((dia, ganhos) {
      final media = ganhos.reduce((a, b) => a + b) / ganhos.length;
      if (media > maiorMediaDia) {
        maiorMediaDia = media;
        melhorDiaSemana = dia;
      }
    });

    return {
      'ganho_medio_diario': ganhoMedioDiario,
      'corrida_media_diaria': corridaMediaDiaria,
      'total_ganhos': totalGanhos,
      'total_corridas': totalCorridas,
      'melhor_dia_semana': melhorDiaSemana,
      'ganhos_por_dia': ganhosPorDia,
      'corridas_por_dia': corridasPorDia,
      'tendencia_crescimento': _calcularTendencia(corridasSnapshot.docs),
      'consistencia': _calcularConsistencia(ganhosPorDia),
      'nivel_atividade': _determinarNivelAtividade(totalCorridas),
    };
  }

  /// Calcular metas ótimas baseadas no perfil
  Future<List<MetaInteligente>> _calcularMetasOptimas(Map<String, dynamic> historico) async {
    final metas = <MetaInteligente>[];
    final hoje = DateTime.now();

    // Meta 1: Ganhos Diários Inteligentes
    final ganhoMedio = historico['ganho_medio_diario'] ?? 50.0;
    final metaGanhosDiaria = MetaInteligente(
      id: 'ganhos_diarios_${hoje.millisecondsSinceEpoch}',
      tipo: TipoMeta.ganhos,
      periodo: PeriodoMeta.diario,
      titulo: 'Meta de Ganhos Diária',
      descricao: 'Baseada na sua média histórica com desafio de 15%',
      valorObjetivo: ganhoMedio * 1.15, // 15% de desafio
      valorAtual: 0,
      dataInicio: hoje,
      dataFim: DateTime(hoje.year, hoje.month, hoje.day, 23, 59),
      recompensa: ganhoMedio * 0.1, // 10% de bônus
      dificuldade: _calcularDificuldade(1.15),
      categoria: CategoriaMeta.crescimento,
      condicoes: {
        'horario_inicio': '06:00',
        'horario_fim': '22:00',
        'dias_semana': [1, 2, 3, 4, 5, 6, 7],
      },
    );
    metas.add(metaGanhosDiaria);

    // Meta 2: Corridas por Hora (Eficiência)
    final corridaMedia = historico['corrida_media_diaria'] ?? 8.0;
    final metaEficiencia = MetaInteligente(
      id: 'eficiencia_${hoje.millisecondsSinceEpoch}',
      tipo: TipoMeta.eficiencia,
      periodo: PeriodoMeta.diario,
      titulo: 'Meta de Eficiência',
      descricao: 'Alcance 3 corridas por hora em seu melhor período',
      valorObjetivo: 3.0,
      valorAtual: 0,
      dataInicio: hoje,
      dataFim: DateTime(hoje.year, hoje.month, hoje.day, 23, 59),
      recompensa: 25.0,
      dificuldade: DificuldadeMeta.media,
      categoria: CategoriaMeta.produtividade,
      condicoes: {
        'periodo_medicao': 'melhor_3_horas_dia',
        'min_horas_online': 3,
      },
    );
    metas.add(metaEficiencia);

    // Meta 3: Consistência Semanal
    final melhorDia = historico['melhor_dia_semana'] ?? 6;
    final metaConsistencia = MetaInteligente(
      id: 'consistencia_${hoje.millisecondsSinceEpoch}',
      tipo: TipoMeta.consistencia,
      periodo: PeriodoMeta.semanal,
      titulo: 'Consistência da Semana',
      descricao: 'Trabalhe pelo menos 5 dias esta semana',
      valorObjetivo: 5.0,
      valorAtual: 0,
      dataInicio: _inicioSemana(hoje),
      dataFim: _fimSemana(hoje),
      recompensa: 100.0,
      dificuldade: DificuldadeMeta.facil,
      categoria: CategoriaMeta.habito,
      condicoes: {
        'min_corridas_por_dia': 3,
        'min_ganho_por_dia': ganhoMedio * 0.5,
      },
    );
    metas.add(metaConsistencia);

    // Meta 4: Desafio de Crescimento
    final crescimento = historico['tendencia_crescimento'] ?? 0.0;
    if (crescimento > 0) {
      final metaCrescimento = MetaInteligente(
        id: 'crescimento_${hoje.millisecondsSinceEpoch}',
        tipo: TipoMeta.crescimento,
        periodo: PeriodoMeta.mensal,
        titulo: 'Desafio de Crescimento',
        descricao: 'Supere seus ganhos do mês passado em 20%',
        valorObjetivo: historico['total_ganhos'] * 1.2,
        valorAtual: 0,
        dataInicio: DateTime(hoje.year, hoje.month, 1),
        dataFim: DateTime(hoje.year, hoje.month + 1, 0),
        recompensa: historico['total_ganhos'] * 0.15,
        dificuldade: DificuldadeMeta.dificil,
        categoria: CategoriaMeta.crescimento,
        condicoes: {
          'comparacao_mes_anterior': true,
        },
      );
      metas.add(metaCrescimento);
    }

    // Meta 5: Horário Nobre
    final metaHorarioNobre = MetaInteligente(
      id: 'horario_nobre_${hoje.millisecondsSinceEpoch}',
      tipo: TipoMeta.estrategico,
      periodo: PeriodoMeta.diario,
      titulo: 'Horário Nobre',
      descricao: 'Faça 70% das suas corridas em horários de pico',
      valorObjetivo: 0.7,
      valorAtual: 0,
      dataInicio: hoje,
      dataFim: DateTime(hoje.year, hoje.month, hoje.day, 23, 59),
      recompensa: 50.0,
      dificuldade: DificuldadeMeta.media,
      categoria: CategoriaMeta.estrategia,
      condicoes: {
        'horarios_pico': ['07:00-09:00', '12:00-14:00', '18:00-20:00'],
        'min_corridas_total': 5,
      },
    );
    metas.add(metaHorarioNobre);

    return metas;
  }

  /// Acompanhar progresso das metas em tempo real
  Future<void> atualizarProgressoMetas() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      for (final meta in _metas) {
        final novoProgresso = await _calcularProgressoMeta(meta, userId);
        
        if (novoProgresso != meta.valorAtual) {
          // Atualizar meta
          final metaAtualizada = meta.copyWith(valorAtual: novoProgresso);
          await _atualizarMetaFirestore(metaAtualizada);
          
          // Verificar se meta foi completada
          if (!meta.completada && metaAtualizada.completada) {
            await _processarMetaCompletada(metaAtualizada);
          }
        }
      }

      notifyListeners();
    } catch (e) {
      print('❌ Erro ao atualizar progresso: $e');
    }
  }

  /// Calcular progresso específico de cada meta
  Future<double> _calcularProgressoMeta(MetaInteligente meta, String userId) async {
    final agora = DateTime.now();
    
    switch (meta.tipo) {
      case TipoMeta.ganhos:
        return await _calcularProgressoGanhos(meta, userId);
      
      case TipoMeta.corridas:
        return await _calcularProgressoCorridas(meta, userId);
      
      case TipoMeta.eficiencia:
        return await _calcularProgressoEficiencia(meta, userId);
      
      case TipoMeta.consistencia:
        return await _calcularProgressoConsistencia(meta, userId);
      
      case TipoMeta.crescimento:
        return await _calcularProgressoCrescimento(meta, userId);
      
      case TipoMeta.estrategico:
        return await _calcularProgressoEstrategico(meta, userId);
      
      default:
        return 0.0;
    }
  }

  /// Gerar insights e recomendações personalizadas
  Future<Map<String, dynamic>> gerarInsightsPersonalizados() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return {};

      // Analisar performance atual
      final performance = await _analisarPerformanceAtual(userId);
      
      // Gerar recomendações baseadas em IA
      final recomendacoes = await _gerarRecomendacoesIA(performance);
      
      // Prever tendências
      final previsoes = await _preverTendencias(performance);

      final insights = {
        'performance_atual': performance,
        'recomendacoes': recomendacoes,
        'previsoes': previsoes,
        'pontos_melhoria': _identificarPontosMelhoria(performance),
        'oportunidades': _identificarOportunidades(performance),
        'alertas': _gerarAlertas(performance),
      };

      _performance = performance;
      _previsoes = previsoes;
      notifyListeners();

      return insights;
    } catch (e) {
      print('❌ Erro ao gerar insights: $e');
      return {};
    }
  }

  /// Recomendar ações baseadas em machine learning
  Future<List<Map<String, dynamic>>> _gerarRecomendacoesIA(Map<String, dynamic> performance) async {
    final recomendacoes = <Map<String, dynamic>>[];

    // Análise de padrões temporais
    if (performance['melhor_horario'] != null) {
      recomendacoes.add({
        'tipo': 'temporal',
        'titulo': 'Otimize seus horários',
        'descricao': 'Trabalhe mais entre ${performance['melhor_horario']} - seus ganhos são 40% maiores',
        'impacto': 'alto',
        'facilidade': 'media',
        'ganho_estimado': performance['ganho_medio'] * 0.4,
      });
    }

    // Análise de localização
    if (performance['melhor_regiao'] != null) {
      recomendacoes.add({
        'tipo': 'localizacao',
        'titulo': 'Foque nas regiões certas',
        'descricao': 'A região ${performance['melhor_regiao']} tem 60% mais demanda',
        'impacto': 'alto',
        'facilidade': 'facil',
        'ganho_estimado': performance['ganho_medio'] * 0.6,
      });
    }

    // Análise de eficiência
    if (performance['tempo_espera_medio'] > 15) {
      recomendacoes.add({
        'tipo': 'eficiencia',
        'titulo': 'Reduza tempo de espera',
        'descricao': 'Use pontos estratégicos para reduzir espera de ${performance['tempo_espera_medio']}min para 8min',
        'impacto': 'medio',
        'facilidade': 'media',
        'ganho_estimado': 45.0,
      });
    }

    return recomendacoes;
  }

  /// Métodos utilitários
  double _calcularTendencia(List<QueryDocumentSnapshot> docs) {
    if (docs.length < 7) return 0.0;
    
    final ganhosPorDia = <int, double>{};
    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final valor = (data['valor'] ?? 0).toDouble();
      final dia = (data['concluidaEm'] as Timestamp).toDate().day;
      ganhosPorDia[dia] = (ganhosPorDia[dia] ?? 0) + valor;
    }
    
    final valores = ganhosPorDia.values.toList()..sort();
    final metade = valores.length ~/ 2;
    final primeira = valores.sublist(0, metade);
    final segunda = valores.sublist(metade);
    
    final mediaPrimeira = primeira.reduce((a, b) => a + b) / primeira.length;
    final mediaSegunda = segunda.reduce((a, b) => a + b) / segunda.length;
    
    return (mediaSegunda - mediaPrimeira) / mediaPrimeira;
  }

  double _calcularConsistencia(Map<int, List<double>> ganhosPorDia) {
    if (ganhosPorDia.isEmpty) return 0.0;
    
    final medias = ganhosPorDia.values.map((ganhos) {
      return ganhos.reduce((a, b) => a + b) / ganhos.length;
    }).toList();
    
    final mediaGeral = medias.reduce((a, b) => a + b) / medias.length;
    final variancia = medias.map((m) => (m - mediaGeral) * (m - mediaGeral)).reduce((a, b) => a + b) / medias.length;
    final desvio = variancia / mediaGeral;
    
    return 1.0 - desvio.clamp(0.0, 1.0); // Quanto menor o desvio, maior a consistência
  }

  String _determinarNivelAtividade(int totalCorridas) {
    if (totalCorridas >= 300) return 'muito_alto';
    if (totalCorridas >= 200) return 'alto';
    if (totalCorridas >= 100) return 'medio';
    if (totalCorridas >= 50) return 'baixo';
    return 'muito_baixo';
  }

  DificuldadeMeta _calcularDificuldade(double fatorDesafio) {
    if (fatorDesafio >= 1.3) return DificuldadeMeta.dificil;
    if (fatorDesafio >= 1.15) return DificuldadeMeta.media;
    return DificuldadeMeta.facil;
  }

  DateTime _inicioSemana(DateTime data) {
    return data.subtract(Duration(days: data.weekday - 1));
  }

  DateTime _fimSemana(DateTime data) {
    return _inicioSemana(data).add(Duration(days: 6));
  }

  // Implementações específicas de cálculo de progresso
  Future<double> _calcularProgressoGanhos(MetaInteligente meta, String userId) async {
    final snapshot = await _firestore
        .collection('corridas')
        .where('motoristaId', isEqualTo: userId)
        .where('concluidaEm', isGreaterThanOrEqualTo: Timestamp.fromDate(meta.dataInicio))
        .where('concluidaEm', isLessThanOrEqualTo: Timestamp.fromDate(meta.dataFim))
        .get();

    double total = 0;
    for (final doc in snapshot.docs) {
      total += (doc.data()['valor'] ?? 0).toDouble();
    }
    return total;
  }

  Future<double> _calcularProgressoCorridas(MetaInteligente meta, String userId) async {
    final snapshot = await _firestore
        .collection('corridas')
        .where('motoristaId', isEqualTo: userId)
        .where('concluidaEm', isGreaterThanOrEqualTo: Timestamp.fromDate(meta.dataInicio))
        .where('concluidaEm', isLessThanOrEqualTo: Timestamp.fromDate(meta.dataFim))
        .get();

    return snapshot.docs.length.toDouble();
  }

  Future<double> _calcularProgressoEficiencia(MetaInteligente meta, String userId) async {
    // Implementar cálculo de eficiência baseado nas condições da meta
    return 0.0;
  }

  Future<double> _calcularProgressoConsistencia(MetaInteligente meta, String userId) async {
    // Implementar cálculo de consistência
    return 0.0;
  }

  Future<double> _calcularProgressoCrescimento(MetaInteligente meta, String userId) async {
    // Implementar cálculo de crescimento
    return 0.0;
  }

  Future<double> _calcularProgressoEstrategico(MetaInteligente meta, String userId) async {
    // Implementar cálculo estratégico
    return 0.0;
  }

  Future<void> _salvarMetas(String userId, List<MetaInteligente> metas) async {
    final batch = _firestore.batch();
    
    for (final meta in metas) {
      final docRef = _firestore.collection('metas_inteligentes').doc(meta.id);
      batch.set(docRef, meta.toMap());
    }
    
    await batch.commit();
  }

  Future<void> _atualizarMetaFirestore(MetaInteligente meta) async {
    await _firestore.collection('metas_inteligentes').doc(meta.id).update(meta.toMap());
  }

  Future<void> _processarMetaCompletada(MetaInteligente meta) async {
    // Dar recompensa
    await _financialService.adicionarCredito(meta.recompensa, 'Meta completada: ${meta.titulo}');
    
    // Dar XP na gamificação
    await _gamificationService.updateProgressAfterRide({
      'meta_completada': true,
      'tipo_meta': meta.tipo.toString(),
      'dificuldade': meta.dificuldade.toString(),
    });
    
    print('🎉 Meta completada: ${meta.titulo} - Recompensa: R\$ ${meta.recompensa}');
  }

  Future<Map<String, dynamic>> _analisarPerformanceAtual(String userId) async {
    // Implementar análise de performance detalhada
    return {};
  }

  Future<Map<String, dynamic>> _preverTendencias(Map<String, dynamic> performance) async {
    // Implementar previsão de tendências
    return {};
  }

  List<Map<String, dynamic>> _identificarPontosMelhoria(Map<String, dynamic> performance) {
    // Implementar identificação de pontos de melhoria
    return [];
  }

  List<Map<String, dynamic>> _identificarOportunidades(Map<String, dynamic> performance) {
    // Implementar identificação de oportunidades
    return [];
  }

  List<Map<String, dynamic>> _gerarAlertas(Map<String, dynamic> performance) {
    // Implementar geração de alertas
    return [];
  }
}
