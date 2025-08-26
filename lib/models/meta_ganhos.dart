
import 'package:cloud_firestore/cloud_firestore.dart';

class MetaGanhos {
  final String id;
  final String motoristaId;
  final double metaDiaria;
  final double metaSemanal;
  final double metaMensal;
  final double ganhoAtualDia;
  final double ganhoAtualSemana;
  final double ganhoAtualMes;
  final DateTime criadaEm;
  final DateTime? atualizadaEm;

  MetaGanhos({
    required this.id,
    required this.motoristaId,
    required this.metaDiaria,
    required this.metaSemanal,
    required this.metaMensal,
    this.ganhoAtualDia = 0.0,
    this.ganhoAtualSemana = 0.0,
    this.ganhoAtualMes = 0.0,
    required this.criadaEm,
    this.atualizadaEm,
  });

  factory MetaGanhos.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return MetaGanhos(
      id: doc.id,
      motoristaId: data['motoristaId'] ?? '',
      metaDiaria: (data['metaDiaria'] ?? 0.0).toDouble(),
      metaSemanal: (data['metaSemanal'] ?? 0.0).toDouble(),
      metaMensal: (data['metaMensal'] ?? 0.0).toDouble(),
      ganhoAtualDia: (data['ganhoAtualDia'] ?? 0.0).toDouble(),
      ganhoAtualSemana: (data['ganhoAtualSemana'] ?? 0.0).toDouble(),
      ganhoAtualMes: (data['ganhoAtualMes'] ?? 0.0).toDouble(),
      criadaEm: (data['criadaEm'] as Timestamp?)?.toDate() ?? DateTime.now(),
      atualizadaEm: (data['atualizadaEm'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'motoristaId': motoristaId,
      'metaDiaria': metaDiaria,
      'metaSemanal': metaSemanal,
      'metaMensal': metaMensal,
      'ganhoAtualDia': ganhoAtualDia,
      'ganhoAtualSemana': ganhoAtualSemana,
      'ganhoAtualMes': ganhoAtualMes,
      'criadaEm': Timestamp.fromDate(criadaEm),
      'atualizadaEm': atualizadaEm != null ? Timestamp.fromDate(atualizadaEm!) : null,
    };
  }

  double get progressoDiario => metaDiaria > 0 ? (ganhoAtualDia / metaDiaria).clamp(0.0, 1.0) : 0.0;
  double get progressoSemanal => metaSemanal > 0 ? (ganhoAtualSemana / metaSemanal).clamp(0.0, 1.0) : 0.0;
  double get progressoMensal => metaMensal > 0 ? (ganhoAtualMes / metaMensal).clamp(0.0, 1.0) : 0.0;

  bool get metaDiariaAlcancada => ganhoAtualDia >= metaDiaria;
  bool get metaSemanalAlcancada => ganhoAtualSemana >= metaSemanal;
  bool get metaMensalAlcancada => ganhoAtualMes >= metaMensal;

  double get faltaDiaria => (metaDiaria - ganhoAtualDia).clamp(0.0, double.infinity);
  double get faltaSemanal => (metaSemanal - ganhoAtualSemana).clamp(0.0, double.infinity);
  double get faltaMensal => (metaMensal - ganhoAtualMes).clamp(0.0, double.infinity);
}
