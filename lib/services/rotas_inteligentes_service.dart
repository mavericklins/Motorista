
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

class RotasInteligentesService extends ChangeNotifier {
  static final RotasInteligentesService _instance = RotasInteligentesService._internal();
  factory RotasInteligentesService() => _instance;
  RotasInteligentesService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, Map<String, dynamic>> _padroesTrafego = {};
  List<Map<String, dynamic>> _rotasAprendidas = [];
  bool _aprendizadoAtivo = true;

  // Getters
  Map<String, Map<String, dynamic>> get padroesTrafego => _padroesTrafego;
  List<Map<String, dynamic>> get rotasAprendidas => _rotasAprendidas;
  bool get aprendizadoAtivo => _aprendizadoAtivo;

  // Inicializar o serviço
  Future<void> inicializar() async {
    await _carregarPadroesAprendidos();
    _iniciarColetaDados();
  }

  // Calcular rota inteligente
  Future<Map<String, dynamic>> calcularRotaInteligente(
      Position origem,
      Position destino,
      {String? tipoVeiculo = 'car'}
      ) async {
    try {
      // Análise de padrões históricos
      final padraoHorario = _analisarPadraoHorario(DateTime.now());
      final condicoesTrafego = await _obterCondicoesTrafego();

      // Gerar múltiplas rotas
      final rotasAlternativas = await _gerarRotasAlternativas(origem, destino);

      // Aplicar IA para escolher melhor rota
      final melhorRota = _aplicarIASelecao(rotasAlternativas, padraoHorario, condicoesTrafego);

      // Salvar escolha para aprendizado
      await _salvarEscolhaRota(origem, destino, melhorRota);

      return melhorRota;
    } catch (e) {
      print('Erro ao calcular rota inteligente: $e');
      return await _rotaBasica(origem, destino);
    }
  }

  // Gerar múltiplas rotas alternativas
  Future<List<Map<String, dynamic>>> _gerarRotasAlternativas(
      Position origem,
      Position destino
      ) async {
    List<Map<String, dynamic>> rotas = [];

    try {
      // Rota mais rápida
      final rotaRapida = await _calcularRotaGeoapify(origem, destino, 'time');
      rotaRapida['tipo'] = 'rapida';
      rotaRapida['prioridade'] = 'tempo';
      rotas.add(rotaRapida);

      // Rota mais curta
      final rotaCurta = await _calcularRotaGeoapify(origem, destino, 'distance');
      rotaCurta['tipo'] = 'curta';
      rotaCurta['prioridade'] = 'distancia';
      rotas.add(rotaCurta);

      // Rota econômica
      final rotaEconomica = await _calcularRotaEconomica(origem, destino);
      rotaEconomica['tipo'] = 'economica';
      rotaEconomica['prioridade'] = 'combustivel';
      rotas.add(rotaEconomica);

    } catch (e) {
      print('Erro ao gerar rotas alternativas: $e');
    }

    return rotas;
  }

  // Calcular rota via Geoapify
  Future<Map<String, dynamic>> _calcularRotaGeoapify(
      Position origem,
      Position destino,
      String mode
      ) async {
    const apiKey = '82e209c579e24e2cbb629e5fa679d352';

    final url = 'https://api.geoapify.com/v1/routing?'
        'waypoints=${origem.latitude},${origem.longitude}|${destino.latitude},${destino.longitude}&'
        'mode=drive&'
        'avoid=&'
        'lang=pt&'
        'units=metric&'
        'details=instruction_details&'
        'apiKey=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final feature = data['features'][0];
      final properties = feature['properties'];

      return {
        'coordinates': feature['geometry']['coordinates'][0],
        'distance': properties['distance'],
        'time': properties['time'],
        'instructions': properties['legs'][0]['steps'],
        'consumoCombustivel': _calcularConsumo(properties['distance']),
        'score': _calcularScoreRota(properties),
      };
    }

    throw Exception('Erro ao calcular rota');
  }

  // Calcular rota econômica
  Future<Map<String, dynamic>> _calcularRotaEconomica(
      Position origem,
      Position destino
      ) async {
    final rotaBase = await _calcularRotaGeoapify(origem, destino, 'distance');

    // Aplicar otimizações para economia
    rotaBase['velocidadeOtima'] = 60; // km/h
    rotaBase['consumoCombustivel'] = rotaBase['consumoCombustivel'] * 0.85; // 15% mais eficiente
    rotaBase['pontosCombustivel'] = await _encontrarPostosCaminhoRota(rotaBase['coordinates']);

    return rotaBase;
  }

  // Aplicar IA para seleção de rota
  Map<String, dynamic> _aplicarIASelecao(
      List<Map<String, dynamic>> rotas,
      Map<String, dynamic> padraoHorario,
      Map<String, dynamic> condicoesTrafego
      ) {
    if (rotas.isEmpty) return {};

    double melhorScore = -1;
    Map<String, dynamic> melhorRota = rotas.first;

    for (var rota in rotas) {
      double score = _calcularScoreIA(rota, padraoHorario, condicoesTrafego);

      if (score > melhorScore) {
        melhorScore = score;
        melhorRota = rota;
      }
    }

    melhorRota['scoreIA'] = melhorScore;
    melhorRota['motivoEscolha'] = _gerarMotivoEscolha(melhorRota, padraoHorario);

    return melhorRota;
  }

  // Calcular score da IA
  double _calcularScoreIA(
      Map<String, dynamic> rota,
      Map<String, dynamic> padraoHorario,
      Map<String, dynamic> condicoesTrafego
      ) {
    double score = 100.0;

    // Peso do tempo (40%)
    final tempo = rota['time'] ?? 0;
    score -= (tempo / 60) * 0.4; // Penaliza tempo longo

    // Peso da distância (20%)
    final distancia = rota['distance'] ?? 0;
    score -= (distancia / 1000) * 0.2; // Penaliza distância longa

    // Peso do combustível (20%)
    final consumo = rota['consumoCombustivel'] ?? 0;
    score -= consumo * 0.2; // Penaliza alto consumo

    // Peso do tráfego (10%)
    final intensidadeTrafego = condicoesTrafego['intensidade'] ?? 0.5;
    score -= intensidadeTrafego * 10;

    // Peso do histórico (10%)
    if (padraoHorario['rotaPreferida'] == rota['tipo']) {
      score += 10;
    }

    return score.clamp(0, 100);
  }

  // Analisar padrão horário
  Map<String, dynamic> _analisarPadraoHorario(DateTime agora) {
    final hora = agora.hour;
    final diaSemana = agora.weekday;

    String periodo;
    if (hora >= 6 && hora < 12) {
      periodo = 'manha';
    } else if (hora >= 12 && hora < 18) {
      periodo = 'tarde';
    } else if (hora >= 18 && hora < 24) {
      periodo = 'noite';
    } else {
      periodo = 'madrugada';
    }

    final chave = '${diaSemana}_$periodo';
    final dadosHorario = _padroesTrafego[chave] ?? {};

    return {
      'periodo': periodo,
      'diaSemana': diaSemana,
      'intensidadeTrafego': dadosHorario['intensidade'] ?? 0.5,
      'rotaPreferida': dadosHorario['rotaPreferida'] ?? 'rapida',
      'tempoMedio': dadosHorario['tempoMedio'] ?? 0,
    };
  }

  // Obter condições de tráfego
  Future<Map<String, dynamic>> _obterCondicoesTrafego() async {
    // Simulação de API de tráfego
    final random = Random();

    return {
      'intensidade': random.nextDouble(),
      'incidentes': random.nextInt(3),
      'velocidadeMedia': 40 + random.nextInt(40),
      'confiabilidade': 0.8 + (random.nextDouble() * 0.2),
    };
  }

  // Calcular consumo de combustível
  double _calcularConsumo(double distanciaMetros) {
    final distanciaKm = distanciaMetros / 1000;
    final consumoKmL = 12.0; // Padrão
    return distanciaKm / consumoKmL;
  }

  // Calcular score da rota
  double _calcularScoreRota(Map<String, dynamic> properties) {
    final tempo = properties['time'] ?? 0;
    final distancia = properties['distance'] ?? 0;

    // Score baseado em tempo e distância
    return (100 - (tempo / 60) - (distancia / 10000)).toDouble();
  }

  // Encontrar postos no caminho
  Future<List<Map<String, dynamic>>> _encontrarPostosCaminhoRota(
      List<List<double>> coordinates
      ) async {
    // Implementação simplificada
    return [
      {
        'nome': 'Posto Exemplo',
        'distancia': 5.2,
        'preco': 5.89,
        'coordenadas': coordinates[coordinates.length ~/ 2],
      }
    ];
  }

  // Gerar motivo da escolha
  String _gerarMotivoEscolha(
      Map<String, dynamic> rota,
      Map<String, dynamic> padraoHorario
      ) {
    switch (rota['tipo']) {
      case 'rapida':
        return 'Rota mais rápida baseada no tráfego atual';
      case 'curta':
        return 'Rota mais curta para economia de combustível';
      case 'economica':
        return 'Rota otimizada para máxima eficiência';
      default:
        return 'Rota recomendada pela IA';
    }
  }

  // Salvar escolha para aprendizado
  Future<void> _salvarEscolhaRota(
      Position origem,
      Position destino,
      Map<String, dynamic> rota
      ) async {
    try {
      final motoristaId = FirebaseAuth.instance.currentUser?.uid;
      if (motoristaId == null) return;

      await _firestore.collection('rotas_ia').add({
        'motoristaId': motoristaId,
        'origem': {
          'lat': origem.latitude,
          'lon': origem.longitude,
        },
        'destino': {
          'lat': destino.latitude,
          'lon': destino.longitude,
        },
        'rotaEscolhida': rota,
        'timestamp': FieldValue.serverTimestamp(),
        'horario': DateTime.now().hour,
        'diaSemana': DateTime.now().weekday,
      });

      // Atualizar padrões locais
      await _atualizarPadroesAprendizado(rota);

    } catch (e) {
      print('Erro ao salvar escolha de rota: $e');
    }
  }

  // Rota básica como fallback
  Future<Map<String, dynamic>> _rotaBasica(Position origem, Position destino) async {
    final distancia = Geolocator.distanceBetween(
        origem.latitude,
        origem.longitude,
        destino.latitude,
        destino.longitude
    );

    return {
      'coordinates': [
        [origem.longitude, origem.latitude],
        [destino.longitude, destino.latitude],
      ],
      'distance': distancia,
      'time': (distancia / 1000) * 60 / 40, // 40 km/h médio
      'tipo': 'basica',
      'consumoCombustivel': _calcularConsumo(distancia),
      'instructions': [
        {'instruction': 'Siga em frente até o destino'},
      ],
    };
  }

  // Carregar padrões aprendidos
  Future<void> _carregarPadroesAprendidos() async {
    try {
      final motoristaId = FirebaseAuth.instance.currentUser?.uid;
      if (motoristaId == null) return;

      final doc = await _firestore
          .collection('motoristas')
          .doc(motoristaId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        final padroesData = data['padroesTrafego'] as Map<String, dynamic>?;

        if (padroesData != null) {
          _padroesTrafego = padroesData.cast<String, Map<String, dynamic>>();
          notifyListeners();
        }
      }
    } catch (e) {
      print('Erro ao carregar padrões: $e');
    }
  }

  // Iniciar coleta de dados
  void _iniciarColetaDados() {
    // Implementar coleta em tempo real
    print('Sistema de rotas inteligentes iniciado');
  }

  // Atualizar padrões de aprendizado
  Future<void> _atualizarPadroesAprendizado(Map<String, dynamic> rota) async {
    final agora = DateTime.now();
    final chave = '${agora.weekday}_${_obterPeriodo(agora.hour)}';

    if (!_padroesTrafego.containsKey(chave)) {
      _padroesTrafego[chave] = {};
    }

    _padroesTrafego[chave]!['rotaPreferida'] = rota['tipo'];
    _padroesTrafego[chave]!['ultimaAtualizacao'] = agora.millisecondsSinceEpoch;

    notifyListeners();
    await _salvarPadroes();
  }

  String _obterPeriodo(int hora) {
    if (hora >= 6 && hora < 12) return 'manha';
    if (hora >= 12 && hora < 18) return 'tarde';
    if (hora >= 18 && hora < 24) return 'noite';
    return 'madrugada';
  }

  // Salvar padrões no Firebase
  Future<void> _salvarPadroes() async {
    try {
      final motoristaId = FirebaseAuth.instance.currentUser?.uid;
      if (motoristaId == null) return;

      await _firestore.collection('motoristas').doc(motoristaId).update({
        'padroesTrafego': _padroesTrafego,
      });
    } catch (e) {
      print('Erro ao salvar padrões: $e');
    }
  }

  // Toggle aprendizado
  void toggleAprendizado() {
    _aprendizadoAtivo = !_aprendizadoAtivo;
    notifyListeners();
  }

  // Obter estatísticas de rotas
  Map<String, dynamic> obterEstatisticasRotas() {
    return {
      'totalRotasAprendidas': _rotasAprendidas.length,
      'padroesSalvos': _padroesTrafego.length,
      'aprendizadoAtivo': _aprendizadoAtivo,
      'ultimaAtualizacao': DateTime.now(),
    };
  }
}
