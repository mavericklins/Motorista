import 'package:cloud_firestore/cloud_firestore.dart';

class FinancialModel {
  final String id;
  final String motoristaId;
  final double saldoAtual;
  final double ganhoHoje;
  final double ganhoSemana;
  final double ganhoMes;
  final double ganhoTotal;
  final double creditosDisponiveis;
  final double valorPendente;
  final int corridasHoje;
  final int corridasSemana;
  final int corridasMes;
  final int corridasTotal;
  final double avaliacaoMedia;
  final DateTime atualizadoEm;

  FinancialModel({
    required this.id,
    required this.motoristaId,
    required this.saldoAtual,
    required this.ganhoHoje,
    required this.ganhoSemana,
    required this.ganhoMes,
    required this.ganhoTotal,
    required this.creditosDisponiveis,
    required this.valorPendente,
    required this.corridasHoje,
    required this.corridasSemana,
    required this.corridasMes,
    required this.corridasTotal,
    required this.avaliacaoMedia,
    required this.atualizadoEm,
  });

  factory FinancialModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return FinancialModel(
      id: doc.id,
      motoristaId: data['motoristaId'] ?? '',
      saldoAtual: (data['saldoAtual'] ?? 0).toDouble(),
      ganhoHoje: (data['ganhoHoje'] ?? 0).toDouble(),
      ganhoSemana: (data['ganhoSemana'] ?? 0).toDouble(),
      ganhoMes: (data['ganhoMes'] ?? 0).toDouble(),
      ganhoTotal: (data['ganhoTotal'] ?? 0).toDouble(),
      creditosDisponiveis: (data['creditosDisponiveis'] ?? 0).toDouble(),
      valorPendente: (data['valorPendente'] ?? 0).toDouble(),
      corridasHoje: data['corridasHoje'] ?? 0,
      corridasSemana: data['corridasSemana'] ?? 0,
      corridasMes: data['corridasMes'] ?? 0,
      corridasTotal: data['corridasTotal'] ?? 0,
      avaliacaoMedia: (data['avaliacaoMedia'] ?? 5.0).toDouble(),
      atualizadoEm: (data['atualizadoEm'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'motoristaId': motoristaId,
      'saldoAtual': saldoAtual,
      'ganhoHoje': ganhoHoje,
      'ganhoSemana': ganhoSemana,
      'ganhoMes': ganhoMes,
      'ganhoTotal': ganhoTotal,
      'creditosDisponiveis': creditosDisponiveis,
      'valorPendente': valorPendente,
      'corridasHoje': corridasHoje,
      'corridasSemana': corridasSemana,
      'corridasMes': corridasMes,
      'corridasTotal': corridasTotal,
      'avaliacaoMedia': avaliacaoMedia,
      'atualizadoEm': Timestamp.fromDate(atualizadoEm),
    };
  }

  // Formatações
  String get saldoAtualFormatado => 'R\$ ${saldoAtual.toStringAsFixed(2).replaceAll('.', ',')}';
  String get ganhoHojeFormatado => 'R\$ ${ganhoHoje.toStringAsFixed(2).replaceAll('.', ',')}';
  String get ganhoSemanaFormatado => 'R\$ ${ganhoSemana.toStringAsFixed(2).replaceAll('.', ',')}';
  String get ganhoMesFormatado => 'R\$ ${ganhoMes.toStringAsFixed(2).replaceAll('.', ',')}';
  String get ganhoTotalFormatado => 'R\$ ${ganhoTotal.toStringAsFixed(2).replaceAll('.', ',')}';
  String get creditosDisponiveisFormatado => 'R\$ ${creditosDisponiveis.toStringAsFixed(2).replaceAll('.', ',')}';
  String get valorPendenteFormatado => 'R\$ ${valorPendente.toStringAsFixed(2).replaceAll('.', ',')}';

  double get mediaPorCorrida => corridasTotal > 0 ? ganhoTotal / corridasTotal : 0.0;
  String get mediaPorCorridaFormatada => 'R\$ ${mediaPorCorrida.toStringAsFixed(2).replaceAll('.', ',')}';

  FinancialModel copyWith({
    double? saldoAtual,
    double? ganhoHoje,
    double? ganhoSemana,
    double? ganhoMes,
    double? ganhoTotal,
    double? creditosDisponiveis,
    double? valorPendente,
    int? corridasHoje,
    int? corridasSemana,
    int? corridasMes,
    int? corridasTotal,
    double? avaliacaoMedia,
    DateTime? atualizadoEm,
  }) {
    return FinancialModel(
      id: id,
      motoristaId: motoristaId,
      saldoAtual: saldoAtual ?? this.saldoAtual,
      ganhoHoje: ganhoHoje ?? this.ganhoHoje,
      ganhoSemana: ganhoSemana ?? this.ganhoSemana,
      ganhoMes: ganhoMes ?? this.ganhoMes,
      ganhoTotal: ganhoTotal ?? this.ganhoTotal,
      creditosDisponiveis: creditosDisponiveis ?? this.creditosDisponiveis,
      valorPendente: valorPendente ?? this.valorPendente,
      corridasHoje: corridasHoje ?? this.corridasHoje,
      corridasSemana: corridasSemana ?? this.corridasSemana,
      corridasMes: corridasMes ?? this.corridasMes,
      corridasTotal: corridasTotal ?? this.corridasTotal,
      avaliacaoMedia: avaliacaoMedia ?? this.avaliacaoMedia,
      atualizadoEm: atualizadoEm ?? DateTime.now(),
    );
  }
}

class TransactionModel {
  final String id;
  final String motoristaId;
  final String tipo; // ganho, saque, bonus, taxa, estorno
  final double valor;
  final String descricao;
  final String? corridaId;
  final String? pagamentoId;
  final String status; // pendente, concluido, falhou
  final DateTime criadoEm;
  final DateTime? processadoEm;

  TransactionModel({
    required this.id,
    required this.motoristaId,
    required this.tipo,
    required this.valor,
    required this.descricao,
    this.corridaId,
    this.pagamentoId,
    required this.status,
    required this.criadoEm,
    this.processadoEm,
  });

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return TransactionModel(
      id: doc.id,
      motoristaId: data['motoristaId'] ?? '',
      tipo: data['tipo'] ?? '',
      valor: (data['valor'] ?? 0).toDouble(),
      descricao: data['descricao'] ?? '',
      corridaId: data['corridaId'],
      pagamentoId: data['pagamentoId'],
      status: data['status'] ?? 'pendente',
      criadoEm: (data['criadoEm'] as Timestamp?)?.toDate() ?? DateTime.now(),
      processadoEm: (data['processadoEm'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'motoristaId': motoristaId,
      'tipo': tipo,
      'valor': valor,
      'descricao': descricao,
      'corridaId': corridaId,
      'pagamentoId': pagamentoId,
      'status': status,
      'criadoEm': Timestamp.fromDate(criadoEm),
      'processadoEm': processadoEm != null ? Timestamp.fromDate(processadoEm!) : null,
    };
  }

  String get valorFormatado {
    final sinal = valor >= 0 ? '+' : '';
    return '$sinal R\$ ${valor.abs().toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String get tipoFormatado {
    switch (tipo) {
      case 'ganho':
        return 'Ganho de Corrida';
      case 'saque':
        return 'Saque';
      case 'bonus':
        return 'Bônus';
      case 'taxa':
        return 'Taxa';
      case 'estorno':
        return 'Estorno';
      default:
        return 'Transação';
    }
  }

  bool get isPositive => valor >= 0;
}

class WithdrawalModel {
  final String id;
  final String motoristaId;
  final double valor;
  final String metodoPagamento; // pix, transferencia
  final Map<String, dynamic> dadosPagamento;
  final String status; // solicitado, processando, concluido, falhou
  final DateTime solicitadoEm;
  final DateTime? processadoEm;
  final String? falhaRazao;

  WithdrawalModel({
    required this.id,
    required this.motoristaId,
    required this.valor,
    required this.metodoPagamento,
    required this.dadosPagamento,
    required this.status,
    required this.solicitadoEm,
    this.processadoEm,
    this.falhaRazao,
  });

  factory WithdrawalModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return WithdrawalModel(
      id: doc.id,
      motoristaId: data['motoristaId'] ?? '',
      valor: (data['valor'] ?? 0).toDouble(),
      metodoPagamento: data['metodoPagamento'] ?? '',
      dadosPagamento: data['dadosPagamento'] ?? {},
      status: data['status'] ?? 'solicitado',
      solicitadoEm: (data['solicitadoEm'] as Timestamp?)?.toDate() ?? DateTime.now(),
      processadoEm: (data['processadoEm'] as Timestamp?)?.toDate(),
      falhaRazao: data['falhaRazao'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'motoristaId': motoristaId,
      'valor': valor,
      'metodoPagamento': metodoPagamento,
      'dadosPagamento': dadosPagamento,
      'status': status,
      'solicitadoEm': Timestamp.fromDate(solicitadoEm),
      'processadoEm': processadoEm != null ? Timestamp.fromDate(processadoEm!) : null,
      'falhaRazao': falhaRazao,
    };
  }

  String get valorFormatado => 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  
  String get statusFormatado {
    switch (status) {
      case 'solicitado':
        return 'Solicitado';
      case 'processando':
        return 'Processando';
      case 'concluido':
        return 'Concluído';
      case 'falhou':
        return 'Falhou';
      default:
        return 'Desconhecido';
    }
  }

  String get metodoPagamentoFormatado {
    switch (metodoPagamento) {
      case 'pix':
        return 'PIX';
      case 'transferencia':
        return 'Transferência Bancária';
      default:
        return 'Não informado';
    }
  }
}

