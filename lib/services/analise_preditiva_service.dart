
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import '../models/ride.dart';

class AnalisePreditivaService {
  static final AnalisePreditivaService _instance = AnalisePreditivaService._internal();
  factory AnalisePreditivaService() => _instance;
  AnalisePreditivaService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Análise de horários mais lucrativos
  Future<Map<String, dynamic>> analisarHorariosMaisLucrativos(String motoristaId) async {
    try {
      final now = DateTime.now();
      final inicioSemana = now.subtract(Duration(days: 7));

      final querySnapshot = await _firestore
          .collection('corridas')
          .where('motoristaId', isEqualTo: motoristaId)
          .where('status', isEqualTo: 'concluida')
          .where('concluidaEm', isGreaterThan: Timestamp.fromDate(inicioSemana))
          .get();

      Map<int, double> ganhosPorHora = {};
      Map<int, int> corridasPorHora = {};

      for (var doc in querySnapshot.docs) {
        final corrida = Ride.fromFirestore(doc);
        if (corrida.concluidaEm != null) {
          final hora = corrida.concluidaEm!.hour;
          ganhosPorHora[hora] = (ganhosPorHora[hora] ?? 0) + corrida.valor;
          corridasPorHora[hora] = (corridasPorHora[hora] ?? 0) + 1;
        }
      }

      // Encontra os 3 horários mais lucrativos
      var horariosOrdenados = ganhosPorHora.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final top3Horarios = horariosOrdenados.take(3).map((entry) => {
        'hora': entry.key,
        'ganho': entry.value,
        'corridas': corridasPorHora[entry.key] ?? 0,
        'mediaGanho': corridasPorHora[entry.key] != null && corridasPorHora[entry.key]! > 0
            ? entry.value / corridasPorHora[entry.key]!
            : 0.0,
      }).toList();

      return {
        'horariosMaisLucrativos': top3Horarios,
        'totalGanhos': ganhosPorHora.values.fold(0.0, (a, b) => a + b),
        'totalCorridas': corridasPorHora.values.fold(0, (a, b) => a + b),
      };
    } catch (e) {
      print('Erro na análise de horários: $e');
      return {};
    }
  }

  // Previsão de demanda por região
  Future<List<Map<String, dynamic>>> preverDemandaPorRegiao(Position posicaoAtual) async {
    try {
      final now = DateTime.now();
      final horaAtual = now.hour;
      final diaSemana = now.weekday;

      // Busca corridas históricas em um raio de 5km
      final querySnapshot = await _firestore
          .collection('corridas')
          .where('status', isEqualTo: 'concluida')
          .limit(500)
          .get();

      List<Map<String, dynamic>> regioes = [];
      Map<String, Map<String, dynamic>> dadosRegiao = {};

      for (var doc in querySnapshot.docs) {
        final corrida = Ride.fromFirestore(doc);
        if (corrida.concluidaEm != null) {
          final distancia = Geolocator.distanceBetween(
            posicaoAtual.latitude,
            posicaoAtual.longitude,
            corrida.origemLat,
            corrida.origemLon,
          ) / 1000; // em km

          if (distancia <= 5.0) {
            final horaCorride = corrida.concluidaEm!.hour;
            final diaCorride = corrida.concluidaEm!.weekday;

            // Agrupa por área aproximada (0.01 grau = ~1km)
            final chaveRegiao = '${(corrida.origemLat * 100).round() / 100}_${(corrida.origemLon * 100).round() / 100}';

            if (!dadosRegiao.containsKey(chaveRegiao)) {
              dadosRegiao[chaveRegiao] = {
                'lat': corrida.origemLat,
                'lon': corrida.origemLon,
                'corridasPorHora': <int, int>{},
                'corridasPorDia': <int, int>{},
                'ganhoTotal': 0.0,
                'distanciaMotorista': distancia,
              };
            }

            final dados = dadosRegiao[chaveRegiao]!;
            dados['corridasPorHora'][horaCorride] = (dados['corridasPorHora'][horaCorride] ?? 0) + 1;
            dados['corridasPorDia'][diaCorride] = (dados['corridasPorDia'][diaCorride] ?? 0) + 1;
            dados['ganhoTotal'] = dados['ganhoTotal'] + corrida.valor;
          }
        }
      }

      // Calcula score de demanda para cada região
      dadosRegiao.forEach((chave, dados) {
        final corridasHoraAtual = dados['corridasPorHora'][horaAtual] ?? 0;
        final corridasDiaAtual = dados['corridasPorDia'][diaSemana] ?? 0;
        final ganhoMedio = dados['ganhoTotal'] / (dados['corridasPorHora'].values.fold(0, (a, b) => a + b) + 1);

        final scoreDemanda = (corridasHoraAtual * 0.5 + corridasDiaAtual * 0.3 + ganhoMedio * 0.2) / dados['distanciaMotorista'];

        regioes.add({
          'lat': dados['lat'],
          'lon': dados['lon'],
          'scoreDemanda': scoreDemanda,
          'corridasPrevisitas': corridasHoraAtual,
          'ganhoMedioEstimado': ganhoMedio,
          'distancia': dados['distanciaMotorista'],
        });
      });

      // Ordena por score de demanda
      regioes.sort((a, b) => b['scoreDemanda'].compareTo(a['scoreDemanda']));

      return regioes.take(5).toList(); // Top 5 regiões
    } catch (e) {
      print('Erro na previsão de demanda: $e');
      return [];
    }
  }

  // Sugestões de reposicionamento
  Future<Map<String, dynamic>> sugerirReposicionamento(Position posicaoAtual) async {
    try {
      final regioesDemanda = await preverDemandaPorRegiao(posicaoAtual);

      if (regioesDemanda.isEmpty) {
        return {
          'temSugestao': false,
          'mensagem': 'Dados insuficientes para sugestão',
        };
      }

      final melhorRegiao = regioesDemanda.first;
      final distancia = melhorRegiao['distancia'];

      if (distancia > 0.5) { // Só sugere se estiver a mais de 500m
        return {
          'temSugestao': true,
          'lat': melhorRegiao['lat'],
          'lon': melhorRegiao['lon'],
          'distancia': distancia,
          'ganhoEstimado': melhorRegiao['ganhoMedioEstimado'],
          'corridasPrevisitas': melhorRegiao['corridasPrevisitas'],
          'mensagem': 'Região com alta demanda detectada a ${distancia.toStringAsFixed(1)}km de você',
        };
      }

      return {
        'temSugestao': false,
        'mensagem': 'Você já está em uma boa região',
      };
    } catch (e) {
      print('Erro na sugestão de reposicionamento: $e');
      return {'temSugestao': false, 'mensagem': 'Erro ao calcular sugestão'};
    }
  }

  // Previsão de picos de demanda
  Future<List<Map<String, dynamic>>> preverPicosDemanda() async {
    try {
      final now = DateTime.now();
      final proximasHoras = List.generate(6, (index) => now.add(Duration(hours: index + 1)));

      List<Map<String, dynamic>> previsoes = [];

      for (final hora in proximasHoras) {
        double scorePrevisao = 0;
        String motivo = '';

        // Análise baseada em padrões históricos
        if (hora.weekday >= 1 && hora.weekday <= 5) { // Segunda a sexta
          if (hora.hour >= 7 && hora.hour <= 9) {
            scorePrevisao = 0.8;
            motivo = 'Horário de pico matinal';
          } else if (hora.hour >= 17 && hora.hour <= 19) {
            scorePrevisao = 0.9;
            motivo = 'Horário de pico vespertino';
          } else if (hora.hour >= 12 && hora.hour <= 14) {
            scorePrevisao = 0.6;
            motivo = 'Horário de almoço';
          }
        } else { // Final de semana
          if (hora.hour >= 10 && hora.hour <= 14) {
            scorePrevisao = 0.7;
            motivo = 'Movimento de fim de semana';
          } else if (hora.hour >= 20 && hora.hour <= 23) {
            scorePrevisao = 0.8;
            motivo = 'Vida noturna de fim de semana';
          }
        }

        previsoes.add({
          'hora': hora,
          'scorePrevisao': scorePrevisao,
          'motivo': motivo,
          'recomendacao': scorePrevisao > 0.7 ? 'Fique online' : scorePrevisao > 0.5 ? 'Boa oportunidade' : 'Baixa demanda',
        });
      }

      return previsoes;
    } catch (e) {
      print('Erro na previsão de picos: $e');
      return [];
    }
  }

  // Análise de performance pessoal
  Future<Map<String, dynamic>> analisarPerformancePessoal(String motoristaId) async {
    try {
      final now = DateTime.now();
      final inicioMes = DateTime(now.year, now.month, 1);
      final mesAnterior = DateTime(now.year, now.month - 1, 1);

      final corridasAtualQuery = await _firestore
          .collection('corridas')
          .where('motoristaId', isEqualTo: motoristaId)
          .where('status', isEqualTo: 'concluida')
          .where('concluidaEm', isGreaterThan: Timestamp.fromDate(inicioMes))
          .get();

      final corridasAnteriorQuery = await _firestore
          .collection('corridas')
          .where('motoristaId', isEqualTo: motoristaId)
          .where('status', isEqualTo: 'concluida')
          .where('concluidaEm', isGreaterThan: Timestamp.fromDate(mesAnterior))
          .where('concluidaEm', isLessThan: Timestamp.fromDate(inicioMes))
          .get();

      final corridasAtual = corridasAtualQuery.docs.map((doc) => Ride.fromFirestore(doc)).toList();
      final corridasAnterior = corridasAnteriorQuery.docs.map((doc) => Ride.fromFirestore(doc)).toList();

      final ganhoAtual = corridasAtual.fold(0.0, (sum, c) => sum + c.valor);
      final ganhoAnterior = corridasAnterior.fold(0.0, (sum, c) => sum + c.valor);

      final crescimentoGanhos = ganhoAnterior > 0 ? ((ganhoAtual - ganhoAnterior) / ganhoAnterior) * 100 : 0.0;
      final crescimentoCorridas = corridasAnterior.length > 0
          ? ((corridasAtual.length - corridasAnterior.length) / corridasAnterior.length) * 100
          : 0.0;

      return {
        'ganhoAtual': ganhoAtual,
        'ganhoAnterior': ganhoAnterior,
        'crescimentoGanhos': crescimentoGanhos,
        'corridasAtual': corridasAtual.length,
        'corridasAnterior': corridasAnterior.length,
        'crescimentoCorridas': crescimentoCorridas,
        'ganhoMedioPorCorrida': corridasAtual.isNotEmpty ? ganhoAtual / corridasAtual.length : 0.0,
        'tendencia': crescimentoGanhos > 0 ? 'Crescimento' : crescimentoGanhos < 0 ? 'Declínio' : 'Estável',
      };
    } catch (e) {
      print('Erro na análise de performance: $e');
      return {};
    }
  }
}
