
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

class EconomiaCombustivelService extends ChangeNotifier {
  static final EconomiaCombustivelService _instance = EconomiaCombustivelService._internal();
  factory EconomiaCombustivelService() => _instance;
  EconomiaCombustivelService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  double _consumoMedio = 12.0; // km/l
  double _velocidadeIdeal = 60.0; // km/h
  Map<String, dynamic> _estatisticasViagem = {};
  List<Map<String, dynamic>> _dicasEconomia = [];
  bool _monitorandoViagem = false;
  DateTime? _inicioViagem;
  double _distanciaViagem = 0;
  List<Position> _pontosViagem = [];

  // Getters
  double get consumoMedio => _consumoMedio;
  double get velocidadeIdeal => _velocidadeIdeal;
  Map<String, dynamic> get estatisticasViagem => _estatisticasViagem;
  List<Map<String, dynamic>> get dicasEconomia => _dicasEconomia;
  bool get monitorandoViagem => _monitorandoViagem;

  // Inicializar serviço
  Future<void> inicializar() async {
    await _carregarConfiguracoes();
    await _gerarDicasEconomia();
  }

  // Iniciar monitoramento de viagem
  Future<void> iniciarMonitoramentoViagem() async {
    _monitorandoViagem = true;
    _inicioViagem = DateTime.now();
    _distanciaViagem = 0;
    _pontosViagem.clear();
    _estatisticasViagem.clear();

    await _adicionarDica({
      'tipo': 'inicio_viagem',
      'titulo': '🚗 Viagem Iniciada',
      'descricao': 'Mantenha velocidade constante entre 50-70 km/h para melhor economia.',
      'prioridade': 'alta',
      'categoria': 'economia',
    });

    notifyListeners();
  }

  // Parar monitoramento de viagem
  Future<void> pararMonitoramentoViagem() async {
    if (!_monitorandoViagem) return;

    _monitorandoViagem = false;
    final duracao = DateTime.now().difference(_inicioViagem!);
    
    // Calcular estatísticas da viagem
    final velocidadeMedia = _calcularVelocidadeMedia();
    final consumoEstimado = _calcularConsumoEstimado();
    final pontuacaoEco = _calcularPontuacaoEco(velocidadeMedia);

    _estatisticasViagem = {
      'duracao': duracao.inMinutes,
      'distancia': _distanciaViagem,
      'velocidadeMedia': velocidadeMedia,
      'consumoEstimado': consumoEstimado,
      'pontuacaoEco': pontuacaoEco,
      'custoEstimado': _calcularCustoEstimado(consumoEstimado),
    };

    await _salvarEstatisticasViagem();
    await _gerarRelatorioViagem();
    
    notifyListeners();
  }

  // Atualizar posição durante a viagem
  Future<void> atualizarPosicao(Position position) async {
    if (!_monitorandoViagem) return;

    _pontosViagem.add(position);

    if (_pontosViagem.length > 1) {
      final pontoAnterior = _pontosViagem[_pontosViagem.length - 2];
      final distancia = Geolocator.distanceBetween(
        pontoAnterior.latitude,
        pontoAnterior.longitude,
        position.latitude,
        position.longitude,
      ) / 1000; // converter para km

      _distanciaViagem += distancia;

      // Análise de velocidade em tempo real
      await _analisarVelocidade(position.speed * 3.6); // converter m/s para km/h
    }
  }

  // Analisar velocidade e dar dicas
  Future<void> _analisarVelocidade(double velocidadeAtual) async {
    if (velocidadeAtual > 80) {
      await _adicionarDica({
        'tipo': 'velocidade_alta',
        'titulo': '⚠️ Velocidade Alta',
        'descricao': 'Reduza para 60-70 km/h. Velocidade alta aumenta o consumo em até 40%.',
        'prioridade': 'alta',
        'categoria': 'velocidade',
      });
    } else if (velocidadeAtual < 30) {
      await _adicionarDica({
        'tipo': 'velocidade_baixa',
        'titulo': '🐌 Trânsito Lento',
        'descricao': 'Em trânsito, evite acelerar e frear bruscamente. Use o freio motor.',
        'prioridade': 'media',
        'categoria': 'transito',
      });
    } else if (velocidadeAtual >= 50 && velocidadeAtual <= 70) {
      await _adicionarDica({
        'tipo': 'velocidade_ideal',
        'titulo': '✅ Velocidade Ideal',
        'descricao': 'Perfeito! Mantenha essa velocidade para máxima economia.',
        'prioridade': 'baixa',
        'categoria': 'economia',
      });
    }
  }

  // Adicionar dica sem duplicar
  Future<void> _adicionarDica(Map<String, dynamic> novaDica) async {
    // Remove dicas antigas do mesmo tipo
    _dicasEconomia.removeWhere((dica) => dica['tipo'] == novaDica['tipo']);
    
    // Adiciona nova dica no início
    _dicasEconomia.insert(0, {
      ...novaDica,
      'timestamp': DateTime.now(),
    });

    // Mantém apenas as 5 dicas mais recentes
    if (_dicasEconomia.length > 5) {
      _dicasEconomia = _dicasEconomia.take(5).toList();
    }

    notifyListeners();
  }

  // Gerar dicas gerais de economia
  Future<void> _gerarDicasEconomia() async {
    final dicasGerais = [
      {
        'tipo': 'manutencao',
        'titulo': '🔧 Manutenção em Dia',
        'descricao': 'Verifique pneus, filtros e óleo regularmente. Pode economizar até 15%.',
        'prioridade': 'media',
        'categoria': 'manutencao',
      },
      {
        'tipo': 'ar_condicionado',
        'titulo': '❄️ Ar Condicionado',
        'descricao': 'Use com moderação. Em velocidades baixas, prefira janelas abertas.',
        'prioridade': 'baixa',
        'categoria': 'conforto',
      },
      {
        'tipo': 'antecipacao',
        'titulo': '👀 Direção Defensiva',
        'descricao': 'Antecipe semáforos e trânsito. Evite acelerar e frear bruscamente.',
        'prioridade': 'alta',
        'categoria': 'direcao',
      },
    ];

    _dicasEconomia.addAll(dicasGerais);
    notifyListeners();
  }

  // Calcular velocidade média da viagem
  double _calcularVelocidadeMedia() {
    if (_pontosViagem.length < 2 || _inicioViagem == null) return 0;

    final duracaoHoras = DateTime.now().difference(_inicioViagem!).inMilliseconds / 3600000;
    return duracaoHoras > 0 ? _distanciaViagem / duracaoHoras : 0;
  }

  // Calcular consumo estimado
  double _calcularConsumoEstimado() {
    return _distanciaViagem / _consumoMedio;
  }

  // Calcular pontuação eco (0-100)
  int _calcularPontuacaoEco(double velocidadeMedia) {
    int pontos = 100;

    // Penalizar por velocidade inadequada
    if (velocidadeMedia > 80) {
      pontos -= ((velocidadeMedia - 80) * 2).round();
    } else if (velocidadeMedia < 40) {
      pontos -= ((40 - velocidadeMedia) * 1.5).round();
    }

    // Bonificar por velocidade ideal (50-70 km/h)
    if (velocidadeMedia >= 50 && velocidadeMedia <= 70) {
      pontos += 10;
    }

    return pontos.clamp(0, 100);
  }

  // Calcular custo estimado (R$ 5,50/litro)
  double _calcularCustoEstimado(double litrosConsumidos) {
    return litrosConsumidos * 5.50;
  }

  // Gerar relatório de viagem
  Future<void> _gerarRelatorioViagem() async {
    final pontuacao = _estatisticasViagem['pontuacaoEco'] as int;
    String feedback = '';
    String emoji = '';

    if (pontuacao >= 90) {
      emoji = '🌟';
      feedback = 'Excelente! Direção muito econômica.';
    } else if (pontuacao >= 70) {
      emoji = '👍';
      feedback = 'Boa direção! Pequenos ajustes podem melhorar ainda mais.';
    } else if (pontuacao >= 50) {
      emoji = '⚠️';
      feedback = 'Direção moderada. Tente manter velocidade mais constante.';
    } else {
      emoji = '🚨';
      feedback = 'Muitas acelerações bruscas. Direção mais suave economiza combustível.';
    }

    await _adicionarDica({
      'tipo': 'relatorio_viagem',
      'titulo': '$emoji Viagem Concluída',
      'descricao': '$feedback Pontuação: $pontuacao/100',
      'prioridade': 'alta',
      'categoria': 'relatorio',
    });
  }

  // Configurar veículo (consumo, etc.)
  Future<void> configurarVeiculo(double consumoKmPorLitro, String tipoVeiculo) async {
    _consumoMedio = consumoKmPorLitro;
    
    // Ajustar velocidade ideal baseada no tipo de veículo
    switch (tipoVeiculo.toLowerCase()) {
      case 'flex':
        _velocidadeIdeal = 65.0;
        break;
      case 'diesel':
        _velocidadeIdeal = 70.0;
        break;
      case 'eletrico':
        _velocidadeIdeal = 60.0;
        break;
      default:
        _velocidadeIdeal = 60.0;
    }

    await _salvarConfiguracoes();
    notifyListeners();
  }

  // Obter economia mensal estimada
  Map<String, dynamic> obterEconomiaMensal() {
    // Calcular com base nas viagens dos últimos 30 dias
    return {
      'litrosEconomizados': 25.5,
      'valorEconomizado': 140.25,
      'reducaoEmissoes': 60.2, // kg CO2
      'ranking': 'Top 15%', // entre motoristas da região
    };
  }

  // Obter dicas por categoria
  List<Map<String, dynamic>> obterDicasPorCategoria(String categoria) {
    return _dicasEconomia.where((dica) => dica['categoria'] == categoria).toList();
  }

  // Salvar dados
  Future<void> _salvarConfiguracoes() async {
    try {
      final motoristaId = _auth.currentUser?.uid;
      if (motoristaId == null) return;

      await _firestore
          .collection('motoristas')
          .doc(motoristaId)
          .collection('economia_combustivel')
          .doc('configuracoes')
          .set({
        'consumoMedio': _consumoMedio,
        'velocidadeIdeal': _velocidadeIdeal,
        'atualizadoEm': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Erro ao salvar configurações: $e');
    }
  }

  Future<void> _salvarEstatisticasViagem() async {
    try {
      final motoristaId = _auth.currentUser?.uid;
      if (motoristaId == null) return;

      await _firestore
          .collection('motoristas')
          .doc(motoristaId)
          .collection('economia_combustivel')
          .doc('viagens')
          .collection('historico')
          .add({
        ..._estatisticasViagem,
        'dataViagem': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Erro ao salvar estatísticas: $e');
    }
  }

  Future<void> _carregarConfiguracoes() async {
    try {
      final motoristaId = _auth.currentUser?.uid;
      if (motoristaId == null) return;

      final doc = await _firestore
          .collection('motoristas')
          .doc(motoristaId)
          .collection('economia_combustivel')
          .doc('configuracoes')
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        _consumoMedio = (data['consumoMedio'] as num?)?.toDouble() ?? 12.0;
        _velocidadeIdeal = (data['velocidadeIdeal'] as num?)?.toDouble() ?? 60.0;
      }
    } catch (e) {
      print('Erro ao carregar configurações: $e');
    }
  }
}
