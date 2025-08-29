import 'package:flutter/foundation.dart';
import '../models/meta_inteligente.dart';

class MetasInteligentesService extends ChangeNotifier {
  List<MetaInteligente> _metas = [];
  Map<String, dynamic> _performance = {};
  Map<String, dynamic> _previsoes = {};

  List<MetaInteligente> get metas => _metas;
  Map<String, dynamic> get performance => _performance;
  Map<String, dynamic> get previsoes => _previsoes;

  Future<void> gerarMetasPersonalizadas() async {
    // Simular geração de metas baseadas em IA
    await Future.delayed(Duration(seconds: 2));

    _metas = [
      MetaInteligente(
        id: '1',
        titulo: 'Ganhos Semanais',
        descricao: 'Meta adaptativa baseada no seu histórico',
        tipo: TipoMeta.ganhos,
        categoria: CategoriaMeta.crescimento,
        valorObjetivo: 800.0,
        valorAtual: 480.0,
        dataInicio: DateTime.now().subtract(Duration(days: 2)),
        dataFim: DateTime.now().add(Duration(days: 5)),
        dificuldade: DificuldadeMeta.media,
        recompensa: 50.0,
        ativa: true,
      ),
      MetaInteligente(
        id: '2',
        titulo: 'Corridas Diárias',
        descricao: 'Mantenha consistência nas corridas',
        tipo: TipoMeta.corridas,
        categoria: CategoriaMeta.produtividade,
        valorObjetivo: 12.0,
        valorAtual: 9.0,
        dataInicio: DateTime.now(),
        dataFim: DateTime.now().add(Duration(days: 1)),
        dificuldade: DificuldadeMeta.facil,
        recompensa: 25.0,
        ativa: true,
      ),
    ];

    notifyListeners();
  }

  Future<void> gerarInsightsPersonalizados() async {
    _performance = {
      'ganho_medio': 42.50,
      'corridas_media': 8.5,
      'eficiencia': 78.5,
    };

    _previsoes = {
      'ganho_semanal': 595.0,
      'melhor_dia': 'Sexta-feira',
      'crescimento': 15.2,
    };

    notifyListeners();
  }

  Future<void> atualizarProgressoMetas() async {
    // Simular atualização do progresso das metas
    for (var meta in _metas) {
      if (meta.ativa && !meta.completada) {
        // Simular progresso aleatório
        meta.valorAtual += (meta.valorObjetivo - meta.valorAtual) * 0.1;
      }
    }
    notifyListeners();
  }

  Future<void> criarMeta(MetaInteligente meta) async {
    _metas.add(meta);
    notifyListeners();
  }

  Future<void> completarMeta(String metaId) async {
    final meta = _metas.firstWhere((m) => m.id == metaId);
    meta.completada = true;
    meta.ativa = false;
    notifyListeners();
  }
}