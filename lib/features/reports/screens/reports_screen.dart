// ignore_for_file: unused_element
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:kasir_rakyat/core/widgets/kr_shimmer.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasir_rakyat/core/constants/app_colors.dart';
import 'package:kasir_rakyat/core/utils/currency_formatter.dart';
import 'package:kasir_rakyat/features/reports/cubit/reports_cubit.dart';
import 'package:kasir_rakyat/features/reports/cubit/reports_state.dart';
import 'package:kasir_rakyat/features/reports/models/reports_models.dart';
import 'package:kasir_rakyat/features/reports/repository/reports_repository.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReportsCubit(ReportsRepository())..loadReport(ReportsPeriod.today),
      child: const _ReportsView(),
    );
  }
}

class _ReportsView extends StatelessWidget {
  const _ReportsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primarySurface,
      body: Column(
        children: [
          const _AppBar(),
          Expanded(
            child: BlocBuilder<ReportsCubit, ReportsState>(
              builder: (context, state) {
                return state.when(
                  initial: () => const SizedBox.shrink(),
                  loading: () => const _ReportsShimmer(),
                  loaded: (period, summary, dailyRevenues, topProducts) => _LoadedBody(
                    period: period,
                    summary: summary,
                    dailyRevenues: dailyRevenues,
                    topProducts: topProducts,
                    onRefresh: () async =>
                        context.read<ReportsCubit>().loadReport(period),
                  ),
                  error: (message) => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: AppColors.danger),
                        const SizedBox(height: 12),
                        Text(message, style: const TextStyle(color: AppColors.textSecondary)),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () =>
                              context.read<ReportsCubit>().loadReport(ReportsPeriod.today),
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  const _AppBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primarySurface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 56,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: const Row(
              children: [
                Text(
                  'Laporan',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadedBody extends StatelessWidget {
  final ReportsPeriod period;
  final ReportsSummary summary;
  final List<DailyRevenue> dailyRevenues;
  final List<TopProduct> topProducts;
  final Future<void> Function() onRefresh;

  const _LoadedBody({
    required this.period,
    required this.summary,
    required this.dailyRevenues,
    required this.topProducts,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.primary,
      child: ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        _PeriodFilter(selected: period),
        const SizedBox(height: 16),
        _RevenueCard(summary: summary, period: period),
        const SizedBox(height: 12),
        _MetricRow(summary: summary),
        const SizedBox(height: 20),
        if (dailyRevenues.isNotEmpty) ...[
          _TrendChart(dailyRevenues: dailyRevenues),
          const SizedBox(height: 20),
        ],
        _TopProductsSection(products: topProducts, period: period),
      ],
      ),
    );
  }
}

class _ReportsShimmer extends StatelessWidget {
  const _ReportsShimmer();

  static Widget _box(double height, {double radius = 12}) => Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: KrShimmer.base,
      highlightColor: KrShimmer.highlight,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // Period filter chips
          Row(
            children: List.generate(
              4,
              (_) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Container(
                  width: 72,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Revenue card
          _box(130, radius: 16),
          const SizedBox(height: 12),
          // Metric row
          Row(
            children: [
              Expanded(child: _box(100)),
              const SizedBox(width: 12),
              Expanded(child: _box(100)),
            ],
          ),
          const SizedBox(height: 20),
          // Chart
          _box(228, radius: 16),
          const SizedBox(height: 20),
          // Top products
          _box(260, radius: 16),
        ],
      ),
    );
  }
}

class _PeriodFilter extends StatelessWidget {
  final ReportsPeriod selected;
  const _PeriodFilter({required this.selected});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ReportsPeriod.values.map((p) {
          final isActive = p == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => context.read<ReportsCubit>().changePeriod(p),
              borderRadius: BorderRadius.circular(99),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : AppColors.primaryChipInactive,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  p.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isActive ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _RevenueCard extends StatelessWidget {
  final ReportsSummary summary;
  final ReportsPeriod period;
  const _RevenueCard({required this.summary, required this.period});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Total Penjualan · ${period.label}',
                style: const TextStyle(fontSize: 13, color: Colors.white70),
              ),
              const Spacer(),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.payments_outlined, color: Colors.white, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            formatRupiah(summary.totalRevenue),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            summary.totalTransactions == 0
                ? 'Belum ada transaksi pada periode ini'
                : '${summary.totalTransactions} transaksi selesai',
            style: const TextStyle(fontSize: 13, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  final ReportsSummary summary;
  const _MetricRow({required this.summary});

  static String _fmt(int amount) {
    if (amount >= 1000000) return 'Rp ${(amount / 1000000).toStringAsFixed(1)}jt';
    if (amount >= 1000) return 'Rp ${(amount / 1000).round()}k';
    return formatRupiah(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            title: 'Transaksi',
            icon: Icons.receipt_long_outlined,
            iconColor: AppColors.warning,
            value: '${summary.totalTransactions}',
            sub: 'Berhasil',
            subColor: AppColors.warning,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MetricCard(
            title: 'Laba Bersih',
            icon: Icons.savings_outlined,
            iconColor: AppColors.info,
            value: _fmt(summary.netProfit),
            sub: 'Margin ${summary.marginPercent}%',
            subColor: AppColors.info,
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final String value;
  final String sub;
  final Color subColor;

  const _MetricCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.sub,
    required this.subColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const Spacer(),
              Icon(icon, color: iconColor, size: 20),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(sub, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: subColor)),
        ],
      ),
    );
  }
}

class _TrendChart extends StatelessWidget {
  final List<DailyRevenue> dailyRevenues;
  const _TrendChart({required this.dailyRevenues});

  @override
  Widget build(BuildContext context) {
    final maxY = dailyRevenues.fold(0.0, (m, e) => e.amount > m ? e.amount.toDouble() : m);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tren Penjualan',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                maxY: maxY == 0 ? 1 : maxY * 1.3,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: AppColors.border.withValues(alpha: 0.7),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        final i = v.toInt();
                        if (i < 0 || i >= dailyRevenues.length) return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            dailyRevenues[i].dayLabel,
                            style: const TextStyle(fontSize: 10, color: AppColors.textTertiary),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(dailyRevenues.length, (i) => BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: dailyRevenues[i].amount.toDouble(),
                      color: AppColors.primary,
                      width: dailyRevenues.length > 10 ? 8 : 16,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                    ),
                  ],
                )),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => AppColors.primary,
                    getTooltipItem: (_, __, rod, ___) => BarTooltipItem(
                      formatRupiah(rod.toY.round()),
                      const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopProductsSection extends StatelessWidget {
  final List<TopProduct> products;
  final ReportsPeriod period;

  const _TopProductsSection({required this.products, required this.period});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                const Text(
                  'Produk Terlaris',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                const Spacer(),
                Text(period.label, style: const TextStyle(fontSize: 12, color: AppColors.textTertiary)),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          if (products.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.bar_chart_outlined, size: 40, color: AppColors.textTertiary),
                    SizedBox(height: 8),
                    Text(
                      'Belum ada data penjualan',
                      style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Selesaikan transaksi di menu Kasir\nuntuk melihat laporan.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: AppColors.textTertiary, height: 1.5),
                    ),
                  ],
                ),
              ),
            )
          else
            ...products.asMap().entries.map((e) => _TopProductTile(
                  rank: e.key + 1,
                  product: e.value,
                  isLast: e.key == products.length - 1,
                )),
        ],
      ),
    );
  }
}

class _TopProductTile extends StatelessWidget {
  final int rank;
  final TopProduct product;
  final bool isLast;

  const _TopProductTile({required this.rank, required this.product, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: rank == 1 ? AppColors.primary : AppColors.primaryChipInactive,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$rank',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: rank == 1 ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${product.soldCount} terjual',
                      style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatRupiah(product.revenue),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  _StockChip(stock: product.stock),
                ],
              ),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1, indent: 56, color: AppColors.border),
      ],
    );
  }
}

class _StockChip extends StatelessWidget {
  final int stock;
  const _StockChip({required this.stock});

  @override
  Widget build(BuildContext context) {
    final Color color;
    final String label;
    if (stock == 0) {
      color = AppColors.danger; label = 'Habis';
    } else if (stock <= 5) {
      color = AppColors.warning; label = 'Menipis';
    } else {
      color = AppColors.primary; label = 'Stok $stock';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: color),
      ),
    );
  }
}
