import 'package:cloud_firestore/cloud_firestore.dart';

class Ride {
  final String id;
  final String passageiroId;
  final String passageiroNome;
  final String passageiroTelefone;
  final String motoristaId;
  final String enderecoOrigem;
  final String enderecoDestino;
  final double origemLat;
  final double origemLon;
  final double destinoLat;
  final double destinoLon;
  final double valor;
  final String formaPagamento;
  final String status;
  final DateTime criadaEm;
  final DateTime? aceitaEm;
  final DateTime? iniciadaEm;
  final DateTime? concluidaEm;
  final DateTime? canceladaEm;
  final String? motivoCancelamento;
  final List<String>? paradasAdicionais;
  final bool corridaCompartilhada;
  final int? maxPassageiros;
  final double? avaliacaoPassageiro;
  final double? avaliacaoMotorista;

  Ride({
    required this.id,
    required this.passageiroId,
    required this.passageiroNome,
    required this.passageiroTelefone,
    required this.motoristaId,
    required this.enderecoOrigem,
    required this.enderecoDestino,
    required this.origemLat,
    required this.origemLon,
    required this.destinoLat,
    required this.destinoLon,
    required this.valor,
    required this.formaPagamento,
    required this.status,
    required this.criadaEm,
    this.aceitaEm,
    this.iniciadaEm,
    this.concluidaEm,
    this.canceladaEm,
    this.motivoCancelamento,
    this.paradasAdicionais,
    this.corridaCompartilhada = false,
    this.maxPassageiros,
    this.avaliacaoPassageiro,
    this.avaliacaoMotorista,
  });

  factory Ride.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return Ride(
      id: doc.id,
      passageiroId: data['passageiroId'] ?? '',
      passageiroNome: data['passageiroNome'] ?? '',
      passageiroTelefone: data['passageiroTelefone'] ?? '',
      motoristaId: data['motoristaId'] ?? '',
      enderecoOrigem: data['enderecoOrigem'] ?? '',
      enderecoDestino: data['enderecoDestino'] ?? '',
      origemLat: (data['origemLat'] ?? 0).toDouble(),
      origemLon: (data['origemLon'] ?? 0).toDouble(),
      destinoLat: (data['destinoLat'] ?? 0).toDouble(),
      destinoLon: (data['destinoLon'] ?? 0).toDouble(),
      valor: (data['valor'] ?? 0).toDouble(),
      formaPagamento: data['formaPagamento'] ?? '',
      status: data['status'] ?? '',
      criadaEm: (data['criadaEm'] as Timestamp?)?.toDate() ?? DateTime.now(),
      aceitaEm: (data['aceitaEm'] as Timestamp?)?.toDate(),
      iniciadaEm: (data['iniciadaEm'] as Timestamp?)?.toDate(),
      concluidaEm: (data['concluidaEm'] as Timestamp?)?.toDate(),
      canceladaEm: (data['canceladaEm'] as Timestamp?)?.toDate(),
      motivoCancelamento: data['motivoCancelamento'],
      paradasAdicionais: data['paradasAdicionais'] != null 
          ? List<String>.from(data['paradasAdicionais'])
          : null,
      corridaCompartilhada: data['corridaCompartilhada'] ?? false,
      maxPassageiros: data['maxPassageiros'],
      avaliacaoPassageiro: data['avaliacaoPassageiro']?.toDouble(),
      avaliacaoMotorista: data['avaliacaoMotorista']?.toDouble(),
    );
  }

  Ride copyWith({
    String? status,
    DateTime? aceitaEm,
    DateTime? iniciadaEm,
    DateTime? concluidaEm,
    DateTime? canceladaEm,
    String? motivoCancelamento,
    double? avaliacaoPassageiro,
    double? avaliacaoMotorista,
  }) {
    return Ride(
      id: id,
      passageiroId: passageiroId,
      passageiroNome: passageiroNome,
      passageiroTelefone: passageiroTelefone,
      motoristaId: motoristaId,
      enderecoOrigem: enderecoOrigem,
      enderecoDestino: enderecoDestino,
      origemLat: origemLat,
      origemLon: origemLon,
      destinoLat: destinoLat,
      destinoLon: destinoLon,
      valor: valor,
      formaPagamento: formaPagamento,
      status: status ?? this.status,
      criadaEm: criadaEm,
      aceitaEm: aceitaEm ?? this.aceitaEm,
      iniciadaEm: iniciadaEm ?? this.iniciadaEm,
      concluidaEm: concluidaEm ?? this.concluidaEm,
      canceladaEm: canceladaEm ?? this.canceladaEm,
      motivoCancelamento: motivoCancelamento ?? this.motivoCancelamento,
      paradasAdicionais: paradasAdicionais,
      corridaCompartilhada: corridaCompartilhada,
      maxPassageiros: maxPassageiros,
      avaliacaoPassageiro: avaliacaoPassageiro ?? this.avaliacaoPassageiro,
      avaliacaoMotorista: avaliacaoMotorista ?? this.avaliacaoMotorista,
    );
  }

  String get statusFormatado {
    switch (status) {
      case 'solicitada':
        return 'Solicitada';
      case 'aceita':
        return 'Aceita';
      case 'em_andamento':
        return 'Em andamento';
      case 'concluida':
        return 'Concluída';
      case 'cancelada_passageiro':
        return 'Cancelada pelo passageiro';
      case 'cancelada_motorista':
        return 'Cancelada pelo motorista';
      default:
        return 'Status desconhecido';
    }
  }

  String get valorFormatado {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  Duration? get duracaoTotal {
    if (iniciadaEm != null && concluidaEm != null) {
      return concluidaEm!.difference(iniciadaEm!);
    }
    return null;
  }

  String get duracaoFormatada {
    final duracao = duracaoTotal;
    if (duracao == null) return '--';
    
    final horas = duracao.inHours;
    final minutos = duracao.inMinutes % 60;
    
    if (horas > 0) {
      return '${horas}h ${minutos}min';
    } else {
      return '${minutos}min';
    }
  }

  bool get podeSerIniciada => status == 'aceita';
  bool get podeSerConcluida => status == 'em_andamento';
  bool get podeSerCancelada => status == 'aceita' || status == 'em_andamento';
}

