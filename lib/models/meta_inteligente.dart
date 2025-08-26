
import 'package:cloud_firestore/cloud_firestore.dart';

enum TipoMeta {
  ganhos,
  corridas,
  eficiencia,
  consistencia,
  crescimento,
  estrategico,
}

enum PeriodoMeta {
  diario,
  semanal,
  mensal,
  personalizado,
}

enum DificuldadeMeta {
  facil,
  media,
  dificil,
}

enum CategoriaMeta {
  produtividade,
  crescimento,
  habito,
  estrategia,
  social,
}

class MetaInteligente {
  final String id;
  final TipoMeta tipo;
  final PeriodoMeta periodo;
  final String titulo;
  final String descricao;
  final double valorObjetivo;
  final double valorAtual;
  final DateTime dataInicio;
  final DateTime dataFim;
  final double recompensa;
  final DificuldadeMeta dificuldade;
  final CategoriaMeta categoria;
  final Map<String, dynamic> condicoes;
  final bool ativa;
  final DateTime? dataCompletada;

  MetaInteligente({
    required this.id,
    required this.tipo,
    required this.periodo,
    required this.titulo,
    required this.descricao,
    required this.valorObjetivo,
    required this.valorAtual,
    required this.dataInicio,
    required this.dataFim,
    required this.recompensa,
    required this.dificuldade,
    required this.categoria,
    required this.condicoes,
    this.ativa = true,
    this.dataCompletada,
  });

  bool get completada => valorAtual >= valorObjetivo;
  
  double get progresso => valorObjetivo > 0 ? (valorAtual / valorObjetivo).clamp(0.0, 1.0) : 0.0;
  
  int get progressoPorcentagem => (progresso * 100).round();

  bool get expirada => DateTime.now().isAfter(dataFim);

  Duration get tempoRestante => dataFim.difference(DateTime.now());

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tipo': tipo.toString(),
      'periodo': periodo.toString(),
      'titulo': titulo,
      'descricao': descricao,
      'valorObjetivo': valorObjetivo,
      'valorAtual': valorAtual,
      'dataInicio': Timestamp.fromDate(dataInicio),
      'dataFim': Timestamp.fromDate(dataFim),
      'recompensa': recompensa,
      'dificuldade': dificuldade.toString(),
      'categoria': categoria.toString(),
      'condicoes': condicoes,
      'ativa': ativa,
      'dataCompletada': dataCompletada != null ? Timestamp.fromDate(dataCompletada!) : null,
    };
  }

  factory MetaInteligente.fromMap(Map<String, dynamic> map) {
    return MetaInteligente(
      id: map['id'] ?? '',
      tipo: TipoMeta.values.firstWhere((e) => e.toString() == map['tipo']),
      periodo: PeriodoMeta.values.firstWhere((e) => e.toString() == map['periodo']),
      titulo: map['titulo'] ?? '',
      descricao: map['descricao'] ?? '',
      valorObjetivo: (map['valorObjetivo'] ?? 0).toDouble(),
      valorAtual: (map['valorAtual'] ?? 0).toDouble(),
      dataInicio: (map['dataInicio'] as Timestamp).toDate(),
      dataFim: (map['dataFim'] as Timestamp).toDate(),
      recompensa: (map['recompensa'] ?? 0).toDouble(),
      dificuldade: DificuldadeMeta.values.firstWhere((e) => e.toString() == map['dificuldade']),
      categoria: CategoriaMeta.values.firstWhere((e) => e.toString() == map['categoria']),
      condicoes: Map<String, dynamic>.from(map['condicoes'] ?? {}),
      ativa: map['ativa'] ?? true,
      dataCompletada: map['dataCompletada'] != null ? (map['dataCompletada'] as Timestamp).toDate() : null,
    );
  }

  MetaInteligente copyWith({
    String? id,
    TipoMeta? tipo,
    PeriodoMeta? periodo,
    String? titulo,
    String? descricao,
    double? valorObjetivo,
    double? valorAtual,
    DateTime? dataInicio,
    DateTime? dataFim,
    double? recompensa,
    DificuldadeMeta? dificuldade,
    CategoriaMeta? categoria,
    Map<String, dynamic>? condicoes,
    bool? ativa,
    DateTime? dataCompletada,
  }) {
    return MetaInteligente(
      id: id ?? this.id,
      tipo: tipo ?? this.tipo,
      periodo: periodo ?? this.periodo,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      valorObjetivo: valorObjetivo ?? this.valorObjetivo,
      valorAtual: valorAtual ?? this.valorAtual,
      dataInicio: dataInicio ?? this.dataInicio,
      dataFim: dataFim ?? this.dataFim,
      recompensa: recompensa ?? this.recompensa,
      dificuldade: dificuldade ?? this.dificuldade,
      categoria: categoria ?? this.categoria,
      condicoes: condicoes ?? this.condicoes,
      ativa: ativa ?? this.ativa,
      dataCompletada: dataCompletada ?? this.dataCompletada,
    );
  }
}
