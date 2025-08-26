
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EcoDriveService extends ChangeNotifier {
  static final EcoDriveService _instance = EcoDriveService._internal();
  factory EcoDriveService() => _instance;
  EcoDriveService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _modoEcoAtivo = false;
  double _consumoMedioKmL = 12.0; // km por litro padrão
  double _precoLitroGasolina = 5.50;
  List<Map<String, dynamic>> _viagensRecentes = [];
  double _pontuacaoEco = 100.0;

  // Getters
  bool get modoEcoAtivo => _modoEcoAtivo;
  double get consumoMedioKmL => _consumoMedioKmL;
  double get precoLitroGasolina => _precoLitroGasolina;
  List<Map<String, dynamic>> get viagensRecentes => _viagensRecentes;
  double get pontuacaoEco => _pontuacaoEco;

  // Ativar/Desativar modo eco
  void toggleModoEco() {
    _modoEcoAtivo = !_modoEcoAtivo;
    notifyListeners();
    _salvarConfiguracoes();
  }

  // Configurar consumo do veículo
  void configurarConsumo(double novoConsumo, double novoPreco) {
    _consumoMedioKmL = novoConsumo;
    _precoLitroGasolina = novoPreco;
    notifyListeners();
    _salvarConfiguracoes();
  }

  // Iniciar monitoramento de viagem
  Future<String> iniciarMonitoramentoViagem(String corridaId, Position posicaoInicial) async {
    try {
      final viagemData = {
        'corridaId': corridaId,
        'motoristaId': FirebaseAuth.instance.currentUser?.uid,
        'posicaoInicial': {
          'lat': posicaoInicial.latitude,
          'lon': posicaoInicial.longitude,
        },
        'iniciadaEm': FieldValue.serverTimestamp(),
        'status': 'em_andamento',
        'distanciaPercorrida': 0.0,
        'velocidadeMedia': 0.0,
        'velocidadeMaxima': 0.0,
        'aceleracoesBruscas': 0,
        'frenadaBrusca': 0,
        'tempoParado': 0,
        'pontuacaoEcoViagem': 100.0,
      };

      final docRef = await _firestore.collection('eco_viagens').add(viagemData);
      return docRef.id;
    } catch (e) {
      print('Erro ao iniciar monitoramento: $e');
      return '';
    }
  }

  // Atualizar dados da viagem em tempo real
  Future<void> atualizarDadosViagem(
      String viagemId,
      Position posicaoAtual,
      double velocidadeAtual,
      double? aceleracao
      ) async {
    try {
      final docRef = _firestore.collection('eco_viagens').doc(viagemId);
      final doc = await docRef.get();

      if (!doc.exists) return;

      final dadosAtuais = doc.data()!;
      double distanciaTotal = dadosAtuais['distanciaPercorrida'] ?? 0.0;
      double velocidadeMaxima = dadosAtuais['velocidadeMaxima'] ?? 0.0;
      int aceleracoesBruscas = dadosAtuais['aceleracoesBruscas'] ?? 0;
      int frenadasBruscas = dadosAtuais['frenadaBrusca'] ?? 0;
      double pontuacao = dadosAtuais['pontuacaoEcoViagem'] ?? 100.0;

      // Detecta aceleração brusca (mais de 3 m/s²)
      if (aceleracao != null && aceleracao.abs() > 3.0) {
        if (aceleracao > 0) {
          aceleracoesBruscas++;
          pontuacao -= 5.0; // Penaliza aceleração brusca
        } else {
          frenadasBruscas++;
          pontuacao -= 3.0; // Penaliza frenada brusca
        }
      }

      // Penaliza velocidade excessiva
      if (velocidadeAtual > 80.0) { // km/h
        pontuacao -= 1.0;
      }

      // Bonifica condução eficiente
      if (velocidadeAtual >= 40.0 && velocidadeAtual <= 80.0) {
        pontuacao = (pontuacao + 0.1).clamp(0.0, 100.0);
      }

      velocidadeMaxima = velocidadeMaxima > velocidadeAtual ? velocidadeMaxima : velocidadeAtual;
      pontuacao = pontuacao.clamp(0.0, 100.0);

      await docRef.update({
        'velocidadeMaxima': velocidadeMaxima,
        'aceleracoesBruscas': aceleracoesBruscas,
        'frenadaBrusca': frenadasBruscas,
        'pontuacaoEcoViagem': pontuacao,
        'ultimaAtualizacao': FieldValue.serverTimestamp(),
      });

    } catch (e) {
      print('Erro ao atualizar dados da viagem: $e');
    }
  }

  // Finalizar monitoramento de viagem
  Future<Map<String, dynamic>?> finalizarViagem(String viagemId, Position posicaoFinal, double distanciaTotal) async {
    try {
      final docRef = _firestore.collection('eco_viagens').doc(viagemId);
      final doc = await docRef.get();

      if (!doc.exists) return null;

      final dados = doc.data()!;
      final iniciadaEm = (dados['iniciadaEm'] as Timestamp).toDate();
      final tempoTotalMinutos = DateTime.now().difference(iniciadaEm).inMinutes;
      final velocidadeMedia = tempoTotalMinutos > 0 ? (distanciaTotal / tempoTotalMinutos) * 60 : 0.0;

      // Calcula consumo estimado
      final litrosConsumidos = distanciaTotal / _consumoMedioKmL;
      final custoGasolina = litrosConsumidos * _precoLitroGasolina;

      final dadosFinais = {
        'posicaoFinal': {
          'lat': posicaoFinal.latitude,
          'lon': posicaoFinal.longitude,
        },
        'finalizadaEm': FieldValue.serverTimestamp(),
        'status': 'concluida',
        'distanciaPercorrida': distanciaTotal,
        'velocidadeMedia': velocidadeMedia,
        'tempoTotalMinutos': tempoTotalMinutos,
        'litrosConsumidos': litrosConsumidos,
        'custoGasolina': custoGasolina,
        'kmPorLitro': distanciaTotal / litrosConsumidos,
      };

      await docRef.update(dadosFinais);

      // Atualiza estatísticas pessoais
      await _atualizarEstatisticasPessoais(dados);

      // Retorna resumo da viagem
      final dadosCompletos = {...dados, ...dadosFinais};
      return _gerarResumoViagem(dadosCompletos);

    } catch (e) {
      print('Erro ao finalizar viagem: $e');
      return null;
    }
  }

  // Gerar resumo da viagem
  Map<String, dynamic> _gerarResumoViagem(Map<String, dynamic> dados) {
    final distancia = dados['distanciaPercorrida'] ?? 0.0;
    final litros = dados['litrosConsumidos'] ?? 0.0;
    final custo = dados['custoGasolina'] ?? 0.0;
    final pontuacao = dados['pontuacaoEcoViagem'] ?? 0.0;
    final aceleracoes = dados['aceleracoesBruscas'] ?? 0;
    final frenadas = dados['frenadaBrusca'] ?? 0;

    String classificacao;
    Color cor;

    if (pontuacao >= 90) {
      classificacao = 'Excelente';
      cor = Colors.green;
    } else if (pontuacao >= 75) {
      classificacao = 'Bom';
      cor = Colors.lightGreen;
    } else if (pontuacao >= 60) {
      classificacao = 'Regular';
      cor = Colors.orange;
    } else {
      classificacao = 'Precisa Melhorar';
      cor = Colors.red;
    }

    return {
      'distancia': distancia,
      'consumoLitros': litros,
      'custoGasolina': custo,
      'pontuacaoEco': pontuacao,
      'classificacao': classificacao,
      'corClassificacao': cor,
      'aceleracoesBruscas': aceleracoes,
      'frenadasBruscas': frenadas,
      'velocidadeMedia': dados['velocidadeMedia'] ?? 0.0,
      'kmPorLitro': distancia > 0 && litros > 0 ? distancia / litros : 0.0,
      'dicas': _gerarDicasEconomia(dados),
    };
  }

  // Gerar dicas de economia
  List<String> _gerarDicasEconomia(Map<String, dynamic> dados) {
    List<String> dicas = [];

    final aceleracoes = dados['aceleracoesBruscas'] ?? 0;
    final frenadas = dados['frenadaBrusca'] ?? 0;
    final velocidadeMaxima = dados['velocidadeMaxima'] ?? 0.0;

    if (aceleracoes > 3) {
      dicas.add('Evite acelerações bruscas para economizar até 15% de combustível');
    }

    if (frenadas > 2) {
      dicas.add('Antecipe as paradas para reduzir frenadas bruscas');
    }

    if (velocidadeMaxima > 100) {
      dicas.add('Mantenha velocidade entre 60-80 km/h para máxima eficiência');
    }

    dicas.add('Use o ar condicionado de forma inteligente para economizar combustível');
    dicas.add('Mantenha a manutenção do veículo em dia');

    return dicas;
  }

  // Atualizar estatísticas pessoais
  Future<void> _atualizarEstatisticasPessoais(Map<String, dynamic> dadosViagem) async {
    try {
      final motoristaId = FirebaseAuth.instance.currentUser?.uid;
      if (motoristaId == null) return;

      final pontuacao = dadosViagem['pontuacaoEcoViagem'] ?? 0.0;

      // Atualiza pontuação média
      _pontuacaoEco = (_pontuacaoEco + pontuacao) / 2;

      // Adiciona à lista de viagens recentes
      _viagensRecentes.insert(0, dadosViagem);
      if (_viagensRecentes.length > 10) {
        _viagensRecentes = _viagensRecentes.take(10).toList();
      }

      notifyListeners();

    } catch (e) {
      print('Erro ao atualizar estatísticas: $e');
    }
  }

  // Salvar configurações
  Future<void> _salvarConfiguracoes() async {
    try {
      final motoristaId = FirebaseAuth.instance.currentUser?.uid;
      if (motoristaId == null) return;

      await _firestore.collection('motoristas').doc(motoristaId).update({
        'ecoConfig': {
          'modoAtivo': _modoEcoAtivo,
          'consumoKmL': _consumoMedioKmL,
          'precoLitro': _precoLitroGasolina,
          'pontuacaoEco': _pontuacaoEco,
        }
      });
    } catch (e) {
      print('Erro ao salvar configurações eco: $e');
    }
  }

  // Carregar configurações
  Future<void> carregarConfiguracoes() async {
    try {
      final motoristaId = FirebaseAuth.instance.currentUser?.uid;
      if (motoristaId == null) return;

      final doc = await _firestore.collection('motoristas').doc(motoristaId).get();
      if (doc.exists) {
        final data = doc.data()!;
        final ecoConfig = data['ecoConfig'] as Map<String, dynamic>?;

        if (ecoConfig != null) {
          _modoEcoAtivo = ecoConfig['modoAtivo'] ?? false;
          _consumoMedioKmL = ecoConfig['consumoKmL'] ?? 12.0;
          _precoLitroGasolina = ecoConfig['precoLitro'] ?? 5.50;
          _pontuacaoEco = ecoConfig['pontuacaoEco'] ?? 100.0;
          notifyListeners();
        }
      }
    } catch (e) {
      print('Erro ao carregar configurações eco: $e');
    }
  }

  // Obter ranking eco entre motoristas
  Future<Map<String, dynamic>> obterRankingEco() async {
    try {
      final motoristaId = FirebaseAuth.instance.currentUser?.uid;
      if (motoristaId == null) return {};

      final querySnapshot = await _firestore
          .collection('motoristas')
          .orderBy('ecoConfig.pontuacaoEco', descending: true)
          .limit(100)
          .get();

      int posicao = 1;
      int minhaPosicao = 0;
      List<Map<String, dynamic>> ranking = [];

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final ecoConfig = data['ecoConfig'] as Map<String, dynamic>?;

        if (ecoConfig != null) {
          final pontuacao = ecoConfig['pontuacaoEco'] ?? 0.0;

          if (doc.id == motoristaId) {
            minhaPosicao = posicao;
          }

          if (ranking.length < 10) { // Top 10
            ranking.add({
              'posicao': posicao,
              'nome': data['nome'] ?? 'Motorista',
              'pontuacao': pontuacao,
              'isMe': doc.id == motoristaId,
            });
          }
        }

        posicao++;
      }

      return {
        'minhaPosicao': minhaPosicao,
        'minhaPontuacao': _pontuacaoEco,
        'ranking': ranking,
        'totalMotoristas': querySnapshot.docs.length,
      };
    } catch (e) {
      print('Erro ao obter ranking: $e');
      return {};
    }
  }

  // Calcular economia estimada mensal
  double calcularEconomiaMensal(double kmMes) {
    final litrosSemEco = kmMes / _consumoMedioKmL;
    final litrosComEco = kmMes / (_consumoMedioKmL * 1.15); // 15% mais eficiente
    final economiaLitros = litrosSemEco - litrosComEco;
    return economiaLitros * _precoLitroGasolina;
  }
}
