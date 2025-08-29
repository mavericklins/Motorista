import 'package:vello_motorista/models/financial_model.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

/// Serviço de relatórios financeiros para Vello Motorista
class FinancialService {
  
  // Método único para adicionar crédito - compatível com ambas as assinaturas
  Future<void> adicionarCredito(num valor, String descricao) async {
    // Implementar adição de crédito
    print('Adicionando crédito: R\$ $valor - $descricao');
    
    // TODO: Implementar lógica real de adição de crédito
    // TODO: Integrar com sistema de pagamentos
    // TODO: Atualizar saldo do motorista
  }

  static Future<FinancialModel?> obterDadosFinanceiros() async {
    // TODO: mapear para FinancialModel real
    return null;
  }

  static Future<List<TransactionModel>> obterHistoricoTransacoes() async {
    // TODO: mapear para TransactionModel real
    return <TransactionModel>[];
  }

  static final FinancialService _instance = FinancialService._internal();
  factory FinancialService() => _instance;
  FinancialService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  /// Obtém resumo financeiro do dia
  Future<DailyFinancialSummary> getDailySummary(String driverId, {DateTime? date}) async {
    try {
      final targetDate = date ?? DateTime.now();
      final startOfDay = DateTime(targetDate.year, targetDate.month, targetDate.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      // Busca corridas do dia
      final ridesSnapshot = await _firestore
          .collection('corridas')
          .where('motoristaId', isEqualTo: driverId)
          .where('status', isEqualTo: 'concluida')
          .where('concluidaEm', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('concluidaEm', isLessThan: Timestamp.fromDate(endOfDay))
          .get();

      // Busca transações do dia
      final transactionsSnapshot = await _firestore
          .collection('transactions')
          .where('driverId', isEqualTo: driverId)
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('createdAt', isLessThan: Timestamp.fromDate(endOfDay))
          .get();

      return _calculateDailySummary(ridesSnapshot.docs, transactionsSnapshot.docs, targetDate);
    } catch (e) {
      print('Erro ao obter resumo diário: $e');
      return DailyFinancialSummary.empty(date ?? DateTime.now());
    }
  }

  /// Obtém resumo financeiro da semana
  Future<WeeklyFinancialSummary> getWeeklySummary(String driverId, {DateTime? date}) async {
    try {
      final targetDate = date ?? DateTime.now();
      final startOfWeek = _getStartOfWeek(targetDate);
      final endOfWeek = startOfWeek.add(const Duration(days: 7));

      // Busca dados da semana
      final ridesSnapshot = await _firestore
          .collection('corridas')
          .where('motoristaId', isEqualTo: driverId)
          .where('status', isEqualTo: 'concluida')
          .where('concluidaEm', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfWeek))
          .where('concluidaEm', isLessThan: Timestamp.fromDate(endOfWeek))
          .get();

      final transactionsSnapshot = await _firestore
          .collection('transactions')
          .where('driverId', isEqualTo: driverId)
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfWeek))
          .where('createdAt', isLessThan: Timestamp.fromDate(endOfWeek))
          .get();

      return _calculateWeeklySummary(ridesSnapshot.docs, transactionsSnapshot.docs, startOfWeek);
    } catch (e) {
      print('Erro ao obter resumo semanal: $e');
      return WeeklyFinancialSummary.empty(date ?? DateTime.now());
    }
  }

  /// Obtém resumo financeiro do mês
  Future<MonthlyFinancialSummary> getMonthlySummary(String driverId, {DateTime? date}) async {
    try {
      final targetDate = date ?? DateTime.now();
      final startOfMonth = DateTime(targetDate.year, targetDate.month, 1);
      final endOfMonth = DateTime(targetDate.year, targetDate.month + 1, 1);

      // Busca dados do mês
      final ridesSnapshot = await _firestore
          .collection('corridas')
          .where('motoristaId', isEqualTo: driverId)
          .where('status', isEqualTo: 'concluida')
          .where('concluidaEm', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .where('concluidaEm', isLessThan: Timestamp.fromDate(endOfMonth))
          .get();

      final transactionsSnapshot = await _firestore
          .collection('transactions')
          .where('driverId', isEqualTo: driverId)
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .where('createdAt', isLessThan: Timestamp.fromDate(endOfMonth))
          .get();

      return _calculateMonthlySummary(ridesSnapshot.docs, transactionsSnapshot.docs, startOfMonth);
    } catch (e) {
      print('Erro ao obter resumo mensal: $e');
      return MonthlyFinancialSummary.empty(date ?? DateTime.now());
    }
  }

  /// Obtém histórico de ganhos por período
  Future<List<EarningsHistory>> getEarningsHistory({
    required String driverId,
    required DateTime startDate,
    required DateTime endDate,
    EarningsGroupBy groupBy = EarningsGroupBy.day,
  }) async {
    try {
      final ridesSnapshot = await _firestore
          .collection('corridas')
          .where('motoristaId', isEqualTo: driverId)
          .where('status', isEqualTo: 'concluida')
          .where('concluidaEm', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('concluidaEm', isLessThan: Timestamp.fromDate(endDate))
          .orderBy('concluidaEm')
          .get();

      return _groupEarningsByPeriod(ridesSnapshot.docs, groupBy);
    } catch (e) {
      print('Erro ao obter histórico de ganhos: $e');
      return [];
    }
  }

  /// Obtém estatísticas de performance
  Future<PerformanceStats> getPerformanceStats(String driverId, {DateTime? date}) async {
    try {
      final targetDate = date ?? DateTime.now();
      final startOfMonth = DateTime(targetDate.year, targetDate.month, 1);
      final endOfMonth = DateTime(targetDate.year, targetDate.month + 1, 1);

      // Busca todas as corridas do mês (incluindo canceladas)
      final allRidesSnapshot = await _firestore
          .collection('corridas')
          .where('motoristaId', isEqualTo: driverId)
          .where('aceitaEm', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .where('aceitaEm', isLessThan: Timestamp.fromDate(endOfMonth))
          .get();

      // Busca avaliações do motorista
      final ratingsSnapshot = await _firestore
          .collection('avaliacoes')
          .where('motoristaId', isEqualTo: driverId)
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .where('createdAt', isLessThan: Timestamp.fromDate(endOfMonth))
          .get();

      return _calculatePerformanceStats(allRidesSnapshot.docs, ratingsSnapshot.docs);
    } catch (e) {
      print('Erro ao obter estatísticas de performance: $e');
      return PerformanceStats.empty();
    }
  }

  /// Obtém relatório de impostos
  Future<TaxReport> getTaxReport(String driverId, int year) async {
    try {
      final startOfYear = DateTime(year, 1, 1);
      final endOfYear = DateTime(year + 1, 1, 1);

      // Busca todas as transações do ano
      final transactionsSnapshot = await _firestore
          .collection('transactions')
          .where('driverId', isEqualTo: driverId)
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfYear))
          .where('createdAt', isLessThan: Timestamp.fromDate(endOfYear))
          .get();

      // Busca despesas do ano (se houver coleção de despesas)
      final expensesSnapshot = await _firestore
          .collection('despesas')
          .where('motoristaId', isEqualTo: driverId)
          .where('data', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfYear))
          .where('data', isLessThan: Timestamp.fromDate(endOfYear))
          .get();

      return _calculateTaxReport(transactionsSnapshot.docs, expensesSnapshot.docs, year);
    } catch (e) {
      print('Erro ao obter relatório de impostos: $e');
      return TaxReport.empty(year);
    }
  }

  /// Calcula resumo diário
  DailyFinancialSummary _calculateDailySummary(
    List<QueryDocumentSnapshot> rides,
    List<QueryDocumentSnapshot> transactions,
    DateTime date,
  ) {
    double totalEarnings = 0;
    double totalFees = 0;
    double netEarnings = 0;
    int totalRides = rides.length;
    double totalDistance = 0;
    Duration totalTime = Duration.zero;

    for (final ride in rides) {
      final data = ride.data() as Map<String, dynamic>;
      final fare = (data['valor'] ?? 0).toDouble();
      final distance = (data['distancia'] ?? 0).toDouble();
      
      totalEarnings += fare;
      totalDistance += distance;
      
      // Calcula tempo da corrida
      final startTime = (data['iniciadaEm'] as Timestamp?)?.toDate();
      final endTime = (data['concluidaEm'] as Timestamp?)?.toDate();
      if (startTime != null && endTime != null) {
        totalTime += endTime.difference(startTime);
      }
    }

    for (final transaction in transactions) {
      final data = transaction.data() as Map<String, dynamic>;
      final amount = (data['amount'] ?? 0).toDouble();
      final fee = amount * 0.15; // 15% de taxa da plataforma
      totalFees += fee;
    }

    netEarnings = totalEarnings - totalFees;

    return DailyFinancialSummary(
      date: date,
      totalEarnings: totalEarnings,
      totalFees: totalFees,
      netEarnings: netEarnings,
      totalRides: totalRides,
      totalDistance: totalDistance,
      totalTime: totalTime,
      averageRideValue: totalRides > 0 ? totalEarnings / totalRides : 0,
      averageRideDistance: totalRides > 0 ? totalDistance / totalRides : 0,
    );
  }

  /// Calcula resumo semanal
  WeeklyFinancialSummary _calculateWeeklySummary(
    List<QueryDocumentSnapshot> rides,
    List<QueryDocumentSnapshot> transactions,
    DateTime startOfWeek,
  ) {
    final dailySummaries = <DailyFinancialSummary>[];
    
    // Agrupa por dia da semana
    for (int i = 0; i < 7; i++) {
      final day = startOfWeek.add(Duration(days: i));
      final dayRides = rides.where((ride) {
        final rideDate = (ride.data() as Map<String, dynamic>)['concluidaEm'] as Timestamp?;
        if (rideDate == null) return false;
        final date = rideDate.toDate();
        return date.year == day.year && date.month == day.month && date.day == day.day;
      }).toList();
      
      final dayTransactions = transactions.where((transaction) {
        final transactionDate = (transaction.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
        if (transactionDate == null) return false;
        final date = transactionDate.toDate();
        return date.year == day.year && date.month == day.month && date.day == day.day;
      }).toList();
      
      dailySummaries.add(_calculateDailySummary(dayRides, dayTransactions, day));
    }

    final totalEarnings = dailySummaries.fold(0.0, (sum, day) => sum + day.totalEarnings);
    final totalFees = dailySummaries.fold(0.0, (sum, day) => sum + day.totalFees);
    final totalRides = dailySummaries.fold(0, (sum, day) => sum + day.totalRides);
    final totalDistance = dailySummaries.fold(0.0, (sum, day) => sum + day.totalDistance);

    return WeeklyFinancialSummary(
      startDate: startOfWeek,
      endDate: startOfWeek.add(const Duration(days: 6)),
      totalEarnings: totalEarnings,
      totalFees: totalFees,
      netEarnings: totalEarnings - totalFees,
      totalRides: totalRides,
      totalDistance: totalDistance,
      dailySummaries: dailySummaries,
      bestDay: dailySummaries.reduce((a, b) => a.totalEarnings > b.totalEarnings ? a : b),
      averageDailyEarnings: totalEarnings / 7,
    );
  }

  /// Calcula resumo mensal
  MonthlyFinancialSummary _calculateMonthlySummary(
    List<QueryDocumentSnapshot> rides,
    List<QueryDocumentSnapshot> transactions,
    DateTime startOfMonth,
  ) {
    final weeklySummaries = <WeeklyFinancialSummary>[];
    final daysInMonth = DateTime(startOfMonth.year, startOfMonth.month + 1, 0).day;
    
    // Agrupa por semana
    DateTime currentWeekStart = _getStartOfWeek(startOfMonth);
    while (currentWeekStart.month <= startOfMonth.month || 
           currentWeekStart.isBefore(startOfMonth.add(Duration(days: daysInMonth)))) {
      
      final weekRides = rides.where((ride) {
        final rideDate = (ride.data() as Map<String, dynamic>)['concluidaEm'] as Timestamp?;
        if (rideDate == null) return false;
        final date = rideDate.toDate();
        return date.isAfter(currentWeekStart.subtract(const Duration(days: 1))) &&
               date.isBefore(currentWeekStart.add(const Duration(days: 7)));
      }).toList();
      
      final weekTransactions = transactions.where((transaction) {
        final transactionDate = (transaction.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
        if (transactionDate == null) return false;
        final date = transactionDate.toDate();
        return date.isAfter(currentWeekStart.subtract(const Duration(days: 1))) &&
               date.isBefore(currentWeekStart.add(const Duration(days: 7)));
      }).toList();
      
      weeklySummaries.add(_calculateWeeklySummary(weekRides, weekTransactions, currentWeekStart));
      currentWeekStart = currentWeekStart.add(const Duration(days: 7));
    }

    final totalEarnings = weeklySummaries.fold(0.0, (sum, week) => sum + week.totalEarnings);
    final totalFees = weeklySummaries.fold(0.0, (sum, week) => sum + week.totalFees);
    final totalRides = weeklySummaries.fold(0, (sum, week) => sum + week.totalRides);
    final totalDistance = weeklySummaries.fold(0.0, (sum, week) => sum + week.totalDistance);

    return MonthlyFinancialSummary(
      month: startOfMonth.month,
      year: startOfMonth.year,
      totalEarnings: totalEarnings,
      totalFees: totalFees,
      netEarnings: totalEarnings - totalFees,
      totalRides: totalRides,
      totalDistance: totalDistance,
      weeklySummaries: weeklySummaries,
      bestWeek: weeklySummaries.isNotEmpty 
          ? weeklySummaries.reduce((a, b) => a.totalEarnings > b.totalEarnings ? a : b)
          : null,
      averageWeeklyEarnings: weeklySummaries.isNotEmpty ? totalEarnings / weeklySummaries.length : 0,
      workingDays: _calculateWorkingDays(weeklySummaries),
    );
  }

  /// Agrupa ganhos por período
  List<EarningsHistory> _groupEarningsByPeriod(
    List<QueryDocumentSnapshot> rides,
    EarningsGroupBy groupBy,
  ) {
    final Map<String, EarningsHistory> grouped = {};

    for (final ride in rides) {
      final data = ride.data() as Map<String, dynamic>;
      final rideDate = (data['concluidaEm'] as Timestamp?)?.toDate();
      final earnings = (data['valor'] ?? 0).toDouble();
      
      if (rideDate == null) continue;

      String key;
      DateTime periodDate;

      switch (groupBy) {
        case EarningsGroupBy.day:
          key = DateFormat('yyyy-MM-dd').format(rideDate);
          periodDate = DateTime(rideDate.year, rideDate.month, rideDate.day);
          break;
        case EarningsGroupBy.week:
          final weekStart = _getStartOfWeek(rideDate);
          key = DateFormat('yyyy-MM-dd').format(weekStart);
          periodDate = weekStart;
          break;
        case EarningsGroupBy.month:
          key = DateFormat('yyyy-MM').format(rideDate);
          periodDate = DateTime(rideDate.year, rideDate.month);
          break;
      }

      if (grouped.containsKey(key)) {
        grouped[key] = grouped[key]!.copyWith(
          earnings: grouped[key]!.earnings + earnings,
          ridesCount: grouped[key]!.ridesCount + 1,
        );
      } else {
        grouped[key] = EarningsHistory(
          period: periodDate,
          earnings: earnings,
          ridesCount: 1,
          groupBy: groupBy,
        );
      }
    }

    final result = grouped.values.toList();
    result.sort((a, b) => a.period.compareTo(b.period));
    return result;
  }

  /// Calcula estatísticas de performance
  PerformanceStats _calculatePerformanceStats(
    List<QueryDocumentSnapshot> rides,
    List<QueryDocumentSnapshot> ratings,
  ) {
    final completedRides = rides.where((ride) {
      final data = ride.data() as Map<String, dynamic>;
      return data['status'] == 'concluida';
    }).length;

    final cancelledRides = rides.where((ride) {
      final data = ride.data() as Map<String, dynamic>;
      return data['status'] == 'cancelada';
    }).length;

    final totalRides = rides.length;
    final completionRate = totalRides > 0 ? (completedRides / totalRides) * 100 : 0.0;
    final cancellationRate = totalRides > 0 ? (cancelledRides / totalRides) * 100 : 0.0;

    // Calcula avaliação média
    double averageRating = 0.0;
    if (ratings.isNotEmpty) {
      final totalRating = ratings.fold(0.0, (sum, rating) {
        final data = rating.data() as Map<String, dynamic>;
        return sum + (data['nota'] ?? 0).toDouble();
      });
      averageRating = totalRating / ratings.length;
    }

    // Calcula tempo médio de resposta
    Duration averageResponseTime = Duration.zero;
    int responseTimeCount = 0;
    
    for (final ride in rides) {
      final data = ride.data() as Map<String, dynamic>;
      final requestTime = (data['criadaEm'] as Timestamp?)?.toDate();
      final acceptTime = (data['aceitaEm'] as Timestamp?)?.toDate();
      
      if (requestTime != null && acceptTime != null) {
        averageResponseTime += acceptTime.difference(requestTime);
        responseTimeCount++;
      }
    }
    
    if (responseTimeCount > 0) {
      averageResponseTime = Duration(
        milliseconds: averageResponseTime.inMilliseconds ~/ responseTimeCount,
      );
    }

    return PerformanceStats(
      totalRides: totalRides,
      completedRides: completedRides,
      cancelledRides: cancelledRides,
      completionRate: completionRate,
      cancellationRate: cancellationRate,
      averageRating: averageRating,
      totalRatings: ratings.length,
      averageResponseTime: averageResponseTime,
    );
  }

  /// Calcula relatório de impostos
  TaxReport _calculateTaxReport(
    List<QueryDocumentSnapshot> transactions,
    List<QueryDocumentSnapshot> expenses,
    int year,
  ) {
    double totalIncome = 0;
    double totalExpenses = 0;
    
    // Calcula receita total
    for (final transaction in transactions) {
      final data = transaction.data() as Map<String, dynamic>;
      final amount = (data['amount'] ?? 0).toDouble();
      totalIncome += amount;
    }

    // Calcula despesas totais
    for (final expense in expenses) {
      final data = expense.data() as Map<String, dynamic>;
      final amount = (data['valor'] ?? 0).toDouble();
      totalExpenses += amount;
    }

    final netIncome = totalIncome - totalExpenses;
    final estimatedTax = _calculateEstimatedTax(netIncome);

    return TaxReport(
      year: year,
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      netIncome: netIncome,
      estimatedTax: estimatedTax,
      transactions: transactions.length,
      expenseEntries: expenses.length,
    );
  }

  /// Calcula imposto estimado (simplificado)
  double _calculateEstimatedTax(double netIncome) {
    // Cálculo simplificado baseado na tabela do IR 2024
    if (netIncome <= 22847.76) return 0;
    if (netIncome <= 33919.80) return netIncome * 0.075 - 1713.58;
    if (netIncome <= 45012.60) return netIncome * 0.15 - 4257.57;
    if (netIncome <= 55976.16) return netIncome * 0.225 - 7633.51;
    return netIncome * 0.275 - 10432.32;
  }

  /// Obtém início da semana (segunda-feira)
  DateTime _getStartOfWeek(DateTime date) {
    final daysFromMonday = date.weekday - 1;
    return DateTime(date.year, date.month, date.day).subtract(Duration(days: daysFromMonday));
  }

  /// Calcula dias trabalhados
  int _calculateWorkingDays(List<WeeklyFinancialSummary> weeklySummaries) {
    int workingDays = 0;
    for (final week in weeklySummaries) {
      for (final day in week.dailySummaries) {
        if (day.totalRides > 0) workingDays++;
      }
    }
    return workingDays;
  }

  /// Formata valor monetário
  String formatCurrency(double value) {
    return _currencyFormat.format(value);
  }

  /// Formata distância
  String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.toStringAsFixed(0)}m';
    } else {
      return '${(distanceInMeters / 1000).toStringAsFixed(1)}km';
    }
  }

  /// Formata duração
  String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}min';
    } else {
      return '${minutes}min';
    }
  }
}

/// Resumo financeiro diário
class DailyFinancialSummary {
  final DateTime date;
  final double totalEarnings;
  final double totalFees;
  final double netEarnings;
  final int totalRides;
  final double totalDistance;
  final Duration totalTime;
  final double averageRideValue;
  final double averageRideDistance;

  DailyFinancialSummary({
    required this.date,
    required this.totalEarnings,
    required this.totalFees,
    required this.netEarnings,
    required this.totalRides,
    required this.totalDistance,
    required this.totalTime,
    required this.averageRideValue,
    required this.averageRideDistance,
  });

  factory DailyFinancialSummary.empty(DateTime date) {
    return DailyFinancialSummary(
      date: date,
      totalEarnings: 0,
      totalFees: 0,
      netEarnings: 0,
      totalRides: 0,
      totalDistance: 0,
      totalTime: Duration.zero,
      averageRideValue: 0,
      averageRideDistance: 0,
    );
  }
}

/// Resumo financeiro semanal
class WeeklyFinancialSummary {
  final DateTime startDate;
  final DateTime endDate;
  final double totalEarnings;
  final double totalFees;
  final double netEarnings;
  final int totalRides;
  final double totalDistance;
  final List<DailyFinancialSummary> dailySummaries;
  final DailyFinancialSummary bestDay;
  final double averageDailyEarnings;

  WeeklyFinancialSummary({
    required this.startDate,
    required this.endDate,
    required this.totalEarnings,
    required this.totalFees,
    required this.netEarnings,
    required this.totalRides,
    required this.totalDistance,
    required this.dailySummaries,
    required this.bestDay,
    required this.averageDailyEarnings,
  });

  factory WeeklyFinancialSummary.empty(DateTime date) {
    return WeeklyFinancialSummary(
      startDate: date,
      endDate: date,
      totalEarnings: 0,
      totalFees: 0,
      netEarnings: 0,
      totalRides: 0,
      totalDistance: 0,
      dailySummaries: [],
      bestDay: DailyFinancialSummary.empty(date),
      averageDailyEarnings: 0,
    );
  }
}

/// Resumo financeiro mensal
class MonthlyFinancialSummary {
  final int month;
  final int year;
  final double totalEarnings;
  final double totalFees;
  final double netEarnings;
  final int totalRides;
  final double totalDistance;
  final List<WeeklyFinancialSummary> weeklySummaries;
  final WeeklyFinancialSummary? bestWeek;
  final double averageWeeklyEarnings;
  final int workingDays;

  MonthlyFinancialSummary({
    required this.month,
    required this.year,
    required this.totalEarnings,
    required this.totalFees,
    required this.netEarnings,
    required this.totalRides,
    required this.totalDistance,
    required this.weeklySummaries,
    required this.bestWeek,
    required this.averageWeeklyEarnings,
    required this.workingDays,
  });

  factory MonthlyFinancialSummary.empty(DateTime date) {
    return MonthlyFinancialSummary(
      month: date.month,
      year: date.year,
      totalEarnings: 0,
      totalFees: 0,
      netEarnings: 0,
      totalRides: 0,
      totalDistance: 0,
      weeklySummaries: [],
      bestWeek: null,
      averageWeeklyEarnings: 0,
      workingDays: 0,
    );
  }
}

/// Histórico de ganhos
class EarningsHistory {
  final DateTime period;
  final double earnings;
  final int ridesCount;
  final EarningsGroupBy groupBy;

  EarningsHistory({
    required this.period,
    required this.earnings,
    required this.ridesCount,
    required this.groupBy,
  });

  EarningsHistory copyWith({
    DateTime? period,
    double? earnings,
    int? ridesCount,
    EarningsGroupBy? groupBy,
  }) {
    return EarningsHistory(
      period: period ?? this.period,
      earnings: earnings ?? this.earnings,
      ridesCount: ridesCount ?? this.ridesCount,
      groupBy: groupBy ?? this.groupBy,
    );
  }
}

/// Estatísticas de performance
class PerformanceStats {
  final int totalRides;
  final int completedRides;
  final int cancelledRides;
  final double completionRate;
  final double cancellationRate;
  final double averageRating;
  final int totalRatings;
  final Duration averageResponseTime;

  PerformanceStats({
    required this.totalRides,
    required this.completedRides,
    required this.cancelledRides,
    required this.completionRate,
    required this.cancellationRate,
    required this.averageRating,
    required this.totalRatings,
    required this.averageResponseTime,
  });

  factory PerformanceStats.empty() {
    return PerformanceStats(
      totalRides: 0,
      completedRides: 0,
      cancelledRides: 0,
      completionRate: 0,
      cancellationRate: 0,
      averageRating: 0,
      totalRatings: 0,
      averageResponseTime: Duration.zero,
    );
  }
}

/// Relatório de impostos
class TaxReport {
  final int year;
  final double totalIncome;
  final double totalExpenses;
  final double netIncome;
  final double estimatedTax;
  final int transactions;
  final int expenseEntries;

  TaxReport({
    required this.year,
    required this.totalIncome,
    required this.totalExpenses,
    required this.netIncome,
    required this.estimatedTax,
    required this.transactions,
    required this.expenseEntries,
  });

  factory TaxReport.empty(int year) {
    return TaxReport(
      year: year,
      totalIncome: 0,
      totalExpenses: 0,
      netIncome: 0,
      estimatedTax: 0,
      transactions: 0,
      expenseEntries: 0,
    );
  }
}

/// Tipos de agrupamento de ganhos
enum EarningsGroupBy {
  day,
  week,
  month,
}