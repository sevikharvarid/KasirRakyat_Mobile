import 'package:kasir_rakyat/core/services/app_data_store.dart';
import 'package:kasir_rakyat/features/reports/models/reports_models.dart';

class ReportsRepository {
  final _store = AppDataStore.instance;

  // Filter transactions to the requested period
  List<AppTransaction> _txsFor(ReportsPeriod period) {
    final now = DateTime.now();
    final cutoff = switch (period) {
      ReportsPeriod.today => DateTime(now.year, now.month, now.day),
      ReportsPeriod.week  => now.subtract(const Duration(days: 6)),
      ReportsPeriod.month => DateTime(now.year, now.month, 1),
    };
    return _store.transactions
        .where((t) => !t.createdAt.isBefore(cutoff))
        .toList();
  }

  Future<ReportsSummary> getSummary(ReportsPeriod period) async {
    final txs = _txsFor(period);
    final totalRevenue    = txs.fold(0, (s, t) => s + t.subtotal);
    final totalCost       = txs.fold(0, (s, t) => t.items.fold(s, (ss, i) => ss + i.buyPrice * i.quantity));
    final netProfit       = totalRevenue - totalCost;
    final marginPercent   = totalRevenue == 0 ? 0 : ((netProfit / totalRevenue) * 100).round();
    return ReportsSummary(
      totalRevenue: totalRevenue,
      revenueGrowthPercent: 0, // growth requires historical data — future sprint
      totalTransactions: txs.length,
      netProfit: netProfit,
      marginPercent: marginPercent,
    );
  }

  Future<List<DailyRevenue>> getDailyRevenues(ReportsPeriod period) async {
    final txs = _txsFor(period);

    if (period == ReportsPeriod.today) {
      // Bucket by hour (08–20)
      final Map<int, int> byHour = {};
      for (final tx in txs) {
        byHour[tx.createdAt.hour] = (byHour[tx.createdAt.hour] ?? 0) + tx.subtotal;
      }
      if (byHour.isEmpty) return const [];
      final hours = byHour.keys.toList()..sort();
      return hours.map((h) => DailyRevenue(
        dayLabel: '${h.toString().padLeft(2, '0')}:00',
        amount: byHour[h]!,
      )).toList();
    }

    if (period == ReportsPeriod.week) {
      const dayNames = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
      final now = DateTime.now();
      return List.generate(7, (i) {
        final day = now.subtract(Duration(days: 6 - i));
        final label = dayNames[(day.weekday - 1) % 7];
        final amount = txs
            .where((t) => _sameDay(t.createdAt, day))
            .fold(0, (s, t) => s + t.subtotal);
        return DailyRevenue(dayLabel: label, amount: amount);
      });
    }

    // month — bucket by week number within month
    final Map<int, int> byWeek = {};
    for (final tx in txs) {
      final week = ((tx.createdAt.day - 1) ~/ 7) + 1;
      byWeek[week] = (byWeek[week] ?? 0) + tx.subtotal;
    }
    if (byWeek.isEmpty) return const [];
    final weeks = byWeek.keys.toList()..sort();
    return weeks.map((w) => DailyRevenue(
      dayLabel: 'Mg $w',
      amount: byWeek[w]!,
    )).toList();
  }

  Future<List<TopProduct>> getTopProducts(ReportsPeriod period) async {
    final txs = _txsFor(period);
    final Map<int, _ProductAgg> agg = {};

    for (final tx in txs) {
      for (final item in tx.items) {
        final a = agg.putIfAbsent(item.productId, () => _ProductAgg(item.productName));
        a.soldCount += item.quantity;
        a.revenue   += item.subtotal;
      }
    }

    final sorted = agg.entries.toList()
      ..sort((a, b) => b.value.soldCount.compareTo(a.value.soldCount));

    return sorted.take(5).map((e) {
      final stock = _store.products
          .where((p) => p.id == e.key)
          .map((p) => p.stock)
          .firstOrNull ?? 0;
      return TopProduct(
        name: e.value.name,
        soldCount: e.value.soldCount,
        revenue: e.value.revenue,
        stock: stock,
      );
    }).toList();
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _ProductAgg {
  final String name;
  int soldCount = 0;
  int revenue   = 0;
  _ProductAgg(this.name);
}
