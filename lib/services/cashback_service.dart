
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CashbackService extends ChangeNotifier {
  static final CashbackService _instance = CashbackService._internal();
  factory CashbackService() => _instance;
  CashbackService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  double _pontosDisponiveis = 0;
  double _cashbackAcumulado = 0;
  List<Map<String, dynamic>> _historicoRecompensas = [];
  List<Map<String, dynamic>> _beneficiosDisponiveis = [];
  Map<String, dynamic> _programaFidelidade = {};

  double get pontosDisponiveis => _pontosDisponiveis;
  double get cashbackAcumulado => _cashbackAcumulado;
  List<Map<String, dynamic>> get historicoRecompensas => _historicoRecompensas;
  List<Map<String, dynamic>> get beneficiosDisponiveis => _beneficiosDisponiveis;
  Map<String, dynamic> get programaFidelidade => _programaFidelidade;

  // Inicializar sistema de cashback
  Future<void> inicializarCashback() async {
    await Future.wait([
      _carregarPontos(),
      _carregarBeneficios(),
      _carregarHistorico(),
      _carregarProgramaFidelidade(),
    ]);
  }

  // Adicionar pontos por corrida
  Future<void> adicionarPontosPorCorrida(String corridaId, double valorCorrida, double avaliacaoPassageiro) async {
    try {
      final motoristaId = FirebaseAuth.instance.currentUser?.uid;
      if (motoristaId == null) return;

      // Calcular pontos baseado no valor e avaliação
      double pontos = valorCorrida * 0.05; // 5% do valor em pontos

      // Bônus por avaliação alta
      if (avaliacaoPassageiro >= 4.5) {
        pontos *= 1.5; // 50% de bônus
      } else if (avaliacaoPassageiro >= 4.0) {
        pontos *= 1.2; // 20% de bônus
      }

      // Bônus por horário (pico)
      final now = DateTime.now();
      if (_isHorarioPico(now.hour, now.weekday)) {
        pontos *= 1.3; // 30% de bônus em horário de pico
      }

      await _adicionarPontos(pontos, 'corrida', {
        'corridaId': corridaId,
        'valorCorrida': valorCorrida,
        'avaliacao': avaliacaoPassageiro,
        'multiplicador': pontos / (valorCorrida * 0.05),
      });
    } catch (e) {
      print('Erro ao adicionar pontos por corrida: $e');
    }
  }

  // Verificar se é horário de pico
  bool _isHorarioPico(int hora, int diaSemana) {
    if (diaSemana >= 1 && diaSemana <= 5) { // Segunda a sexta
      return (hora >= 7 && hora <= 9) || (hora >= 17 && hora <= 19);
    }
    return false; // Fim de semana sem pico específico
  }

  // Adicionar pontos genérico
  Future<void> _adicionarPontos(double pontos, String tipo, Map<String, dynamic> detalhes) async {
    try {
      final motoristaId = FirebaseAuth.instance.currentUser?.uid;
      if (motoristaId == null) return;

      final batch = _firestore.batch();

      // Atualizar total de pontos
      final motoristaRef = _firestore.collection('motoristas').doc(motoristaId);
      batch.update(motoristaRef, {
        'cashback.pontos': FieldValue.increment(pontos),
        'cashback.ultimaAtualizacao': FieldValue.serverTimestamp(),
      });

      // Registrar transação
      final transacaoRef = _firestore
          .collection('motoristas')
          .doc(motoristaId)
          .collection('cashback_historico')
          .doc();

      batch.set(transacaoRef, {
        'tipo': tipo,
        'pontos': pontos,
        'detalhes': detalhes,
        'criadaEm': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      _pontosDisponiveis += pontos;
      notifyListeners();

      // Verificar conquistas
      await _verificarConquistas(pontos);
    } catch (e) {
      print('Erro ao adicionar pontos: $e');
    }
  }

  // Verificar conquistas e marcos
  Future<void> _verificarConquistas(double pontosAdicionados) async {
    try {
      final pontosTotal = _pontosDisponiveis;

      // Marcos de pontos
      List<Map<String, dynamic>> conquistas = [];

      if (pontosTotal >= 100 && pontosTotal - pontosAdicionados < 100) {
        conquistas.add({
          'nome': 'Primeiro Centenário',
          'descricao': 'Acumulou 100 pontos',
          'bonus': 50.0,
          'icone': 'milestone',
        });
      }

      if (pontosTotal >= 500 && pontosTotal - pontosAdicionados < 500) {
        conquistas.add({
          'nome': 'Colecionador',
          'descricao': 'Acumulou 500 pontos',
          'bonus': 100.0,
          'icone': 'trophy',
        });
      }

      if (pontosTotal >= 1000 && pontosTotal - pontosAdicionados < 1000) {
        conquistas.add({
          'nome': 'Mestre dos Pontos',
          'descricao': 'Acumulou 1000 pontos',
          'bonus': 250.0,
          'icone': 'crown',
        });
      }

      // Aplicar bônus das conquistas
      for (final conquista in conquistas) {
        await _adicionarPontos(conquista['bonus'], 'conquista', conquista);
        await _notificarConquista(conquista);
      }
    } catch (e) {
      print('Erro ao verificar conquistas: $e');
    }
  }

  // Notificar conquista
  Future<void> _notificarConquista(Map<String, dynamic> conquista) async {
    // Implementar notificação push ou local
    print('Conquista desbloqueada: ${conquista['nome']}');
  }

  // Resgatar benefício
  Future<Map<String, dynamic>> resgatarBeneficio(String beneficioId) async {
    try {
      final motoristaId = FirebaseAuth.instance.currentUser?.uid;
      if (motoristaId == null) {
        return {'sucesso': false, 'erro': 'Usuário não autenticado'};
      }

      final beneficio = _beneficiosDisponiveis.firstWhere(
            (b) => b['id'] == beneficioId,
        orElse: () => {},
      );

      if (beneficio.isEmpty) {
        return {'sucesso': false, 'erro': 'Benefício não encontrado'};
      }

      final custoPontos = beneficio['custoPontos'] as double;

      if (_pontosDisponiveis < custoPontos) {
        return {
          'sucesso': false,
          'erro': 'Pontos insuficientes',
          'pontosNecessarios': custoPontos,
          'pontosDisponiveis': _pontosDisponiveis,
        };
      }

      final batch = _firestore.batch();

      // Debitar pontos
      final motoristaRef = _firestore.collection('motoristas').doc(motoristaId);
      batch.update(motoristaRef, {
        'cashback.pontos': FieldValue.increment(-custoPontos),
      });

      // Registrar resgate
      final resgateRef = _firestore
          .collection('motoristas')
          .doc(motoristaId)
          .collection('cashback_resgates')
          .doc();

      batch.set(resgateRef, {
        'beneficioId': beneficioId,
        'nome': beneficio['nome'],
        'custoPontos': custoPontos,
        'tipo': beneficio['tipo'],
        'detalhes': beneficio,
        'status': 'resgatado',
        'resgatadoEm': FieldValue.serverTimestamp(),
        'validoAte': beneficio['tipo'] == 'desconto'
            ? Timestamp.fromDate(DateTime.now().add(Duration(days: 30)))
            : null,
      });

      await batch.commit();

      _pontosDisponiveis -= custoPontos;
      notifyListeners();

      // Processar benefício específico
      await _processarBeneficio(beneficio);

      return {
        'sucesso': true,
        'beneficio': beneficio,
        'pontosRestantes': _pontosDisponiveis,
      };
    } catch (e) {
      print('Erro ao resgatar benefício: $e');
      return {'sucesso': false, 'erro': e.toString()};
    }
  }

  // Processar benefício específico
  Future<void> _processarBeneficio(Map<String, dynamic> beneficio) async {
    final tipo = beneficio['tipo'] as String;

    switch (tipo) {
      case 'cashback':
        await _processarCashback(beneficio['valor']);
        break;
      case 'desconto_combustivel':
      // Implementar lógica de desconto em postos parceiros
        break;
      case 'manutencao_gratuita':
      // Implementar agendamento de manutenção
        break;
    }
  }

  // Processar cashback real
  Future<void> _processarCashback(double valor) async {
    try {
      final motoristaId = FirebaseAuth.instance.currentUser?.uid;
      if (motoristaId == null) return;

      await _firestore.collection('motoristas').doc(motoristaId).update({
        'cashback.saldoReal': FieldValue.increment(valor),
      });

      _cashbackAcumulado += valor;
      notifyListeners();
    } catch (e) {
      print('Erro ao processar cashback: $e');
    }
  }

  // Carregar pontos do usuário
  Future<void> _carregarPontos() async {
    try {
      final motoristaId = FirebaseAuth.instance.currentUser?.uid;
      if (motoristaId == null) return;

      final doc = await _firestore.collection('motoristas').doc(motoristaId).get();
      if (doc.exists) {
        final data = doc.data()!;
        final cashback = data['cashback'] as Map<String, dynamic>?;

        if (cashback != null) {
          _pontosDisponiveis = (cashback['pontos'] ?? 0.0).toDouble();
          _cashbackAcumulado = (cashback['saldoReal'] ?? 0.0).toDouble();
          notifyListeners();
        }
      }
    } catch (e) {
      print('Erro ao carregar pontos: $e');
    }
  }

  // Carregar benefícios disponíveis
  Future<void> _carregarBeneficios() async {
    try {
      final querySnapshot = await _firestore
          .collection('cashback_beneficios')
          .where('ativo', isEqualTo: true)
          .orderBy('custoPontos')
          .get();

      _beneficiosDisponiveis = querySnapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();

      notifyListeners();
    } catch (e) {
      print('Erro ao carregar benefícios: $e');

      // Benefícios padrão se não conseguir carregar do Firebase
      _beneficiosDisponiveis = [
        {
          'id': 'cashback_10',
          'nome': 'Cashback R\$ 10,00',
          'descricao': 'Receba R\$ 10,00 diretamente na sua conta',
          'custoPontos': 200.0,
          'tipo': 'cashback',
          'valor': 10.0,
          'icone': 'money',
        },
        {
          'id': 'cashback_25',
          'nome': 'Cashback R\$ 25,00',
          'descricao': 'Receba R\$ 25,00 diretamente na sua conta',
          'custoPontos': 450.0,
          'tipo': 'cashback',
          'valor': 25.0,
          'icone': 'money',
        },
        {
          'id': 'desconto_combustivel',
          'nome': 'Desconto 10% Combustível',
          'descricao': 'Desconto de 10% em postos parceiros',
          'custoPontos': 300.0,
          'tipo': 'desconto_combustivel',
          'valor': 0.1,
          'icone': 'gas_station',
        },
        {
          'id': 'manutencao_basica',
          'nome': 'Manutenção Básica Gratuita',
          'descricao': 'Troca de óleo e revisão básica gratuita',
          'custoPontos': 800.0,
          'tipo': 'manutencao_gratuita',
          'icone': 'car_repair',
        },
      ];
      notifyListeners();
    }
  }

  // Carregar histórico
  Future<void> _carregarHistorico() async {
    try {
      final motoristaId = FirebaseAuth.instance.currentUser?.uid;
      if (motoristaId == null) return;

      final querySnapshot = await _firestore
          .collection('motoristas')
          .doc(motoristaId)
          .collection('cashback_historico')
          .orderBy('criadaEm', descending: true)
          .limit(50)
          .get();

      _historicoRecompensas = querySnapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();

      notifyListeners();
    } catch (e) {
      print('Erro ao carregar histórico: $e');
    }
  }

  // Carregar programa de fidelidade
  Future<void> _carregarProgramaFidelidade() async {
    try {
      final motoristaId = FirebaseAuth.instance.currentUser?.uid;
      if (motoristaId == null) return;

      // Calcular estatísticas do programa
      final now = DateTime.now();
      final inicioMes = DateTime(now.year, now.month, 1);

      final corridasMes = await _firestore
          .collection('corridas')
          .where('motoristaId', isEqualTo: motoristaId)
          .where('status', isEqualTo: 'concluida')
          .where('concluidaEm', isGreaterThan: Timestamp.fromDate(inicioMes))
          .get();

      final corridasTotal = corridasMes.docs.length;

      // Definir nível baseado em corridas mensais
      String nivel = 'Bronze';
      double multiplicadorBonus = 1.0;
      int corridasProximoNivel = 20;

      if (corridasTotal >= 50) {
        nivel = 'Diamante';
        multiplicadorBonus = 2.0;
        corridasProximoNivel = 0;
      } else if (corridasTotal >= 30) {
        nivel = 'Ouro';
        multiplicadorBonus = 1.5;
        corridasProximoNivel = 50 - corridasTotal;
      } else if (corridasTotal >= 20) {
        nivel = 'Prata';
        multiplicadorBonus = 1.2;
        corridasProximoNivel = 30 - corridasTotal;
      } else {
        corridasProximoNivel = 20 - corridasTotal;
      }

      _programaFidelidade = {
        'nivel': nivel,
        'corridasMes': corridasTotal,
        'multiplicadorBonus': multiplicadorBonus,
        'corridasProximoNivel': corridasProximoNivel,
        'beneficios': _obterBeneficiosNivel(nivel),
        'progressoNivel': corridasTotal / (corridasTotal + corridasProximoNivel).clamp(1, 50),
      };

      notifyListeners();
    } catch (e) {
      print('Erro ao carregar programa de fidelidade: $e');
    }
  }

  // Obter benefícios por nível
  List<String> _obterBeneficiosNivel(String nivel) {
    switch (nivel) {
      case 'Diamante':
        return [
          'Bônus de 100% nos pontos',
          'Cashback prioritário',
          'Benefícios exclusivos',
          'Suporte premium',
        ];
      case 'Ouro':
        return [
          'Bônus de 50% nos pontos',
          'Descontos especiais',
          'Acesso antecipado a promoções',
        ];
      case 'Prata':
        return [
          'Bônus de 20% nos pontos',
          'Descontos em parceiros',
        ];
      default:
        return [
          'Acumulo básico de pontos',
          'Benefícios padrão',
        ];
    }
  }

  // Obter relatório de pontos
  Map<String, dynamic> obterRelatorioMensal() {
    final now = DateTime.now();
    final inicioMes = DateTime(now.year, now.month, 1);

    final pontosMes = _historicoRecompensas
        .where((h) => (h['criadaEm'] as Timestamp).toDate().isAfter(inicioMes))
        .fold(0.0, (sum, h) => sum + (h['pontos'] as double));

    final resgateMes = _historicoRecompensas
        .where((h) => h['tipo'] == 'resgate' && (h['criadaEm'] as Timestamp).toDate().isAfter(inicioMes))
        .fold(0.0, (sum, h) => sum + (h['pontos'] as double).abs());

    return {
      'pontosGanhosMes': pontosMes,
      'pontosResgatadosMes': resgateMes,
      'saldoAtual': _pontosDisponiveis,
      'cashbackAcumulado': _cashbackAcumulado,
      'programaFidelidade': _programaFidelidade,
    };
  }
}
