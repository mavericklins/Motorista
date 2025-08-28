import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CoachingInteligenteService extends ChangeNotifier {
  static final CoachingInteligenteService _instance = CoachingInteligenteService._internal();
  factory CoachingInteligenteService() => _instance;
  CoachingInteligenteService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Map<String, dynamic>> _dicasAtivas = [];
  Map<String, dynamic> _performanceAtual = {};
  Map<String, dynamic> _metasPersonalizadas = {};
  List<Map<String, dynamic>> _conquistasDesbloqueadas = [];

  // Getters
  List<Map<String, dynamic>> get dicasAtivas => _dicasAtivas;
  Map<String, dynamic> get performanceAtual => _performanceAtual;
  Map<String, dynamic> get metasPersonalizadas => _metasPersonalizadas;
  List<Map<String, dynamic>> get conquistasDesbloqueadas => _conquistasDesbloqueadas;

  // Inicializar coaching
  Future<void> inicializarCoaching() async {
    await _carregarPerformanceAtual();
    await _carregarMetasPersonalizadas();
    await _gerarDicasPersonalizadas();
    await _verificarConquistas();
  }

  // Carregar performance atual do motorista
  Future<void> _carregarPerformanceAtual() async {
    try {
      final motoristaId = _auth.currentUser?.uid;
      if (motoristaId == null) return;

      // Buscar dados dos últimos 30 dias
      final agora = DateTime.now();
      final inicioMes = DateTime(agora.year, agora.month, 1);

      final corridasQuery = await _firestore
          .collection('corridas')
          .where('motoristaId', isEqualTo: motoristaId)
          .where('status', isEqualTo: 'concluida')
          .where('dataInicio', isGreaterThanOrEqualTo: inicioMes)
          .get();

      double totalGanhos = 0;
      double totalDistancia = 0;
      int totalCorridas = corridasQuery.docs.length;
      double totalTempo = 0;
      int avaliacoesBoas = 0;
      double somaAvaliacoes = 0;

      for (var doc in corridasQuery.docs) {
        final data = doc.data();
        totalGanhos += (data['valor'] as num?)?.toDouble() ?? 0;
        totalDistancia += (data['distancia'] as num?)?.toDouble() ?? 0;
        totalTempo += (data['tempoViagem'] as num?)?.toDouble() ?? 0;

        final avaliacao = (data['avaliacaoPassageiro'] as num?)?.toDouble() ?? 0;
        if (avaliacao > 0) {
          somaAvaliacoes += avaliacao;
          if (avaliacao >= 4.0) avaliacoesBoas++;
        }
      }

      _performanceAtual = {
        'totalCorridas': totalCorridas,
        'totalGanhos': totalGanhos,
        'mediaDiaria': totalCorridas > 0 ? totalGanhos / DateTime.now().day : 0,
        'avaliacaoMedia': totalCorridas > 0 ? somaAvaliacoes / totalCorridas : 0,
        'porcentagemAvaliacoesBoas': totalCorridas > 0 ? (avaliacoesBoas / totalCorridas) * 100 : 0,
        'tempoMedioViagem': totalCorridas > 0 ? totalTempo / totalCorridas : 0,
        'distanciaTotal': totalDistancia,
        'eficiencia': totalDistancia > 0 ? totalGanhos / totalDistancia : 0,
      };

      await _salvarPerformance();
      notifyListeners();
    } catch (e) {
      print('Erro ao carregar performance: $e');
    }
  }

  // Gerar dicas personalizadas baseadas na performance
  Future<void> _gerarDicasPersonalizadas() async {
    _dicasAtivas.clear();

    // Análise de ganhos
    if (_performanceAtual['mediaDiaria'] != null) {
      final mediaDiaria = _performanceAtual['mediaDiaria'] as double;

      if (mediaDiaria < 100) {
        _dicasAtivas.add({
          'tipo': 'ganhos',
          'prioridade': 'alta',
          'titulo': 'Aumente seus Ganhos Diários',
          'descricao': 'Sua média diária está abaixo do potencial. Tente focar nos horários de pico: 7h-9h e 17h-19h.',
          'acao': 'Ver Horários de Pico',
          'icone': '💰',
          'categoria': 'financeiro'
        });
      }
    }

    // Análise de avaliações
    if (_performanceAtual['avaliacaoMedia'] != null) {
      final avaliacaoMedia = _performanceAtual['avaliacaoMedia'] as double;

      if (avaliacaoMedia < 4.5) {
        _dicasAtivas.add({
          'tipo': 'avaliacao',
          'prioridade': 'media',
          'titulo': 'Melhore sua Avaliação',
          'descricao': 'Mantenha o veículo limpo, seja cordial e ofereça água/bala aos passageiros.',
          'acao': 'Dicas de Atendimento',
          'icone': '⭐',
          'categoria': 'atendimento'
        });
      }
    }

    // Análise de eficiência
    if (_performanceAtual['eficiencia'] != null) {
      final eficiencia = _performanceAtual['eficiencia'] as double;

      if (eficiencia < 2.0) {
        _dicasAtivas.add({
          'tipo': 'eficiencia',
          'prioridade': 'media',
          'titulo': 'Otimize suas Rotas',
          'descricao': 'Use o Waze integrado e evite trânsito pesado para maximizar ganhos por km.',
          'acao': 'Configurar Navegação',
          'icone': '🗺️',
          'categoria': 'operacional'
        });
      }
    }

    // Análise de bem-estar do motorista
    await _analisarBemEstar();

    // Dicas baseadas no horário atual
    final agora = DateTime.now();
    if (agora.hour >= 6 && agora.hour <= 9) {
      _dicasAtivas.add({
        'tipo': 'horario',
        'prioridade': 'baixa',
        'titulo': 'Horário de Pico Matinal',
        'descricao': 'Posicione-se próximo a estações de metrô e bairros residenciais.',
        'acao': 'Ver Pontos Estratégicos',
        'icone': '🌅',
        'categoria': 'estrategica'
      });
    }

    notifyListeners();
  }

  // Verificar conquistas desbloqueadas
  Future<void> _verificarConquistas() async {
    final novasConquistas = <Map<String, dynamic>>[];

    // Conquista: Primeiro Dia
    if (_performanceAtual['totalCorridas'] != null && _performanceAtual['totalCorridas'] >= 1) {
      novasConquistas.add({
        'id': 'primeira_corrida',
        'titulo': 'Primeira Viagem',
        'descricao': 'Completou sua primeira corrida!',
        'icone': '🚗',
        'pontos': 50,
        'desbloqueadaEm': DateTime.now(),
      });
    }

    // Conquista: 5 Estrelas
    if (_performanceAtual['avaliacaoMedia'] != null && _performanceAtual['avaliacaoMedia'] >= 4.8) {
      novasConquistas.add({
        'id': 'cinco_estrelas',
        'titulo': 'Motorista 5 Estrelas',
        'descricao': 'Mantém avaliação média acima de 4.8!',
        'icone': '🌟',
        'pontos': 200,
        'desbloqueadaEm': DateTime.now(),
      });
    }

    // Conquista: Meta Diária
    if (_performanceAtual['mediaDiaria'] != null && _performanceAtual['mediaDiaria'] >= 150) {
      novasConquistas.add({
        'id': 'meta_diaria',
        'titulo': 'Meta Batida',
        'descricao': 'Superou R\$ 150 de média diária!',
        'icone': '🎯',
        'pontos': 100,
        'desbloqueadaEm': DateTime.now(),
      });
    }

    _conquistasDesbloqueadas.addAll(novasConquistas);
    await _salvarConquistas();
    notifyListeners();
  }

  // Criar meta personalizada
  Future<void> criarMetaPersonalizada(String tipo, double valor, DateTime prazo) async {
    try {
      final meta = {
        'tipo': tipo, // 'ganhos_diarios', 'corridas_diarias', 'avaliacao_media'
        'valor': valor,
        'prazo': prazo,
        'criadaEm': DateTime.now(),
        'status': 'ativa',
        'progresso': 0.0,
      };

      _metasPersonalizadas[tipo] = meta;
      await _salvarMetas();

      // Gerar dica específica para a meta
      _dicasAtivas.add({
        'tipo': 'meta_personalizada',
        'prioridade': 'alta',
        'titulo': 'Nova Meta Criada',
        'descricao': 'Foque em ${_obterDescricaoMeta(tipo)} para atingir sua meta!',
        'acao': 'Ver Progresso',
        'icone': '🎯',
        'categoria': 'meta'
      });

      notifyListeners();
    } catch (e) {
      print('Erro ao criar meta: $e');
    }
  }

  String _obterDescricaoMeta(String tipo) {
    switch (tipo) {
      case 'ganhos_diarios': return 'maximizar seus ganhos diários';
      case 'corridas_diarias': return 'aumentar o número de corridas';
      case 'avaliacao_media': return 'melhorar o atendimento ao cliente';
      default: return 'sua meta';
    }
  }

  // Atualizar progresso das metas
  Future<void> atualizarProgressoMetas() async {
    for (final tipo in _metasPersonalizadas.keys) {
      final meta = _metasPersonalizadas[tipo]!;
      double progressoAtual = 0;

      switch (tipo) {
        case 'ganhos_diarios':
          progressoAtual = _performanceAtual['mediaDiaria'] ?? 0;
          break;
        case 'corridas_diarias':
          progressoAtual = (_performanceAtual['totalCorridas'] ?? 0) / DateTime.now().day;
          break;
        case 'avaliacao_media':
          progressoAtual = _performanceAtual['avaliacaoMedia'] ?? 0;
          break;
      }

      final progresso = (progressoAtual / meta['valor']) * 100;
      meta['progresso'] = progresso.clamp(0, 100);

      if (progresso >= 100 && meta['status'] == 'ativa') {
        meta['status'] = 'concluida';
        _conquistasDesbloqueadas.add({
          'id': 'meta_${tipo}_concluida',
          'titulo': 'Meta Alcançada!',
          'descricao': 'Parabéns! Você atingiu sua meta de ${_obterDescricaoMeta(tipo)}',
          'icone': '🏆',
          'pontos': 300,
          'desbloqueadaEm': DateTime.now(),
        });
      }
    }

    await _salvarMetas();
    await _salvarConquistas();
    notifyListeners();
  }

  // Obter dica específica por categoria
  List<Map<String, dynamic>> obterDicasPorCategoria(String categoria) {
    return _dicasAtivas.where((dica) => dica['categoria'] == categoria).toList();
  }

  // Marcar dica como vista
  void marcarDicaComoVista(int index) {
    if (index >= 0 && index < _dicasAtivas.length) {
      _dicasAtivas[index]['vista'] = true;
      notifyListeners();
    }
  }

  // Análise de bem-estar do motorista
  Future<void> _analisarBemEstar() async {
    try {
      final agora = DateTime.now();
      final horasOnlineConsecutivas = await _calcularHorasOnlineConsecutivas();
      final diasSemParada = await _calcularDiasSemParada();

      // Alerta de fadiga
      if (horasOnlineConsecutivas >= 8) {
        _dicasAtivas.add({
          'tipo': 'saude',
          'prioridade': 'alta',
          'titulo': 'Hora de Descansar',
          'descricao': 'Você está online há ${horasOnlineConsecutivas.toStringAsFixed(1)}h. Faça uma pausa para sua segurança.',
          'acao': 'Programar Pausa',
          'icone': '😴',
          'categoria': 'saude'
        });
      }

      // Alerta de sobrecarga
      if (diasSemParada >= 7) {
        _dicasAtivas.add({
          'tipo': 'saude',
          'prioridade': 'alta',
          'titulo': 'Dia de Folga Necessário',
          'descricao': 'Você trabalhou $diasSemParada dias seguidos. Considere tirar uma folga.',
          'acao': 'Planejar Folga',
          'icone': '🏖️',
          'categoria': 'saude'
        });
      }

      // Dicas de postura (baseado em tempo dirigindo)
      final tempoDirigindo = _performanceAtual['tempoMedioViagem'] ?? 0;
      if (tempoDirigindo > 30) {
        _dicasAtivas.add({
          'tipo': 'saude',
          'prioridade': 'baixa',
          'titulo': 'Cuide da Postura',
          'descricao': 'Ajuste o banco, apoie as costas e faça alongamentos entre corridas.',
          'acao': 'Ver Exercícios',
          'icone': '🧘‍♂️',
          'categoria': 'saude'
        });
      }

    } catch (e) {
      print('Erro na análise de bem-estar: $e');
    }
  }

  Future<double> _calcularHorasOnlineConsecutivas() async {
    // Placeholder - implementar lógica real de tracking
    return DateTime.now().hour.toDouble(); // Simplificado
  }

  Future<int> _calcularDiasSemParada() async {
    // Placeholder - implementar lógica real baseada em histórico
    return 3; // Simplificado
  }

  // Obter métricas de saúde
  Map<String, dynamic> obterMetricasSaude() {
    return {
      'horasOnlineHoje': 6.5,
      'diasConsecutivos': 3,
      'pausasRecomendadas': 2,
      'pausasFeitas': 1,
      'scorePostura': 75, // 0-100
      'alertasFadiga': 1,
      'recomendacoes': [
        'Faça uma pausa de 15 min a cada 2h',
        'Mantenha as costas retas',
        'Hidrate-se regularmente'
      ]
    };
  }

  // Obter análise semanal
  Map<String, dynamic> obterAnaliseSemanal() {
    // Calcular tendências e insights da semana
    return {
      'tendenciaGanhos': 'crescente', // crescente, decrescente, estavel
      'melhorDia': 'sexta-feira',
      'horarioMaisProdutivo': '18:00-20:00',
      'recomendacao': 'Foque nos horários de 17h às 19h para maximizar ganhos',
      'proximaMeta': 'Aumentar 15% os ganhos semanais',
    };
  }

  // Salvar dados no Firebase
  Future<void> _salvarPerformance() async {
    try {
      final motoristaId = _auth.currentUser?.uid;
      if (motoristaId == null) return;

      await _firestore
          .collection('motoristas')
          .doc(motoristaId)
          .collection('coaching')
          .doc('performance')
          .set({
        'data': _performanceAtual,
        'atualizadoEm': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Erro ao salvar performance: $e');
    }
  }

  Future<void> _salvarMetas() async {
    try {
      final motoristaId = _auth.currentUser?.uid;
      if (motoristaId == null) return;

      await _firestore
          .collection('motoristas')
          .doc(motoristaId)
          .collection('coaching')
          .doc('metas')
          .set({
        'metas': _metasPersonalizadas,
        'atualizadoEm': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Erro ao salvar metas: $e');
    }
  }

  Future<void> _salvarConquistas() async {
    try {
      final motoristaId = _auth.currentUser?.uid;
      if (motoristaId == null) return;

      await _firestore
          .collection('motoristas')
          .doc(motoristaId)
          .collection('coaching')
          .doc('conquistas')
          .set({
        'conquistas': _conquistasDesbloqueadas,
        'atualizadoEm': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Erro ao salvar conquistas: $e');
    }
  }

  // Carregar dados do Firebase
  Future<void> _carregarMetasPersonalizadas() async {
    try {
      final motoristaId = _auth.currentUser?.uid;
      if (motoristaId == null) return;

      final doc = await _firestore
          .collection('motoristas')
          .doc(motoristaId)
          .collection('coaching')
          .doc('metas')
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        _metasPersonalizadas = Map<String, dynamic>.from(data['metas'] ?? {});
      }
    } catch (e) {
      print('Erro ao carregar metas: $e');
    }
  }
}