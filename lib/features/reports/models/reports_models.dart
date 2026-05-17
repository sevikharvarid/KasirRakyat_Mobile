enum ReportsPeriod { today, week, month }

extension ReportsPeriodLabel on ReportsPeriod {
  String get label {
    switch (this) {
      case ReportsPeriod.today: return 'Hari ini';
      case ReportsPeriod.week: return '7 Hari Terakhir';
      case ReportsPeriod.month: return 'Bulan Ini';
    }
  }
}

class ReportsSummary {
  final int totalRevenue;
  final int revenueGrowthPercent;
  final int totalTransactions;
  final int netProfit;
  final int marginPercent;

  const ReportsSummary({
    required this.totalRevenue,
    required this.revenueGrowthPercent,
    required this.totalTransactions,
    required this.netProfit,
    required this.marginPercent,
  });
}

class DailyRevenue {
  final String dayLabel;
  final int amount;

  const DailyRevenue({required this.dayLabel, required this.amount});
}

class TopProduct {
  final String name;
  final String? imageUrl;
  final int soldCount;
  final int revenue;
  final int stock;

  const TopProduct({
    required this.name,
    this.imageUrl,
    required this.soldCount,
    required this.revenue,
    required this.stock,
  });
}
