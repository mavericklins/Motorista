import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/financial_model.dart';

class FinancialServiceProfessional {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Obter dados financeiros do motorista atual
  static Future<FinancialModel?> obterDadosFinanceiros() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      // Buscar dados financeiros existentes
      final doc = await _firestore
          .collection('financeiro_motorista')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        return FinancialModel.fromFirestore(doc);
      } else {
        // Criar dados financeiros iniciais
        final initialData = FinancialModel(
          id: user.uid,
          motoristaId: user.uid,
          saldoAtual: 0.0,
          ganhoHoje: 0.0,
          ganhoSemana: 0.0,
          ganhoMes: 0.0,
          ganhoTotal: 0.0,
          creditosDisponiveis: 0.0,
          valorPendente: 0.0,
          corridasHoje: 0,
          corridasSemana: 0,
          corridasMes: 0,
          corridasTotal: 0,
          avaliacaoMedia: 5.0,
          atualizadoEm: DateTime.now(),
        );

        await _firestore
            .collection('financeiro_motorista')
            .doc(user.uid)
            .set(initialData.toFirestore());

        return initialData;
      }
    } catch (e) {
      print('❌ Erro ao obter dados financeiros: $e');
      return null;
    }
  }

  /// Atualizar dados financeiros após corrida concluída
  static Future<void> atualizarGanhosCorrida({
    required String motoristaId,
    required double valorGanho,
    required String corridaId,
  }) async {
    try {
      final docRef = _firestore.collection('financeiro_motorista').doc(motoristaId);
      
      await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(docRef);
        
        FinancialModel currentData;
        if (doc.exists) {
          currentData = FinancialModel.fromFirestore(doc);
        } else {
          currentData = FinancialModel(
            id: motoristaId,
            motoristaId: motoristaId,
            saldoAtual: 0.0,
            ganhoHoje: 0.0,
            ganhoSemana: 0.0,
            ganhoMes: 0.0,
            ganhoTotal: 0.0,
            creditosDisponiveis: 0.0,
            valorPendente: 0.0,
            corridasHoje: 0,
            corridasSemana: 0,
            corridasMes: 0,
            corridasTotal: 0,
            avaliacaoMedia: 5.0,
            atualizadoEm: DateTime.now(),
          );
        }

        // Verificar se é hoje, esta semana, este mês
        final hoje = DateTime.now();
        final inicioHoje = DateTime(hoje.year, hoje.month, hoje.day);
        final inicioSemana = hoje.subtract(Duration(days: hoje.weekday - 1));
        final inicioMes = DateTime(hoje.year, hoje.month, 1);

        final isHoje = currentData.atualizadoEm.isAfter(inicioHoje);
        final isSemana = currentData.atualizadoEm.isAfter(inicioSemana);
        final isMes = currentData.atualizadoEm.isAfter(inicioMes);

        // Atualizar dados
        final updatedData = currentData.copyWith(
          saldoAtual: currentData.saldoAtual + valorGanho,
          ganhoHoje: isHoje ? currentData.ganhoHoje + valorGanho : valorGanho,
          ganhoSemana: isSemana ? currentData.ganhoSemana + valorGanho : valorGanho,
          ganhoMes: isMes ? currentData.ganhoMes + valorGanho : valorGanho,
          ganhoTotal: currentData.ganhoTotal + valorGanho,
          corridasHoje: isHoje ? currentData.corridasHoje + 1 : 1,
          corridasSemana: isSemana ? currentData.corridasSemana + 1 : 1,
          corridasMes: isMes ? currentData.corridasMes + 1 : 1,
          corridasTotal: currentData.corridasTotal + 1,
          atualizadoEm: DateTime.now(),
        );

        transaction.set(docRef, updatedData.toFirestore());

        // Registrar transação
        await _registrarTransacao(
          motoristaId: motoristaId,
          tipo: 'ganho',
          valor: valorGanho,
          descricao: 'Ganho de corrida',
          corridaId: corridaId,
        );
      });

      print('✅ Ganhos atualizados: R\$ $valorGanho');
    } catch (e) {
      print('❌ Erro ao atualizar ganhos: $e');
    }
  }

  /// Registrar transação financeira
  static Future<void> _registrarTransacao({
    required String motoristaId,
    required String tipo,
    required double valor,
    required String descricao,
    String? corridaId,
    String? pagamentoId,
  }) async {
    try {
      final transaction = TransactionModel(
        id: '',
        motoristaId: motoristaId,
        tipo: tipo,
        valor: valor,
        descricao: descricao,
        corridaId: corridaId,
        pagamentoId: pagamentoId,
        status: 'concluido',
        criadoEm: DateTime.now(),
        processadoEm: DateTime.now(),
      );

      await _firestore.collection('transacoes_financeiras').add(transaction.toFirestore());
    } catch (e) {
      print('❌ Erro ao registrar transação: $e');
    }
  }

  /// Obter histórico de transações
  static Future<List<TransactionModel>> obterHistoricoTransacoes() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final snapshot = await _firestore
          .collection('transacoes_financeiras')
          .where('motoristaId', isEqualTo: user.uid)
          .orderBy('criadoEm', descending: true)
          .limit(50)
          .get();

      return snapshot.docs.map((doc) => TransactionModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('❌ Erro ao obter histórico de transações: $e');
      return [];
    }
  }

  /// Stream de dados financeiros em tempo real
  static Stream<FinancialModel?> streamDadosFinanceiros() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(null);

    return _firestore
        .collection('financeiro_motorista')
        .doc(user.uid)
        .snapshots()
        .map((doc) {
          if (doc.exists) {
            return FinancialModel.fromFirestore(doc);
          }
          return null;
        });
  }

  /// Solicitar saque
  static Future<bool> solicitarSaque({
    required double valor,
    required String metodoPagamento,
    required Map<String, dynamic> dadosPagamento,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Verificar saldo disponível
      final financialData = await obterDadosFinanceiros();
      if (financialData == null || financialData.saldoAtual < valor) {
        throw Exception('Saldo insuficiente');
      }

      // Valor mínimo para saque
      if (valor < 10.0) {
        throw Exception('Valor mínimo para saque é R\$ 10,00');
      }

      // Criar solicitação de saque
      final withdrawal = WithdrawalModel(
        id: '',
        motoristaId: user.uid,
        valor: valor,
        metodoPagamento: metodoPagamento,
        dadosPagamento: dadosPagamento,
        status: 'solicitado',
        solicitadoEm: DateTime.now(),
      );

      await _firestore.collection('saques').add(withdrawal.toFirestore());

      // Atualizar saldo (descontar valor solicitado)
      await _atualizarSaldo(user.uid, -valor);

      // Registrar transação
      await _registrarTransacao(
        motoristaId: user.uid,
        tipo: 'saque',
        valor: -valor,
        descricao: 'Saque solicitado via ${metodoPagamento.toUpperCase()}',
      );

      return true;
    } catch (e) {
      print('❌ Erro ao solicitar saque: $e');
      return false;
    }
  }

  /// Atualizar saldo
  static Future<void> _atualizarSaldo(String motoristaId, double valor) async {
    try {
      final docRef = _firestore.collection('financeiro_motorista').doc(motoristaId);
      
      await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(docRef);
        
        if (doc.exists) {
          final currentData = FinancialModel.fromFirestore(doc);
          final updatedData = currentData.copyWith(
            saldoAtual: currentData.saldoAtual + valor,
            atualizadoEm: DateTime.now(),
          );
          
          transaction.update(docRef, updatedData.toFirestore());
        }
      });
    } catch (e) {
      print('❌ Erro ao atualizar saldo: $e');
    }
  }

  /// Obter histórico de saques
  static Future<List<WithdrawalModel>> obterHistoricoSaques() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final snapshot = await _firestore
          .collection('saques')
          .where('motoristaId', isEqualTo: user.uid)
          .orderBy('solicitadoEm', descending: true)
          .get();

      return snapshot.docs.map((doc) => WithdrawalModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('❌ Erro ao obter histórico de saques: $e');
      return [];
    }
  }

  /// Calcular estatísticas detalhadas
  static Future<Map<String, dynamic>> calcularEstatisticasDetalhadas(String motoristaId) async {
    try {
      final hoje = DateTime.now();
      final inicioSemana = hoje.subtract(Duration(days: hoje.weekday - 1));
      final inicioMes = DateTime(hoje.year, hoje.month, 1);
      final inicioAno = DateTime(hoje.year, 1, 1);

      // Buscar todas as transações do ano
      final snapshot = await _firestore
          .collection('transacoes_financeiras')
          .where('motoristaId', isEqualTo: motoristaId)
          .where('tipo', isEqualTo: 'ganho')
          .where('criadoEm', isGreaterThanOrEqualTo: Timestamp.fromDate(inicioAno))
          .orderBy('criadoEm', descending: true)
          .get();

      final transacoes = snapshot.docs.map((doc) => TransactionModel.fromFirestore(doc)).toList();

      // Calcular estatísticas
      double ganhoSemana = 0;
      double ganhoMes = 0;
      double ganhoAno = 0;
      int corridasSemana = 0;
      int corridasMes = 0;
      int corridasAno = 0;

      for (final transacao in transacoes) {
        final valor = transacao.valor;
        
        if (transacao.criadoEm.isAfter(inicioSemana)) {
          ganhoSemana += valor;
          corridasSemana++;
        }
        
        if (transacao.criadoEm.isAfter(inicioMes)) {
          ganhoMes += valor;
          corridasMes++;
        }
        
        ganhoAno += valor;
        corridasAno++;
      }

      return {
        'ganhoSemana': ganhoSemana,
        'ganhoMes': ganhoMes,
        'ganhoAno': ganhoAno,
        'corridasSemana': corridasSemana,
        'corridasMes': corridasMes,
        'corridasAno': corridasAno,
        'mediaPorCorrida': corridasAno > 0 ? ganhoAno / corridasAno : 0.0,
        'melhorDia': _calcularMelhorDia(transacoes),
        'tendencia': _calcularTendencia(transacoes),
      };
    } catch (e) {
      print('❌ Erro ao calcular estatísticas: $e');
      return {};
    }
  }

  /// Calcular melhor dia da semana
  static Map<String, dynamic> _calcularMelhorDia(List<TransactionModel> transacoes) {
    final ganhoPorDia = <int, double>{};
    final corridasPorDia = <int, int>{};

    for (final transacao in transacoes) {
      final diaSemana = transacao.criadoEm.weekday;
      ganhoPorDia[diaSemana] = (ganhoPorDia[diaSemana] ?? 0) + transacao.valor;
      corridasPorDia[diaSemana] = (corridasPorDia[diaSemana] ?? 0) + 1;
    }

    if (ganhoPorDia.isEmpty) return {'dia': 'N/A', 'valor': 0.0};

    final melhorDia = ganhoPorDia.entries.reduce((a, b) => a.value > b.value ? a : b);
    
    final nomesDias = ['', 'Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo'];
    
    return {
      'dia': nomesDias[melhorDia.key],
      'valor': melhorDia.value,
      'corridas': corridasPorDia[melhorDia.key] ?? 0,
    };
  }

  /// Calcular tendência de ganhos
  static String _calcularTendencia(List<TransactionModel> transacoes) {
    if (transacoes.length < 7) return 'Dados insuficientes';

    final ultimaSemana = transacoes.take(7).fold(0.0, (sum, t) => sum + t.valor);
    final semanaAnterior = transacoes.skip(7).take(7).fold(0.0, (sum, t) => sum + t.valor);

    if (semanaAnterior == 0) return 'Estável';

    final variacao = ((ultimaSemana - semanaAnterior) / semanaAnterior) * 100;

    if (variacao > 10) return 'Crescendo';
    if (variacao < -10) return 'Decrescendo';
    return 'Estável';
  }

  /// Resetar dados diários (para ser chamado via Cloud Function)
  static Future<void> resetarDadosDiarios() async {
    try {
      final snapshot = await _firestore.collection('financeiro_motorista').get();
      
      for (final doc in snapshot.docs) {
        await doc.reference.update({
          'ganhoHoje': 0.0,
          'corridasHoje': 0,
          'atualizadoEm': Timestamp.now(),
        });
      }
      
      print('✅ Dados diários resetados');
    } catch (e) {
      print('❌ Erro ao resetar dados diários: $e');
    }
  }
}

