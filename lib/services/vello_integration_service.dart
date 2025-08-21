import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './financial_service_professional.dart';
import './security_service.dart';
import './analytics_service.dart';
import './support_points_service.dart';
import './notification_service_advanced.dart';

/// Serviço integrador que conecta funcionalidades novas com o sistema Vello existente
/// SEM QUEBRAR NADA que já funciona
class VelloIntegrationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  
  static bool _initialized = false;

  /// Inicializar todas as funcionalidades adicionais
  static Future<void> inicializar() async {
    if (_initialized) return;
    
    try {
      print('🚀 Inicializando funcionalidades adicionais Vello...');

      // Inicializar serviços complementares (não substitui os existentes)
      await AnalyticsService.inicializar();
      await NotificationServiceAdvanced.inicializar();
      
      // Registrar início de sessão
      await AnalyticsService.registrarInicioTurno();
      
      _initialized = true;
      print('✅ Funcionalidades adicionais inicializadas');
    } catch (e) {
      print('❌ Erro ao inicializar funcionalidades adicionais: $e');
    }
  }

  /// Integrar com sistema de corridas existente - APENAS ADICIONA funcionalidades
  static Future<void> integrarComCorridaExistente(String corridaId) async {
    try {
      // Registrar evento de corrida no analytics (complementar)
      await AnalyticsService.registrarEvento(
        nomeEvento: 'ride_integration_started',
        parametros: {'ride_id': corridaId},
      );

      // Verificar segurança (adicional, não bloqueia o fluxo existente)
      final gpsSeguro = await SecurityService.verificarGPSFalso();
      if (!gpsSeguro) {
        print('⚠️ GPS suspeito detectado - registrando para análise');
        await SecurityService.monitorarComportamento(
          acao: 'gps_suspeito_corrida',
          dados: {'corridaId': corridaId},
        );
      }

      print('✅ Integração com corrida $corridaId realizada');
    } catch (e) {
      print('❌ Erro na integração: $e');
      // Não quebra o fluxo existente
    }
  }

  /// Processar pagamento recebido - COMPLEMENTA o sistema existente
  static Future<void> processarPagamentoRecebido({
    required String corridaId,
    required double valor,
    required String metodo,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Atualizar ganhos do motorista (funcionalidade NOVA)
      await FinancialServiceProfessional.atualizarGanhosCorrida(
        motoristaId: user.uid,
        valorGanho: valor * 0.85, // 85% para motorista
        corridaId: corridaId,
      );

      // Registrar no analytics (NOVO)
      await AnalyticsService.registrarPagamentoRecebido(valor, metodo);

      print('✅ Pagamento processado: R\$ ${valor.toStringAsFixed(2)}');
    } catch (e) {
      print('❌ Erro ao processar pagamento: $e');
      // Não quebra o fluxo de pagamento existente
    }
  }

  /// Obter estatísticas financeiras - FUNCIONALIDADE NOVA
  static Future<Map<String, dynamic>> obterEstatisticasFinanceiras() async {
    try {
      return await FinancialServiceProfessional.obterEstatisticasFinanceiras();
    } catch (e) {
      print('❌ Erro ao obter estatísticas: $e');
      return {};
    }
  }

  /// Obter pontos de apoio próximos - FUNCIONALIDADE NOVA
  static Future<List<dynamic>> obterPontosApoioProximos() async {
    try {
      return await SupportPointsService.obterPontosApoio();
    } catch (e) {
      print('❌ Erro ao obter pontos de apoio: $e');
      return [];
    }
  }

  /// Registrar evento de corrida - COMPLEMENTA analytics existente
  static Future<void> registrarEventoCorrida({
    required String evento,
    required String corridaId,
    Map<String, dynamic>? dados,
  }) async {
    try {
      await AnalyticsService.registrarEventoCorrida(
        evento: evento,
        corridaId: corridaId,
        parametrosAdicionais: dados,
      );
    } catch (e) {
      print('❌ Erro ao registrar evento: $e');
      // Não quebra funcionalidade principal
    }
  }

  /// Verificar segurança antes de aceitar corrida - FUNCIONALIDADE ADICIONAL
  static Future<bool> verificarSegurancaAntesAceitarCorrida() async {
    try {
      // Verificações de segurança adicionais
      final gpsSeguro = await SecurityService.verificarGPSFalso();
      final integridade = await SecurityService.verificarIntegridadeApp();
      
      if (!gpsSeguro || !integridade) {
        await SecurityService.monitorarComportamento(
          acao: 'tentativa_aceitar_corrida_insegura',
          dados: {
            'gps_seguro': gpsSeguro,
            'integridade_ok': integridade,
          },
        );
        return false;
      }
      
      return true;
    } catch (e) {
      print('❌ Erro na verificação de segurança: $e');
      return true; // Em caso de erro, não bloqueia o fluxo
    }
  }

  /// Enviar notificação complementar - NÃO SUBSTITUI sistema existente
  static Future<void> enviarNotificacaoComplementar({
    required String titulo,
    required String mensagem,
    required String tipo,
  }) async {
    try {
      await NotificationServiceAdvanced.mostrarNotificacaoLocal(
        titulo: titulo,
        mensagem: mensagem,
        tipo: tipo,
      );
    } catch (e) {
      print('❌ Erro ao enviar notificação complementar: $e');
      // Não quebra sistema de notificação existente
    }
  }

  /// Monitorar performance de operação - FUNCIONALIDADE NOVA
  static Future<T> monitorarPerformance<T>(
    String operacao,
    Future<T> Function() funcao,
  ) async {
    try {
      return await AnalyticsService.monitorarPerformance(operacao, funcao);
    } catch (e) {
      print('❌ Erro no monitoramento: $e');
      // Executa função mesmo se monitoramento falhar
      return await funcao();
    }
  }

  /// Obter relatório de analytics - FUNCIONALIDADE NOVA
  static Future<Map<String, dynamic>> obterRelatorioAnalytics({
    DateTime? dataInicio,
    DateTime? dataFim,
  }) async {
    try {
      return await AnalyticsService.obterRelatorioAnalytics(
        dataInicio: dataInicio,
        dataFim: dataFim,
      );
    } catch (e) {
      print('❌ Erro ao obter relatório: $e');
      return {};
    }
  }

  /// Validar documento - FUNCIONALIDADE NOVA
  static Future<Map<String, dynamic>> validarDocumento({
    required String tipo,
    required String caminhoImagem,
  }) async {
    try {
      return await SecurityService.validarDocumento(
        tipoDocumento: tipo,
        caminhoImagem: caminhoImagem,
      );
    } catch (e) {
      print('❌ Erro na validação de documento: $e');
      return {'documento_valido': false, 'erro': e.toString()};
    }
  }

  /// Finalizar turno - FUNCIONALIDADE NOVA
  static Future<void> finalizarTurno() async {
    try {
      await AnalyticsService.registrarFimTurno();
      await AnalyticsService.finalizarSessao();
      print('✅ Turno finalizado');
    } catch (e) {
      print('❌ Erro ao finalizar turno: $e');
    }
  }

  /// Hooks para integração com sistema existente
  
  /// Hook: Corrida aceita (chama após aceitar no sistema existente)
  static Future<void> onCorridaAceita(String corridaId, double valor) async {
    await integrarComCorridaExistente(corridaId);
    await AnalyticsService.registrarCorridaAceita(corridaId, valor);
    await enviarNotificacaoComplementar(
      titulo: 'Corrida Aceita',
      mensagem: 'Corrida de R\$ ${valor.toStringAsFixed(2)} aceita com sucesso',
      tipo: 'corrida_aceita',
    );
  }

  /// Hook: Corrida concluída (chama após concluir no sistema existente)
  static Future<void> onCorridaConcluida(String corridaId, double valor, int duracao) async {
    await processarPagamentoRecebido(
      corridaId: corridaId,
      valor: valor,
      metodo: 'app',
    );
    await AnalyticsService.registrarCorridaConcluida(corridaId, valor, duracao);
    await enviarNotificacaoComplementar(
      titulo: 'Corrida Concluída',
      mensagem: 'Parabéns! Você ganhou R\$ ${(valor * 0.85).toStringAsFixed(2)}',
      tipo: 'corrida_concluida',
    );
  }

  /// Hook: Corrida cancelada (chama após cancelar no sistema existente)
  static Future<void> onCorridaCancelada(String corridaId, String motivo) async {
    await AnalyticsService.registrarCorridaCancelada(corridaId, motivo);
  }

  /// Verificar se funcionalidades estão disponíveis
  static bool get funcionalidadesDisponveis => _initialized;

  /// Status dos serviços
  static Map<String, bool> get statusServicos => {
    'analytics': _initialized,
    'security': _initialized,
    'financial': _initialized,
    'support_points': _initialized,
    'notifications': _initialized,
  };
}

