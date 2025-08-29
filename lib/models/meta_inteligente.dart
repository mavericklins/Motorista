enum DifficultyLevel {
  easy,
  medium,
  hard,
}

enum TipoMeta {
  corridas,
  ganhos,
  eficiencia,
  avaliacao,
  tempo,
  distancia,
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
  medio,
  dificil,
  alto,
}

class MetaInteligente {
  final String id;
  final String titulo;
  final String descricao;
  final TipoMeta tipo;
  final CategoriaMeta categoria;
  final double valorObjetivo;
  double valorAtual;
  final double valorAlvo;
  final String recompensa;
  final DateTime dataInicio;
  final DateTime dataFim;
  final DateTime prazo;
  final bool isAtiva;
  bool completada;
  final DificuldadeMeta dificuldade;

  MetaInteligente({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.tipo,
    required this.categoria,
    required this.valorObjetivo,
    this.valorAtual = 0.0,
    required this.valorAlvo,
    required this.recompensa,
    required this.dataInicio,
    required this.dataFim,
    required this.prazo,
    required this.isAtiva,
    this.completada = false,
    this.dificuldade = DificuldadeMeta.medio,
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
      'valorAlvo': valorAlvo,
      'recompensa': recompensa,
      'dataInicio': dataInicio.toIso8601String(),
      'dataFim': dataFim.toIso8601String(),
      'prazo': prazo.toIso8601String(),
      'isAtiva': isAtiva,
      'completada': completada,
      'dificuldade': dificuldade.toString(),
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
      valorAlvo: json['valorAlvo']?.toDouble() ?? 0.0,
      recompensa: json['recompensa'],
      dataInicio: DateTime.parse(json['dataInicio']),
      dataFim: DateTime.parse(json['dataFim']),
      prazo: DateTime.parse(json['prazo']),
      isAtiva: json['isAtiva'] ?? true,
      completada: json['completada'] ?? false,
      dificuldade: DificuldadeMeta.values.firstWhere((e) => e.toString() == json['dificuldade']),
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
    double? valorAlvo,
    String? recompensa,
    DateTime? dataInicio,
    DateTime? dataFim,
    DateTime? prazo,
    bool? isAtiva,
    bool? completada,
    DificuldadeMeta? dificuldade,
  }) {
    return MetaInteligente(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      tipo: tipo ?? this.tipo,
      categoria: categoria ?? this.categoria,
      valorObjetivo: valorObjetivo ?? this.valorObjetivo,
      valorAtual: valorAtual ?? this.valorAtual,
      valorAlvo: valorAlvo ?? this.valorAlvo,
      recompensa: recompensa ?? this.recompensa,
      dataInicio: dataInicio ?? this.dataInicio,
      dataFim: dataFim ?? this.dataFim,
      prazo: prazo ?? this.prazo,
      isAtiva: isAtiva ?? this.isAtiva,
      completada: completada ?? this.completada,
      dificuldade: dificuldade ?? this.dificuldade,
    );
  }
}