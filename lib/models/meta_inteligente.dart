enum TipoMeta {
  ganhos,
  corridas,
  eficiencia,
  consistencia,
  crescimento,
  estrategico,
}

enum CategoriaMeta {
  produtividade,
  crescimento,
  habito,
  estrategia,
  social,
}

enum DificuldadeMeta {
  facil,
  media,
  dificil,
}

class MetaInteligente {
  final String id;
  final String titulo;
  final String descricao;
  final TipoMeta tipo;
  final CategoriaMeta categoria;
  final double valorObjetivo;
  double valorAtual;
  final DateTime dataInicio;
  final DateTime dataFim;
  final DificuldadeMeta dificuldade;
  final double recompensa;
  bool ativa;
  bool completada;

  MetaInteligente({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.tipo,
    required this.categoria,
    required this.valorObjetivo,
    this.valorAtual = 0.0,
    required this.dataInicio,
    required this.dataFim,
    this.dificuldade = DificuldadeMeta.media,
    this.recompensa = 0.0,
    this.ativa = true,
    this.completada = false,
  });

  double get progresso {
    if (valorObjetivo == 0) return 0.0;
    return (valorAtual / valorObjetivo).clamp(0.0, 1.0);
  }

  int get progressoPorcentagem {
    return (progresso * 100).round();
  }

  bool get expirada {
    return DateTime.now().isAfter(dataFim) && !completada;
  }

  Duration get tempoRestante {
    final agora = DateTime.now();
    if (agora.isAfter(dataFim)) {
      return Duration.zero;
    }
    return dataFim.difference(agora);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'tipo': tipo.toString(),
      'categoria': categoria.toString(),
      'valorObjetivo': valorObjetivo,
      'valorAtual': valorAtual,
      'dataInicio': dataInicio.toIso8601String(),
      'dataFim': dataFim.toIso8601String(),
      'dificuldade': dificuldade.toString(),
      'recompensa': recompensa,
      'ativa': ativa,
      'completada': completada,
    };
  }

  factory MetaInteligente.fromJson(Map<String, dynamic> json) {
    return MetaInteligente(
      id: json['id'],
      titulo: json['titulo'],
      descricao: json['descricao'],
      tipo: TipoMeta.values.firstWhere((e) => e.toString() == json['tipo']),
      categoria: CategoriaMeta.values.firstWhere((e) => e.toString() == json['categoria']),
      valorObjetivo: json['valorObjetivo'].toDouble(),
      valorAtual: json['valorAtual']?.toDouble() ?? 0.0,
      dataInicio: DateTime.parse(json['dataInicio']),
      dataFim: DateTime.parse(json['dataFim']),
      dificuldade: DificuldadeMeta.values.firstWhere((e) => e.toString() == json['dificuldade']),
      recompensa: json['recompensa']?.toDouble() ?? 0.0,
      ativa: json['ativa'] ?? true,
      completada: json['completada'] ?? false,
    );
  }

  MetaInteligente copyWith({
    String? id,
    String? titulo,
    String? descricao,
    TipoMeta? tipo,
    CategoriaMeta? categoria,
    double? valorObjetivo,
    double? valorAtual,
    DateTime? dataInicio,
    DateTime? dataFim,
    DificuldadeMeta? dificuldade,
    double? recompensa,
    bool? ativa,
    bool? completada,
  }) {
    return MetaInteligente(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      tipo: tipo ?? this.tipo,
      categoria: categoria ?? this.categoria,
      valorObjetivo: valorObjetivo ?? this.valorObjetivo,
      valorAtual: valorAtual ?? this.valorAtual,
      dataInicio: dataInicio ?? this.dataInicio,
      dataFim: dataFim ?? this.dataFim,
      dificuldade: dificuldade ?? this.dificuldade,
      recompensa: recompensa ?? this.recompensa,
      ativa: ativa ?? this.ativa,
      completada: completada ?? this.completada,
    );
  }
}