import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kasir_rakyat/features/reports/models/reports_models.dart';

part 'reports_state.freezed.dart';

@freezed
class ReportsState with _$ReportsState {
  const factory ReportsState.initial() = _Initial;
  const factory ReportsState.loading() = _Loading;
  const factory ReportsState.loaded({
    required ReportsPeriod period,
    required ReportsSummary summary,
    required List<DailyRevenue> dailyRevenues,
    required List<TopProduct> topProducts,
  }) = _Loaded;
  const factory ReportsState.error(String message) = _Error;
}
