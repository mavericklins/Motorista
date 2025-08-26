
import 'package:cloud_firestore/cloud_firestore.dart';

class DriverGoals {
  final String id;
  final String motoristaId;
  final Map<String, GoalTarget> metasDiarias;
  final Map<String, GoalTarget> metasSemanais;
  final Map<String, GoalTarget> metasMensais;
  final List<Achievement> conquistas;
  final int pontuacao;
  final int nivel;
  final Map<String, dynamic> estatisticas;
  final Timestamp atualizadoEm;

  DriverGoals({
    required this.id,
    required this.motoristaId,
    required this.metasDiarias,
    required this.metasSemanais,
    required this.metasMensais,
    required this.conquistas,
    required this.pontuacao,
    required this.nivel,
    required this.estatisticas,
    required this.atualizadoEm,
  });

  factory DriverGoals.fromMap(Map<String, dynamic> map, String docId) {
    return DriverGoals(
      id: docId,
      motoristaId: map['motoristaId'] ?? '',
      metasDiarias: (map['metasDiarias'] as Map<String, dynamic>? ?? {})
          .map((k, v) => MapEntry(k, GoalTarget.fromMap(v))),
      metasSemanais: (map['metasSemanais'] as Map<String, dynamic>? ?? {})
          .map((k, v) => MapEntry(k, GoalTarget.fromMap(v))),
      metasMensais: (map['metasMensais'] as Map<String, dynamic>? ?? {})
          .map((k, v) => MapEntry(k, GoalTarget.fromMap(v))),
      conquistas: (map['conquistas'] as List<dynamic>? ?? [])
          .map((c) => Achievement.fromMap(c))
          .toList(),
      pontuacao: map['pontuacao'] ?? 0,
      nivel: map['nivel'] ?? 1,
      estatisticas: Map<String, dynamic>.from(map['estatisticas'] ?? {}),
      atualizadoEm: map['atualizadoEm'] ?? Timestamp.now(),
    );
  }
}

class GoalTarget {
  final String tipo; // corridas, ganhos, tempo_online, etc.
  final double objetivo;
  final double atual;
  final bool concluida;
  final DateTime? dataLimite;
  final double? bonus;

  GoalTarget({
    required this.tipo,
    required this.objetivo,
    required this.atual,
    required this.concluida,
    this.dataLimite,
    this.bonus,
  });

  factory GoalTarget.fromMap(Map<String, dynamic> map) {
    return GoalTarget(
      tipo: map['tipo'] ?? '',
      objetivo: (map['objetivo'] ?? 0.0).toDouble(),
      atual: (map['atual'] ?? 0.0).toDouble(),
      concluida: map['concluida'] ?? false,
      dataLimite: map['dataLimite'] != null
          ? (map['dataLimite'] as Timestamp).toDate()
          : null,
      bonus: map['bonus']?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tipo': tipo,
      'objetivo': objetivo,
      'atual': atual,
      'concluida': concluida,
      'dataLimite': dataLimite != null ? Timestamp.fromDate(dataLimite!) : null,
      'bonus': bonus,
    };
  }

  double get progresso => objetivo > 0 ? (atual / objetivo).clamp(0.0, 1.0) : 0.0;
}

class Achievement {
  final String id;
  final String titulo;
  final String descricao;
  final String icone;
  final DateTime conquistadoEm;
  final int pontos;

  Achievement({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.icone,
    required this.conquistadoEm,
    required this.pontos,
  });

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'] ?? '',
      titulo: map['titulo'] ?? '',
      descricao: map['descricao'] ?? '',
      icone: map['icone'] ?? '🏆',
      conquistadoEm: (map['conquistadoEm'] as Timestamp).toDate(),
      pontos: map['pontos'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'icone': icone,
      'conquistadoEm': Timestamp.fromDate(conquistadoEm),
      'pontos': pontos,
    };
  }
}
